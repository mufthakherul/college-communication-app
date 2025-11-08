/**
 * Downloads configuration
 *
 * Central place to configure app release fileIds or direct URLs.
 * Replace the placeholder file IDs with the actual Appwrite storage file IDs after
 * uploading the APK/AAB to the Appwrite `releases` bucket (see RELEASE_UPLOAD.md).
 */

export const DownloadConfig = {
  // If you're using Appwrite storage, set these file IDs (string) for each role.
  // Leave empty ("" or undefined) to fall back to a direct URL or placeholder.
  studentFileId: '',
  teacherFileId: '',
  adminFileId: '',

  // Optional: if you prefer using direct HTTPS links (S3, GitHub Releases, etc.),
  // put them here and they will be used if fileId is not set for a role.
  studentDirectUrl: '',
  teacherDirectUrl: '',
  adminDirectUrl: '',
} as const;

export type DownloadRole = 'student' | 'teacher' | 'admin';
