const { test, before, after } = require("node:test");
const fs = require("node:fs");
const path = require("node:path");
const {
  initializeTestEnvironment, assertSucceeds, assertFails,
} = require("@firebase/rules-unit-testing");
const { doc, setDoc, deleteDoc } = require("firebase/firestore");
const { ref, getBytes, uploadBytes, deleteObject } = require("firebase/storage");

let env;
const file = "users/alice/spots/s1/a.jpg";
const png = new Uint8Array([1, 2, 3]);

before(async () => {
  env = await initializeTestEnvironment({
    projectId: "demo-tekushare",
    firestore: {
      rules: fs.readFileSync(path.join(__dirname, "../firestore.rules"), "utf8"),
      host: "127.0.0.1", port: 8080,
    },
    storage: {
      rules: fs.readFileSync(path.join(__dirname, "../storage.rules"), "utf8"),
      host: "127.0.0.1", port: 9199,
    },
  });
  await env.withSecurityRulesDisabled(async (ctx) => {
    const fs_ = ctx.firestore();
    await setDoc(doc(fs_, "accountLinks/alice_bob"), {
      uids: ["alice", "bob"],
      shares: { alice: { wantToGo: true, visited: false }, bob: { wantToGo: true, visited: true } },
    });
    await setDoc(doc(fs_, "users/alice"), { displayName: "A", shareVisited: false });
    await setDoc(doc(fs_, "users/alice/spots/s1"), { status: "wantToGo" });
    await setDoc(doc(fs_, "users/alice/spots/s2"), { status: "visited" });
    await uploadBytes(ref(ctx.storage(), "users/alice/spots/s2/a.jpg"), png, { contentType: "image/jpeg" });
    await uploadBytes(ref(ctx.storage(), "users/alice/spots/gone/a.jpg"), png, { contentType: "image/jpeg" });
    await uploadBytes(ref(ctx.storage(), file), png, { contentType: "image/jpeg" });
  });
});
after(() => env.cleanup());

test("読み取りは本人と連携相手のみ", async () => {
  await assertSucceeds(getBytes(ref(env.authenticatedContext("alice").storage(), file)));
  await assertSucceeds(getBytes(ref(env.authenticatedContext("bob").storage(), file)));
  await assertFails(getBytes(ref(env.authenticatedContext("mallory").storage(), file)));
});

test("共有OFFのスポット・削除済みスポットの写真は連携相手も読めない", async () => {
  const bob = env.authenticatedContext("bob").storage();
  const alice = env.authenticatedContext("alice").storage();
  await assertFails(getBytes(ref(bob, "users/alice/spots/s2/a.jpg")));
  await assertFails(getBytes(ref(bob, "users/alice/spots/gone/a.jpg")));
  await assertSucceeds(getBytes(ref(alice, "users/alice/spots/s2/a.jpg")));
  await assertSucceeds(getBytes(ref(alice, "users/alice/spots/gone/a.jpg")));
});

test("共有設定の更新は1回の書き込みで全スポットの写真に即時反映される", async () => {
  // 旧設計ではスポットごとの更新が分割バッチになり、更新前の写真が取得できてしまった。
  // 連携の shares を1か所更新するだけで、スポットが何件あっても一括で拒否される。
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, "users/alice/spots/s3"), { status: "wantToGo" });
    await uploadBytes(ref(ctx.storage(), "users/alice/spots/s3/a.jpg"), png, { contentType: "image/jpeg" });
  });
  const bob = env.authenticatedContext("bob").storage();
  await assertSucceeds(getBytes(ref(bob, "users/alice/spots/s3/a.jpg")));
  await assertSucceeds(getBytes(ref(bob, file)));

  await env.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), "accountLinks/alice_bob"), {
      uids: ["alice", "bob"],
      shares: { alice: { wantToGo: false, visited: false }, bob: { wantToGo: true, visited: true } },
    });
  });
  await assertFails(getBytes(ref(bob, "users/alice/spots/s3/a.jpg")));
  await assertFails(getBytes(ref(bob, file)));
  await assertSucceeds(getBytes(ref(env.authenticatedContext("alice").storage(), file)));
});

test("連携が解除されると写真は読めない", async () => {
  await env.withSecurityRulesDisabled(async (ctx) => {
    await deleteDoc(doc(ctx.firestore(), "accountLinks/alice_bob"));
  });
  await assertFails(getBytes(ref(env.authenticatedContext("bob").storage(), file)));
});

test("書き込みは本人の画像のみ・サイズ上限あり", async () => {
  const alice = env.authenticatedContext("alice").storage();
  const mallory = env.authenticatedContext("mallory").storage();
  const p = "users/alice/spots/s1/b.jpg";
  await assertSucceeds(uploadBytes(ref(alice, p), png, { contentType: "image/jpeg" }));
  await assertFails(uploadBytes(ref(alice, p), png, { contentType: "text/html" }));
  await assertFails(uploadBytes(ref(alice, p), new Uint8Array(10 * 1024 * 1024 + 1), { contentType: "image/jpeg" }));
  await assertFails(uploadBytes(ref(mallory, p), png, { contentType: "image/jpeg" }));
  await assertFails(deleteObject(ref(mallory, p)));
  await assertSucceeds(deleteObject(ref(alice, p)));
});
