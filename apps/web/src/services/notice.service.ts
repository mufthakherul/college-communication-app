/**
 * Notice Service
 * Handles notice-related operations
 */

import { appwriteService, Query } from './appwrite.service';
import { AppwriteConfig } from '../config/appwrite';
import { Notice } from '../types';
import { ID } from 'appwrite';

class NoticeService {
  /**
   * Get all notices with optional filtering
   */
  async getNotices(filters?: {
    authorId?: string;
    department?: string;
    isActive?: boolean;
    limit?: number;
  }): Promise<Notice[]> {
    try {
      const queries: string[] = [Query.orderDesc('createdAt')];

      if (filters?.authorId) {
        queries.push(Query.equal('authorId', filters.authorId));
      }
      if (filters?.department) {
        queries.push(Query.equal('department', filters.department));
      }
      if (filters?.isActive !== undefined) {
        queries.push(Query.equal('isActive', filters.isActive));
      }
      if (filters?.limit) {
        queries.push(Query.limit(filters.limit));
      }

      const response = await appwriteService.databases.listDocuments(
        AppwriteConfig.databaseId,
        AppwriteConfig.collections.notices,
        queries
      );

      return response.documents as unknown as Notice[];
    } catch (error) {
      console.error('Error fetching notices:', error);
      throw error;
    }
  }

  /**
   * Get a single notice by ID
   */
  async getNotice(noticeId: string): Promise<Notice> {
    try {
      const response = await appwriteService.databases.getDocument(
        AppwriteConfig.databaseId,
        AppwriteConfig.collections.notices,
        noticeId
      );

      return response as unknown as Notice;
    } catch (error) {
      console.error('Error fetching notice:', error);
      throw error;
    }
  }

  /**
   * Create a new notice
   */
  async createNotice(noticeData: Omit<Notice, '$id'>): Promise<Notice> {
    try {
      // Set server timestamp for consistency across clients
      const noticeWithTimestamp = {
        ...noticeData,
        createdAt: new Date().toISOString(), // Server-side timestamp
        isActive: noticeData.isActive ?? true,
      };

      const response = await appwriteService.databases.createDocument(
        AppwriteConfig.databaseId,
        AppwriteConfig.collections.notices,
        ID.unique(),
        noticeWithTimestamp
      );

      return response as unknown as Notice;
    } catch (error) {
      console.error('Error creating notice:', error);
      throw error;
    }
  }

  /**
   * Update notice information
   */
  async updateNotice(
    noticeId: string,
    updates: Partial<Notice>
  ): Promise<Notice> {
    try {
      const response = await appwriteService.databases.updateDocument(
        AppwriteConfig.databaseId,
        AppwriteConfig.collections.notices,
        noticeId,
        updates
      );

      return response as unknown as Notice;
    } catch (error) {
      console.error('Error updating notice:', error);
      throw error;
    }
  }

  /**
   * Delete a notice
   */
  async deleteNotice(noticeId: string): Promise<void> {
    try {
      await appwriteService.databases.deleteDocument(
        AppwriteConfig.databaseId,
        AppwriteConfig.collections.notices,
        noticeId
      );
    } catch (error) {
      console.error('Error deleting notice:', error);
      throw error;
    }
  }

  /**
   * Get notice statistics
   */
  async getNoticeStats() {
    try {
      const allNotices = await this.getNotices();
      const activeNotices = allNotices.filter((n) => n.isActive);
      const highPriority = allNotices.filter((n) => n.priority === 'high');

      return {
        total: allNotices.length,
        active: activeNotices.length,
        inactive: allNotices.length - activeNotices.length,
        highPriority: highPriority.length,
      };
    } catch (error) {
      console.error('Error fetching notice stats:', error);
      throw error;
    }
  }
}

export const noticeService = new NoticeService();
