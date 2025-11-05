/**
 * Storage Service
 * Handles file upload and management
 */

import { appwriteService } from './appwrite.service';
import { AppwriteConfig } from '../config/appwrite';
import { ID } from 'appwrite';

class StorageService {
  /**
   * Upload a file to Appwrite storage
   */
  async uploadFile(
    bucketId: string,
    file: File,
    onProgress?: (progress: number) => void
  ): Promise<string> {
    try {
      const fileId = ID.unique();

      const response = await appwriteService.storage.createFile(
        bucketId,
        fileId,
        file,
        undefined,
        onProgress
          ? (uploadProgress) => {
              // Convert UploadProgress to percentage
              const percentage =
                (uploadProgress.$id ? 100 : (uploadProgress.chunksUploaded / uploadProgress.chunksTotal) * 100) || 0;
              onProgress(percentage);
            }
          : undefined
      );

      return response.$id;
    } catch (error) {
      console.error('Error uploading file:', error);
      throw error;
    }
  }

  /**
   * Delete a file from Appwrite storage
   */
  async deleteFile(bucketId: string, fileId: string): Promise<void> {
    try {
      await appwriteService.storage.deleteFile(bucketId, fileId);
    } catch (error) {
      console.error('Error deleting file:', error);
      throw error;
    }
  }

  /**
   * Get file preview URL
   */
  getFilePreview(
    bucketId: string,
    fileId: string,
    width?: number,
    height?: number
  ): string {
    return appwriteService.storage.getFilePreview(
      bucketId,
      fileId,
      width,
      height
    ).toString();
  }

  /**
   * Get file download URL
   */
  getFileDownload(bucketId: string, fileId: string): string {
    return appwriteService.storage.getFileDownload(bucketId, fileId).toString();
  }

  /**
   * Get file view URL
   */
  getFileView(bucketId: string, fileId: string): string {
    return appwriteService.storage.getFileView(bucketId, fileId).toString();
  }

  /**
   * Upload notice attachment
   */
  async uploadNoticeAttachment(
    file: File,
    onProgress?: (progress: number) => void
  ): Promise<string> {
    return this.uploadFile(
      AppwriteConfig.buckets.noticeAttachments,
      file,
      onProgress
    );
  }

  /**
   * Delete notice attachment
   */
  async deleteNoticeAttachment(fileId: string): Promise<void> {
    return this.deleteFile(AppwriteConfig.buckets.noticeAttachments, fileId);
  }

  /**
   * Get notice attachment URL
   */
  getNoticeAttachmentUrl(fileId: string): string {
    return this.getFileView(AppwriteConfig.buckets.noticeAttachments, fileId);
  }
}

export const storageService = new StorageService();
