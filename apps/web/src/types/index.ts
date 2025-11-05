/**
 * Type definitions for the Teacher Dashboard
 */

export enum UserRole {
  STUDENT = 'student',
  TEACHER = 'teacher',
  ADMIN = 'admin',
}

export interface User {
  $id: string;
  userId: string;
  email: string;
  name: string;
  role: UserRole;
  department?: string;
  enrollmentYear?: number;
  phone?: string;
  profileImageUrl?: string;
  isActive?: boolean;
  createdAt?: string;
  updatedAt?: string;
}

export interface Notice {
  $id: string;
  title: string;
  content: string;
  authorId: string;
  authorName: string;
  department?: string;
  priority: 'high' | 'medium' | 'low';
  createdAt: string;
  expiresAt?: string;
  attachments?: string[];
  isActive: boolean;
}

export interface Message {
  $id: string;
  senderId: string;
  receiverId: string;
  message: string;
  timestamp: string;
  isRead: boolean;
  attachments?: string[];
}

export interface DashboardStats {
  totalUsers: number;
  totalStudents: number;
  totalTeachers: number;
  totalNotices: number;
  totalMessages: number;
  activeNotices: number;
}

export interface UserActivity {
  $id: string;
  userId: string;
  action: string;
  details?: string;
  timestamp: string;
}
