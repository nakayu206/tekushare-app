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
 * スポットの作成・更新時に、Storage ルールが参照する shared フィールドを同期する。
 * Storage ルールは Firestore を2件までしか参照できないため、共有設定を非正規化する。
 */
export const syncSpotShared = functions
  .region("asia-northeast1")
  .runWith({ failurePolicy: true })
  .firestore.document("users/{uid}/spots/{spotId}")
  .onWrite(async (change, context) => {
    if (!change.after.exists) return;
    const ownerSnap = await db.collection("users").doc(context.params.uid).get();
    const shared = isSpotShared(change.after.data()?.status, ownerSnap.data());
    if (change.after.data()?.shared === shared) return;
    await change.after.ref.update({ shared });
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
    const spots = await db
      .collection("users")
      .doc(context.params.uid)
      .collection("spots")
      .get();
    await Promise.all(
      spots.docs.map((doc) => {
        const shared = isSpotShared(doc.data().status, after);
        return doc.data().shared === shared ? null : doc.ref.update({ shared });
      }),
    );
  });
