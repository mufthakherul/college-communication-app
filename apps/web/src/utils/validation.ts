/**
 * Validation Utilities
 * Shared validation functions for forms
 */

/**
 * Email validation regex
 * Validates basic email format: username@domain.extension
 */
export const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

/**
 * Validate email address
 * @param email - Email address to validate
 * @returns true if valid, false otherwise
 */
export function isValidEmail(email: string): boolean {
  return EMAIL_REGEX.test(email);
}

/**
 * Validate required field
 * @param value - Field value to validate
 * @returns true if not empty, false otherwise
 */
export function isRequired(value: string): boolean {
  return value.trim().length > 0;
}

/**
 * Allowed file extensions for attachments
 */
export const ALLOWED_FILE_EXTENSIONS = [
  // Images
  '.jpg',
  '.jpeg',
  '.png',
  '.gif',
  '.webp',
  // Documents
  '.pdf',
  '.doc',
  '.docx',
  '.txt',
  // Spreadsheets (optional)
  '.xls',
  '.xlsx',
];

/**
 * Validate file type
 * @param fileName - Name of the file
 * @returns true if file type is allowed, false otherwise
 */
export function isValidFileType(fileName: string): boolean {
  const extension = fileName.toLowerCase().substring(fileName.lastIndexOf('.'));
  return ALLOWED_FILE_EXTENSIONS.includes(extension);
}

/**
 * Maximum file size in bytes (10MB)
 */
export const MAX_FILE_SIZE = 10 * 1024 * 1024;

/**
 * Validate file size
 * @param fileSize - Size of the file in bytes
 * @returns true if file size is within limit, false otherwise
 */
export function isValidFileSize(fileSize: number): boolean {
  return fileSize <= MAX_FILE_SIZE;
}
