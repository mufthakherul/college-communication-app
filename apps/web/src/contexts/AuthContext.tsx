/**
 * Authentication Context
 * Manages authentication state across the application
 */

import React, { createContext, useContext, useState, useEffect } from 'react';
import { appwriteService } from '../services/appwrite.service';
import { User, UserRole } from '../types';
import { userService } from '../services/user.service';

interface AuthContextType {
  currentUser: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  signIn: (email: string, password: string) => Promise<void>;
  signOut: () => Promise<void>;
  checkAuth: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => {
  const [currentUser, setCurrentUser] = useState<User | null>(null);
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [isLoading, setIsLoading] = useState(true);

  const checkAuth = async () => {
    try {
      const authUser = await appwriteService.getCurrentUser();
      // Fetch user profile from database using efficient query
      const userProfile = await userService.getUserByAuthId(authUser.$id);

      if (
        userProfile &&
        (userProfile.role === UserRole.TEACHER ||
          userProfile.role === UserRole.ADMIN)
      ) {
        setCurrentUser(userProfile);
        setIsAuthenticated(true);
      } else {
        // User is not a teacher or admin
        await appwriteService.signOut();
        setCurrentUser(null);
        setIsAuthenticated(false);
      }
    } catch (error) {
      setCurrentUser(null);
      setIsAuthenticated(false);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    checkAuth();
  }, []);

  const signIn = async (email: string, password: string) => {
    try {
      await appwriteService.signIn(email, password);
      await checkAuth();
    } catch (error) {
      console.error('Sign in error:', error);
      throw error;
    }
  };

  const signOut = async () => {
    try {
      await appwriteService.signOut();
      setCurrentUser(null);
      setIsAuthenticated(false);
    } catch (error) {
      console.error('Sign out error:', error);
      throw error;
    }
  };

  const value = {
    currentUser,
    isAuthenticated,
    isLoading,
    signIn,
    signOut,
    checkAuth,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};
