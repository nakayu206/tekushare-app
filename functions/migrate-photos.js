/**
 * 既存写真の移行スクリプト（手動で1回実行する）。
 *   1. users/{uid}/spots/{spotId}.photoPaths のダウンロードURLを Storage のパスに置換
 *      あわせて accountLinks に shares（各ユーザーの共有設定。Storage ルールが参照）を補完する
 *      （ドキュメントごとのトランザクションで最新値を読み直して更新するため、
 *        実行中のユーザーの写真追加・削除を上書きしない）
 *   2. users/ 配下の全ファイルのダウンロードトークンを削除（既存URLを失効させる）
 *
 * 使い方: GOOGLE_APPLICATION_CREDENTIALS を設定し、
 *   node migrate-photos.js <projectId> <bucket> [--apply]
 * --apply を付けない場合は変更せず対象件数のみ表示する（ドライラン）。
 * 実行前に新バージョンのアプリ（パス保存・パス表示対応）が配布済みであることを確認すること。
 */
const admin = require("firebase-admin");

const [projectId, bucketName, flag] = process.argv.slice(2);
if (!projectId || !bucketName) {
  console.error("usage: node migrate-photos.js <projectId> <bucket> [--apply]");
  process.exit(1);
}
const apply = flag === "--apply";
admin.initializeApp({ projectId, storageBucket: bucketName });
const db = admin.firestore();
const bucket = admin.storage().bucket();

// https://firebasestorage.googleapis.com/v0/b/<bucket>/o/<encodedPath>?alt=media&token=...
function toStoragePath(url) {
  if (!url.startsWith("https://")) return url;
  const m = url.match(/\/o\/([^?]+)/);
  return m ? decodeURIComponent(m[1]) : url;
}

(async () => {
  let spots = 0;
  const snap = await db.collectionGroup("spots").get();
  for (const doc of snap.docs) {
    // 取得済みの値は使わず、トランザクション内で最新のドキュメントから再計算する
    const changed = await db.runTransaction(async (tx) => {
      const fresh = await tx.get(doc.ref);
      if (!fresh.exists) return false;
      const data = fresh.data();
      const paths = data.photoPaths ?? [];
      const converted = paths.map(toStoragePath);
      if (!converted.some((p, i) => p !== paths[i])) return false;
      if (apply) tx.update(doc.ref, { photoPaths: converted });
      return true;
    });
    if (changed) spots++;
  }
  console.log(`更新対象のスポット: ${spots}`);

  // 連携ごとの共有設定(shares)を、各ユーザーの現在の設定から補完する
  let links = 0;
  const linkSnap = await db.collection("accountLinks").get();
  for (const link of linkSnap.docs) {
    const uids = link.data().uids ?? [];
    const changed = await db.runTransaction(async (tx) => {
      const fresh = await tx.get(link.ref);
      if (!fresh.exists || fresh.data().shares) return false;
      const users = await Promise.all(uids.map((u) => tx.get(db.collection("users").doc(u))));
      const shares = {};
      uids.forEach((u, i) => {
        const d = users[i].data();
        shares[u] = { wantToGo: d?.shareWantToGo !== false, visited: d?.shareVisited !== false };
      });
      if (apply) tx.update(link.ref, { shares });
      return true;
    });
    if (changed) links++;
  }
  console.log(`shares 補完対象の連携: ${links}`);

  let files = 0;
  const [all] = await bucket.getFiles({ prefix: "users/" });
  for (const file of all) {
    if (file.metadata.metadata?.firebaseStorageDownloadTokens) {
      files++;
      if (apply) {
        await file.setMetadata({ metadata: { firebaseStorageDownloadTokens: null } });
      }
    }
  }
  console.log(`トークン削除対象のファイル: ${files}`);
  console.log(apply ? "適用しました" : "ドライランです（--apply で適用）");
})();
