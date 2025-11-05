/**
 * Appwrite Service
 * Handles all Appwrite client operations
 */

import { Client, Account, Databases, Storage, Query } from 'appwrite';
import { AppwriteConfig } from '../config/appwrite';

class AppwriteService {
  private client: Client;
  public account: Account;
  public databases: Databases;
  public storage: Storage;

  constructor() {
    this.client = new Client()
      .setEndpoint(AppwriteConfig.endpoint)
      .setProject(AppwriteConfig.projectId);

    this.account = new Account(this.client);
    this.databases = new Databases(this.client);
    this.storage = new Storage(this.client);
  }

  /**
   * Get the current authenticated user
   */
  async getCurrentUser() {
    try {
      return await this.account.get();
    } catch (error) {
      console.error('Error getting current user:', error);
      throw error;
    }
  }

  /**
   * Sign in with email and password
   */
  async signIn(email: string, password: string) {
    try {
      return await this.account.createEmailPasswordSession(email, password);
    } catch (error) {
      console.error('Error signing in:', error);
      throw error;
    }
  }

  /**
   * Sign out
   */
  async signOut() {
    try {
      await this.account.deleteSession('current');
    } catch (error) {
      console.error('Error signing out:', error);
      throw error;
    }
  }

  /**
   * Check if user is authenticated
   */
  async isAuthenticated(): Promise<boolean> {
    try {
      await this.account.get();
      return true;
    } catch {
      return false;
    }
  }
}

// Export singleton instance
export const appwriteService = new AppwriteService();
export { Query };
