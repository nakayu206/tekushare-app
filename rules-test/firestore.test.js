const { test, before, after, beforeEach } = require("node:test");
const assert = require("node:assert");
const fs = require("node:fs");
const path = require("node:path");
const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require("@firebase/rules-unit-testing");
const {
  doc, getDoc, getDocs, collection, setDoc, writeBatch, Timestamp,
} = require("firebase/firestore");

const future = () => Timestamp.fromDate(new Date(Date.now() + 86400000));
let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: "demo-tekushare",
    firestore: {
      rules: fs.readFileSync(path.join(__dirname, "../firestore.rules"), "utf8"),
      host: "127.0.0.1",
      port: 8080,
    },
  });
});
after(() => env.cleanup());
beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, "linkInvites/t1"), {
      fromUid: "alice", used: false, expiresAt: future(),
    });
    await setDoc(doc(db, "users/alice"), { displayName: "A" });
    await setDoc(doc(db, "users/alice/private/fcm"), { fcmToken: "x" });
  });
});

const linkData = (token = "t1") => ({
  uids: ["alice", "bob"], inviteToken: token, createdAt: Timestamp.now(),
});

test("招待は list 不可・get 可", async () => {
  const db = env.authenticatedContext("mallory").firestore();
  await assertFails(getDocs(collection(db, "linkInvites")));
  await assertSucceeds(getDoc(doc(db, "linkInvites/t1")));
});

test("users は list 不可・get 可、private は本人のみ", async () => {
  const bob = env.authenticatedContext("bob").firestore();
  await assertFails(getDocs(collection(bob, "users")));
  await assertSucceeds(getDoc(doc(bob, "users/alice")));
  await assertFails(getDoc(doc(bob, "users/alice/private/fcm")));
  const alice = env.authenticatedContext("alice").firestore();
  await assertSucceeds(getDoc(doc(alice, "users/alice/private/fcm")));
});

test("連携作成は招待の使用済み化とセットなら成功", async () => {
  const db = env.authenticatedContext("bob").firestore();
  const b = writeBatch(db);
  b.set(doc(db, "accountLinks/alice_bob"), linkData());
  b.update(doc(db, "linkInvites/t1"), { used: true });
  await assertSucceeds(b.commit());
});

test("招待を使用済みにしない連携作成は失敗", async () => {
  const db = env.authenticatedContext("bob").firestore();
  await assertFails(setDoc(doc(db, "accountLinks/alice_bob"), linkData()));
});

test("期限切れ招待・不正な linkId は失敗", async () => {
  await env.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), "linkInvites/old"), {
      fromUid: "alice", used: false,
      expiresAt: Timestamp.fromDate(new Date(Date.now() - 1000)),
    });
  });
  const db = env.authenticatedContext("bob").firestore();
  const b1 = writeBatch(db);
  b1.set(doc(db, "accountLinks/alice_bob"), linkData("old"));
  b1.update(doc(db, "linkInvites/old"), { used: true });
  await assertFails(b1.commit());

  const b2 = writeBatch(db);
  b2.set(doc(db, "accountLinks/bob_alice"), linkData());
  b2.update(doc(db, "linkInvites/t1"), { used: true });
  await assertFails(b2.commit());
});

test("contacts は本人のみ。連携相手・他人は読めない", async () => {
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, "users/alice/contacts/c1"), { name: "n", phone: "090" });
    await setDoc(doc(db, "accountLinks/alice_bob"), { uids: ["alice", "bob"] });
  });
  const alice = env.authenticatedContext("alice").firestore();
  await assertSucceeds(getDoc(doc(alice, "users/alice/contacts/c1")));
  for (const uid of ["bob", "mallory"]) {
    const db = env.authenticatedContext(uid).firestore();
    await assertFails(getDoc(doc(db, "users/alice/contacts/c1")));
    await assertFails(getDocs(collection(db, "users/alice/contacts")));
    await assertFails(setDoc(doc(db, "users/alice/contacts/c2"), { name: "x", phone: "1" }));
  }
});

test("users への書き込みは許可フィールド・型のみ", async () => {
  const alice = env.authenticatedContext("alice").firestore();
  const mallory = env.authenticatedContext("mallory").firestore();
  await assertSucceeds(setDoc(doc(alice, "users/alice"),
    { displayName: "A2", shareVisited: false, updatedAt: Timestamp.now() }, { merge: true }));
  await assertFails(setDoc(doc(alice, "users/alice"), { isAdmin: true }, { merge: true }));
  await assertFails(setDoc(doc(alice, "users/alice"), { shareVisited: "yes" }, { merge: true }));
  await assertFails(setDoc(doc(alice, "users/alice"), { displayName: "x".repeat(51) }, { merge: true }));
  await assertFails(setDoc(doc(mallory, "users/alice"), { displayName: "hacked" }, { merge: true }));
});

test("旧 fcmToken の削除は許可される", async () => {
  await env.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), "users/alice"), { displayName: "A", fcmToken: "old" });
  });
  const alice = env.authenticatedContext("alice").firestore();
  const { deleteField } = require("firebase/firestore");
  await assertSucceeds(setDoc(doc(alice, "users/alice"), { fcmToken: deleteField() }, { merge: true }));
});
