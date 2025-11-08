# Release upload and canonical download URL

This document describes the recommended flow to publish Android APK/AAB releases and wire them into the web frontend as a single canonical download URL.

Overview

- Upload your APK/AAB to the Appwrite `releases` bucket (or any storage service you prefer).
- Copy the file ID (Appwrite) or the direct HTTPS URL (S3/GCS/GH Releases).
- Add the file ID or URL to `apps/web/src/config/downloads.ts` (studentFileId / teacherFileId / adminFileId or direct URLs).
- The web Downloads page will automatically use the configured Appwrite file IDs (preferred) to generate download links.

Using Appwrite (recommended for this project)

1. Create a `releases` bucket in your Appwrite project (console > Storage > Buckets).
2. Ensure the bucket permissions allow read for the intended audience. For public downloads, set appropriate file-level permissions.
3. Upload the APK/AAB via Appwrite Console or using the Appwrite SDK.

Example: upload using Appwrite JS SDK (node script)

```js
import fs from "fs";
import { Client, Storage } from "node-appwrite";

const client = new Client()
  .setEndpoint(process.env.APPWRITE_ENDPOINT)
  .setProject(process.env.APPWRITE_PROJECT)
  .setKey(process.env.APPWRITE_API_KEY);

const storage = new Storage(client);

async function uploadRelease(filePath) {
  const file = fs.createReadStream(filePath);
  const response = await storage.createFile("releases", undefined, file);
  console.log("uploaded file id", response.$id);
}

uploadRelease("./app-release.apk");
```

4. Copy the returned `$id` and place it in `apps/web/src/config/downloads.ts` for the appropriate role.

Example `apps/web/src/config/downloads.ts`

```ts
export const DownloadConfig = {
  studentFileId: "abc123-file-id",
  teacherFileId: "def456-file-id",
  adminFileId: "ghi789-file-id",
  studentDirectUrl: "",
  teacherDirectUrl: "",
  adminDirectUrl: "",
};
```

Alternative: Use direct HTTPS link (GitHub Releases / S3 / GCS)

- Instead of file IDs, set the `studentDirectUrl` / `teacherDirectUrl` / `adminDirectUrl` fields to the public HTTPS URL of the artifact.

Notes

- CI: we recommend building release APK/AAB in CI (GitHub Actions) and uploading artifacts to Appwrite or cloud storage as part of the release pipeline.
- Security: make sure downloads served from the bucket are appropriately permissioned; public buckets are easiest but ensure you trust the content and that download URLs are not used to exfiltrate sensitive files.

If you want, I can also add a tiny GitHub Actions snippet to build and upload the artifact to Appwrite.
