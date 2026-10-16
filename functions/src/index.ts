import * as admin from "firebase-admin";
import * as functions from "firebase-functions/v1";

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

/**
 * users/{uid} の walkingStatus が 'walking' に変わったとき、
 * 連携アカウントへ FCM プッシュ通知を送信する。
 */
export const onWalkStarted = functions
  .region("asia-northeast1")
  .firestore.document("users/{uid}")
  .onWrite(async (change, context) => {
    const uid = context.params.uid;
    const before = change.before.data();
    const after = change.after.data();

    // walkingStatus が 'walking' になった瞬間だけ処理する
    const isNowWalking = after?.walkingStatus === "walking";
    const wasWalking = before?.walkingStatus === "walking";
    if (!isNowWalking || wasWalking) return;

    const displayName =
      (after?.displayName as string | undefined) ?? "お友達";

    // 連携アカウントを検索
    const linksSnap = await db
      .collection("accountLinks")
      .where("uids", "array-contains", uid)
      .get();

    if (linksSnap.empty) return;

    const partnerUids = linksSnap.docs.flatMap((doc) => {
      const uids = doc.data().uids as string[];
      return uids.filter((u) => u !== uid);
    });

    // 各パートナーへ FCM 送信
    await Promise.all(
      partnerUids.map(async (partnerUid) => {
        const tokenDoc = await db
          .collection("users")
          .doc(partnerUid)
          .collection("private")
          .doc("fcm")
          .get();
        const fcmToken = tokenDoc.data()?.fcmToken as string | undefined;
        if (!fcmToken) return;

        await messaging.send({
          token: fcmToken,
          notification: {
            title: "散歩開始",
            body: `${displayName}が散歩を始めました`,
          },
          data: {
            type: "walk_started",
            partnerUid: uid,
          },
          apns: {
            payload: {
              aps: { sound: "default" },
            },
          },
          android: {
            notification: { sound: "default" },
          },
        });
      }),
    );
  });

const DOWNLOAD_TOKEN_KEY = "firebaseStorageDownloadTokens";

/** ファイルのダウンロードトークンを削除する（トークンが無ければ何もしない） */
async function revokeToken(bucketName: string, name: string): Promise<boolean> {
  const file = admin.storage().bucket(bucketName).file(name);
  const [metadata] = await file.getMetadata();
  if (!metadata.metadata?.[DOWNLOAD_TOKEN_KEY]) return false;
  await file.setMetadata({ metadata: { [DOWNLOAD_TOKEN_KEY]: null } });
  return true;
}

/**
 * 写真がアップロードされたら、ダウンロードトークンを削除する。
 * トークン付きURLは長期間有効で連携解除・共有OFFでも失効しないため、
 * 写真はルール（認証付き）経由の取得だけに限定する。
 * 失敗時は自動再試行し、取りこぼしは sweepDownloadTokens が回収する。
 */
export const revokeDownloadToken = functions
  .region("asia-northeast1")
  .runWith({ failurePolicy: true })
  .storage.object()
  .onFinalize(async (object) => {
    const name = object.name;
    if (!name || !name.startsWith("users/")) return;
    if (!object.metadata?.[DOWNLOAD_TOKEN_KEY]) return;
    await revokeToken(object.bucket, name);
  });

/**
 * トークンが残っている写真を毎日探して削除する（revokeDownloadToken の取りこぼし回収用）。
 */
export const sweepDownloadTokens = functions
  .region("asia-northeast1")
  .pubsub.schedule("every 24 hours")
  .onRun(async () => {
    const [files] = await admin.storage().bucket().getFiles({ prefix: "users/" });
    let revoked = 0;
    for (const file of files) {
      if (!file.metadata.metadata?.[DOWNLOAD_TOKEN_KEY]) continue;
      try {
        if (await revokeToken(file.bucket.name, file.name)) revoked++;
      } catch (e) {
        functions.logger.error("[sweepDownloadTokens] トークン削除に失敗", {
          file: file.name,
          error: String(e),
        });
      }
    }
    functions.logger.info(`[sweepDownloadTokens] ${revoked}件のトークンを削除`);
  });

/** ステータスと共有設定から、連携相手に写真を見せてよいかを求める（未設定はデフォルトON） */
function isSpotShared(
  status: string | undefined,
  owner: FirebaseFirestore.DocumentData | undefined,
): boolean {
  if (status === "wantToGo") return owner?.shareWantToGo !== false;
  if (status === "visited") return owner?.shareVisited !== false;
  return false;
}

/**
 * スポット1件の shared を、最新の共有設定・ステータスから再計算して同期する。
 * トランザクション内で読み直すため、遅れて届いた古いイベントが
 * 共有OFF後に shared を true へ戻すことはない。
 */
async function syncSpotSharedTx(
  ownerRef: FirebaseFirestore.DocumentReference,
  spotRef: FirebaseFirestore.DocumentReference,
): Promise<void> {
  await db.runTransaction(async (tx) => {
    const spotSnap = await tx.get(spotRef);
    if (!spotSnap.exists) return;
    const ownerSnap = await tx.get(ownerRef);
    const shared = isSpotShared(spotSnap.data()?.status, ownerSnap.data());
    if (spotSnap.data()?.shared !== shared) tx.update(spotRef, { shared });
  });
}

/**
 * スポットの作成・更新時に、Storage ルールが参照する shared フィールドを同期する。
 * Storage ルールは Firestore を2件までしか参照できないため、共有設定を非正規化する。
 * 非公開への変更はクライアントが先に shared=false を書いて即時に反映し、
 * こちらは共有ON側への反映と取りこぼしの補正を担う（失敗時は安全側＝非公開）。
 */
export const syncSpotShared = functions
  .region("asia-northeast1")
  .runWith({ failurePolicy: true })
  .firestore.document("users/{uid}/spots/{spotId}")
  .onWrite(async (change, context) => {
    if (!change.after.exists) return;
    await syncSpotSharedTx(
      db.collection("users").doc(context.params.uid),
      change.after.ref,
    );
  });

/**
 * 共有設定が変更されたら、そのユーザーの全スポットの shared を更新する。
 */
export const syncSharedOnSettingsChange = functions
  .region("asia-northeast1")
  .runWith({ failurePolicy: true })
  .firestore.document("users/{uid}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    if (
      before.shareWantToGo === after.shareWantToGo &&
      before.shareVisited === after.shareVisited
    ) {
      return;
    }
    const ownerRef = db.collection("users").doc(context.params.uid);
    const spots = await ownerRef.collection("spots").get();
    await Promise.all(spots.docs.map((doc) => syncSpotSharedTx(ownerRef, doc.ref)));
  });
