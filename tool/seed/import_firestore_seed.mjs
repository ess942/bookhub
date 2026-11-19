import { readFile } from 'node:fs/promises';
import { applicationDefault, initializeApp } from 'firebase-admin/app';
import { getFirestore, Timestamp } from 'firebase-admin/firestore';

const projectId = process.env.FIREBASE_PROJECT_ID;
if (!projectId) {
  throw new Error('Set FIREBASE_PROJECT_ID to the target Firebase project.');
}

const seedUrl = new URL('./catalog_seed.json', import.meta.url);
const seed = JSON.parse(await readFile(seedUrl, 'utf8'));
if (!Array.isArray(seed.categories) || !Array.isArray(seed.books)) {
  throw new Error('Seed JSON must contain categories and books arrays.');
}

const app = initializeApp({
  credential: applicationDefault(),
  projectId,
});
const firestore = getFirestore(app);
const batch = firestore.batch();

for (const category of seed.categories) {
  const { id, ...data } = category;
  batch.set(firestore.collection('categories').doc(id), data);
}

for (const book of seed.books) {
  const { id, createdAt, ...data } = book;
  batch.set(firestore.collection('books').doc(id), {
    ...data,
    createdAt: Timestamp.fromDate(new Date(createdAt)),
  });
}

await batch.commit();
console.log(
  `Imported ${seed.categories.length} categories and ${seed.books.length} books into ${projectId}.`,
);
