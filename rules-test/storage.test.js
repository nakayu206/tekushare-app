const { test, before, after } = require("node:test");
const fs = require("node:fs");
const path = require("node:path");
const {
  initializeTestEnvironment, assertSucceeds, assertFails,
} = require("@firebase/rules-unit-testing");
const { doc, setDoc } = require("firebase/firestore");
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
    await setDoc(doc(ctx.firestore(), "accountLinks/alice_bob"), { uids: ["alice", "bob"] });
    await uploadBytes(ref(ctx.storage(), file), png, { contentType: "image/jpeg" });
  });
});
after(() => env.cleanup());

test("読み取りは本人と連携相手のみ", async () => {
  await assertSucceeds(getBytes(ref(env.authenticatedContext("alice").storage(), file)));
  await assertSucceeds(getBytes(ref(env.authenticatedContext("bob").storage(), file)));
  await assertFails(getBytes(ref(env.authenticatedContext("mallory").storage(), file)));
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
