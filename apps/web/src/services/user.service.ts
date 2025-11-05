/**
 * User Service
 * Handles user-related operations
 */

import { appwriteService, Query } from './appwrite.service';
import { AppwriteConfig } from '../config/appwrite';
import { User, UserRole } from '../types';
import { ID } from 'appwrite';

class UserService {
  /**
   * Get all users with optional filtering
   */
  async getUsers(filters?: {
    role?: UserRole;
    department?: string;
    limit?: number;
  }): Promise<User[]> {
    try {
      const queries: string[] = [];

      if (filters?.role) {
        queries.push(Query.equal('role', filters.role));
      }
      if (filters?.department) {
        queries.push(Query.equal('department', filters.department));
      }
      if (filters?.limit) {
        queries.push(Query.limit(filters.limit));
      }

      const response = await appwriteService.databases.listDocuments(
        AppwriteConfig.databaseId,
        AppwriteConfig.collections.users,
        queries
      );

      return response.documents as unknown as User[];
    } catch (error) {
      console.error('Error fetching users:', error);
      throw error;
    }
  }

  /**
   * Get a single user by ID
   */
  async getUser(userId: string): Promise<User> {
    try {
      const response = await appwriteService.databases.getDocument(
        AppwriteConfig.databaseId,
        AppwriteConfig.collections.users,
        userId
      );

      return response as unknown as User;
    } catch (error) {
      console.error('Error fetching user:', error);
      throw error;
    }
  }

  /**
   * Get user by auth ID (userId field)
   */
  async getUserByAuthId(authId: string): Promise<User | null> {
    try {
      const response = await appwriteService.databases.listDocuments(
        AppwriteConfig.databaseId,
        AppwriteConfig.collections.users,
        [Query.equal('userId', authId), Query.limit(1)]
      );

      if (response.documents.length > 0) {
        return response.documents[0] as unknown as User;
      }
      return null;
    } catch (error) {
      console.error('Error fetching user by auth ID:', error);
      throw error;
    }
  }

  /**
   * Create a new user
   */
  async createUser(userData: Omit<User, '$id'>): Promise<User> {
    try {
      const response = await appwriteService.databases.createDocument(
        AppwriteConfig.databaseId,
        AppwriteConfig.collections.users,
        ID.unique(),
        userData
      );

      return response as unknown as User;
    } catch (error) {
      console.error('Error creating user:', error);
      throw error;
    }
  }

  /**
   * Update user information
   */
  async updateUser(userId: string, updates: Partial<User>): Promise<User> {
    try {
      const response = await appwriteService.databases.updateDocument(
        AppwriteConfig.databaseId,
        AppwriteConfig.collections.users,
        userId,
        updates
      );

      return response as unknown as User;
    } catch (error) {
      console.error('Error updating user:', error);
      throw error;
    }
  }

  /**
   * Delete a user
   */
  async deleteUser(userId: string): Promise<void> {
    try {
      await appwriteService.databases.deleteDocument(
        AppwriteConfig.databaseId,
        AppwriteConfig.collections.users,
        userId
      );
    } catch (error) {
      console.error('Error deleting user:', error);
      throw error;
    }
  }

  /**
   * Get user statistics
   */
  async getUserStats() {
    try {
      const allUsers = await this.getUsers();
      const students = allUsers.filter((u) => u.role === UserRole.STUDENT);
      const teachers = allUsers.filter((u) => u.role === UserRole.TEACHER);
      const admins = allUsers.filter((u) => u.role === UserRole.ADMIN);

      return {
        total: allUsers.length,
        students: students.length,
        teachers: teachers.length,
        admins: admins.length,
        active: allUsers.filter((u) => u.isActive).length,
      };
    } catch (error) {
      console.error('Error fetching user stats:', error);
      throw error;
    }
  }
}

export const userService = new UserService();
