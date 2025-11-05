/**
 * Message Service
 * Handles message-related operations
 */

import { appwriteService, Query } from './appwrite.service';
import { AppwriteConfig } from '../config/appwrite';
import { Message } from '../types';

class MessageService {
  /**
   * Get all messages with optional filtering
   */
  async getMessages(filters?: {
    senderId?: string;
    receiverId?: string;
    limit?: number;
  }): Promise<Message[]> {
    try {
      const queries: string[] = [Query.orderDesc('timestamp')];

      if (filters?.senderId) {
        queries.push(Query.equal('senderId', filters.senderId));
      }
      if (filters?.receiverId) {
        queries.push(Query.equal('receiverId', filters.receiverId));
      }
      if (filters?.limit) {
        queries.push(Query.limit(filters.limit));
      }

      const response = await appwriteService.databases.listDocuments(
        AppwriteConfig.databaseId,
        AppwriteConfig.collections.messages,
        queries
      );

      return response.documents as unknown as Message[];
    } catch (error) {
      console.error('Error fetching messages:', error);
      throw error;
    }
  }

  /**
   * Get message statistics
   */
  async getMessageStats() {
    try {
      const allMessages = await this.getMessages({ limit: 1000 });
      const readMessages = allMessages.filter((m) => m.isRead);

      return {
        total: allMessages.length,
        read: readMessages.length,
        unread: allMessages.length - readMessages.length,
      };
    } catch (error) {
      console.error('Error fetching message stats:', error);
      throw error;
    }
  }
}

export const messageService = new MessageService();
