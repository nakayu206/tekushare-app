import * as admin from "firebase-admin";
import { onDocumentWritten } from "firebase-functions/v2/firestore";

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

/**
 * users/{uid} の walkingStatus が 'walking' に変わったとき、
 * 連携アカウントへ FCM プッシュ通知を送信する。
 */
export const onWalkStarted = onDocumentWritten(
  "users/{uid}",
  async (event) => {
    const uid = event.params.uid;
    const after = event.data?.after?.data();
    const before = event.data?.before?.data();

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
        const userDoc = await db.collection("users").doc(partnerUid).get();
        const fcmToken = userDoc.data()?.fcmToken as string | undefined;
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
  },
);
