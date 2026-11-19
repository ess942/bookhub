# Import the sample catalog

The seed contains five categories and fifteen books. It writes documents to
`categories/{id}` and `books/{id}` and converts each book's ISO `createdAt`
value into a Firestore timestamp.

1. Select the Firebase project and sign in with Google Application Default
   Credentials. The selected identity needs permission to write Firestore:

   ```powershell
   gcloud auth application-default login
   ```

2. From this directory install the Admin SDK dependency and run the importer:

   ```powershell
   npm install
   $env:FIREBASE_PROJECT_ID = "your-firebase-project-id"
   npm run seed
   ```

The script uses Application Default Credentials and contains no credentials.
It overwrites documents with the same sample IDs. Deploy the catalog search
composite index from the repository root with `firebase deploy --only
firestore:indexes`.
