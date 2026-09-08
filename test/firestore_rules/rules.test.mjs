import { readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  deleteDoc,
  doc,
  getDoc,
  serverTimestamp,
  setDoc,
  updateDoc,
} from 'firebase/firestore';

const __dirname = dirname(fileURLToPath(import.meta.url));
const rules = readFileSync(resolve(__dirname, '../../firestore.rules'), 'utf8');

const PROJECT_ID = 'mini-blog-app-3ff95';

const draftPayload = (authorId) => ({
  title: 'Titre',
  content: 'Contenu assez long',
  authorId,
  authorName: 'Alice',
  status: 'draft',
  createdAt: serverTimestamp(),
  updatedAt: serverTimestamp(),
  publishedAt: null,
});

let testEnv;

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: { rules, host: '127.0.0.1', port: 8080 },
  });
});

after(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
});

function authed(uid) {
  return testEnv.authenticatedContext(uid).firestore();
}

function guest() {
  return testEnv.unauthenticatedContext().firestore();
}

describe('Lecture', () => {
  it('un article publié est lisible sans auth', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'articles', 'pub-1'), {
        ...draftPayload('alice'),
        status: 'published',
        publishedAt: serverTimestamp(),
      });
    });

    await assertSucceeds(getDoc(doc(guest(), 'articles', 'pub-1')));
  });

  it('un brouillon est lisible par son auteur', async () => {
    await assertSucceeds(
      setDoc(doc(authed('alice'), 'articles', 'draft-1'), draftPayload('alice')),
    );
    await assertSucceeds(getDoc(doc(authed('alice'), 'articles', 'draft-1')));
  });

  it('un brouillon n\'est pas lisible par un autre utilisateur', async () => {
    await assertSucceeds(
      setDoc(doc(authed('alice'), 'articles', 'draft-1'), draftPayload('alice')),
    );
    await assertFails(getDoc(doc(authed('bob'), 'articles', 'draft-1')));
  });
});

describe('Création', () => {
  it('un utilisateur authentifié crée son propre article', async () => {
    await assertSucceeds(
      setDoc(doc(authed('alice'), 'articles', 'a1'), draftPayload('alice')),
    );
  });

  it('refuse un article avec le authorId d\'un autre utilisateur', async () => {
    await assertFails(
      setDoc(doc(authed('alice'), 'articles', 'a1'), draftPayload('bob')),
    );
  });

  it('un utilisateur non authentifié ne peut pas créer', async () => {
    await assertFails(
      setDoc(doc(guest(), 'articles', 'a1'), draftPayload('alice')),
    );
  });
});

describe('Modification', () => {
  beforeEach(async () => {
    await assertSucceeds(
      setDoc(doc(authed('alice'), 'articles', 'a1'), draftPayload('alice')),
    );
  });

  it('l\'auteur peut modifier son article', async () => {
    await assertSucceeds(
      updateDoc(doc(authed('alice'), 'articles', 'a1'), {
        title: 'Nouveau titre',
        updatedAt: serverTimestamp(),
      }),
    );
  });

  it('un autre utilisateur ne peut pas modifier l\'article', async () => {
    await assertFails(
      updateDoc(doc(authed('bob'), 'articles', 'a1'), {
        title: 'Hack',
        updatedAt: serverTimestamp(),
      }),
    );
  });

  it('refuse de changer authorId', async () => {
    await assertFails(
      updateDoc(doc(authed('alice'), 'articles', 'a1'), {
        authorId: 'bob',
        updatedAt: serverTimestamp(),
      }),
    );
  });
});

describe('Suppression', () => {
  beforeEach(async () => {
    await assertSucceeds(
      setDoc(doc(authed('alice'), 'articles', 'a1'), draftPayload('alice')),
    );
  });

  it('l\'auteur peut supprimer son article', async () => {
    await assertSucceeds(deleteDoc(doc(authed('alice'), 'articles', 'a1')));
  });

  it('un autre utilisateur ne peut pas supprimer', async () => {
    await assertFails(deleteDoc(doc(authed('bob'), 'articles', 'a1')));
  });
});

describe('Publication', () => {
  beforeEach(async () => {
    await assertSucceeds(
      setDoc(doc(authed('alice'), 'articles', 'a1'), draftPayload('alice')),
    );
  });

  it('l\'auteur peut publier son article', async () => {
    await assertSucceeds(
      updateDoc(doc(authed('alice'), 'articles', 'a1'), {
        status: 'published',
        publishedAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
      }),
    );
  });

  it('un autre utilisateur ne peut pas publier l\'article', async () => {
    await assertFails(
      updateDoc(doc(authed('bob'), 'articles', 'a1'), {
        status: 'published',
        publishedAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
      }),
    );
  });
});

describe('Commentaires', () => {
  const commentPayload = (authorId) => ({
    authorId,
    authorName: 'Bob',
    content: 'Super article',
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  });

  beforeEach(async () => {
    await assertSucceeds(
      setDoc(doc(authed('alice'), 'articles', 'pub-1'), {
        ...draftPayload('alice'),
        status: 'published',
        publishedAt: serverTimestamp(),
      }),
    );
  });

  it('un utilisateur connecté peut commenter un article publié', async () => {
    await assertSucceeds(
      setDoc(
        doc(authed('bob'), 'articles', 'pub-1', 'comments', 'c1'),
        commentPayload('bob'),
      ),
    );
  });

  it('refuse un commentaire avec le authorId d\'un autre', async () => {
    await assertFails(
      setDoc(
        doc(authed('bob'), 'articles', 'pub-1', 'comments', 'c1'),
        commentPayload('alice'),
      ),
    );
  });

  it('l\'auteur du commentaire peut le supprimer', async () => {
    await assertSucceeds(
      setDoc(
        doc(authed('bob'), 'articles', 'pub-1', 'comments', 'c1'),
        commentPayload('bob'),
      ),
    );
    await assertSucceeds(
      deleteDoc(doc(authed('bob'), 'articles', 'pub-1', 'comments', 'c1')),
    );
  });

  it('un autre utilisateur ne peut pas supprimer le commentaire', async () => {
    await assertSucceeds(
      setDoc(
        doc(authed('bob'), 'articles', 'pub-1', 'comments', 'c1'),
        commentPayload('bob'),
      ),
    );
    await assertFails(
      deleteDoc(doc(authed('alice'), 'articles', 'pub-1', 'comments', 'c1')),
    );
  });
});
