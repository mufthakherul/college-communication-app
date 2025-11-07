/**
 * Teacher Service
 * Handles teacher-related operations for dedicated teachers collection
 */

import { appwriteService, Query } from './appwrite.service';
import { AppwriteConfig } from '../config/appwrite';
import { ID } from 'appwrite';

export interface Teacher {
  $id: string;
  user_id: string;
  email: string;
  full_name: string;
  employee_id?: string;
  department: string;
  designation?: string;
  subjects?: string[];
  qualification?: string;
  specialization?: string;
  phone_number?: string;
  office_room?: string;
  office_hours?: string;
  joining_date?: string;
  photo_url?: string;
  bio?: string;
  is_active: boolean;
  created_at?: string;
  updated_at?: string;
}

export interface TeacherFormData {
  user_id: string;
  email: string;
  full_name: string;
  employee_id?: string;
  department: string;
  designation?: string;
  subjects?: string[];
  qualification?: string;
  specialization?: string;
  phone_number?: string;
  office_room?: string;
  office_hours?: string;
  joining_date?: string;
  photo_url?: string;
  bio?: string;
  is_active?: boolean;
}

class TeacherService {
  private readonly collectionId = 'teachers';

  /**
   * Get all teachers with optional filtering
   */
  async getTeachers(filters?: {
    department?: string;
    is_active?: boolean;
    limit?: number;
  }): Promise<Teacher[]> {
    try {
      const queries: string[] = [];

      if (filters?.department) {
        queries.push(Query.equal('department', filters.department));
      }
      if (filters?.is_active !== undefined) {
        queries.push(Query.equal('is_active', filters.is_active));
      }
      if (filters?.limit) {
        queries.push(Query.limit(filters.limit));
      }

      const response = await appwriteService.databases.listDocuments(
        AppwriteConfig.databaseId,
        this.collectionId,
        queries
      );

      return response.documents as unknown as Teacher[];
    } catch (error) {
      console.error('Error fetching teachers:', error);
      throw error;
    }
  }

  /**
   * Get a single teacher by ID
   */
  async getTeacher(teacherId: string): Promise<Teacher> {
    try {
      const response = await appwriteService.databases.getDocument(
        AppwriteConfig.databaseId,
        this.collectionId,
        teacherId
      );

      return response as unknown as Teacher;
    } catch (error) {
      console.error('Error fetching teacher:', error);
      throw error;
    }
  }

  /**
   * Get teacher by user auth ID
   */
  async getTeacherByUserId(userId: string): Promise<Teacher | null> {
    try {
      const response = await appwriteService.databases.listDocuments(
        AppwriteConfig.databaseId,
        this.collectionId,
        [Query.equal('user_id', userId), Query.limit(1)]
      );

      if (response.documents.length > 0) {
        return response.documents[0] as unknown as Teacher;
      }
      return null;
    } catch (error) {
      console.error('Error fetching teacher by user ID:', error);
      throw error;
    }
  }

  /**
   * Get teacher by email
   */
  async getTeacherByEmail(email: string): Promise<Teacher | null> {
    try {
      const response = await appwriteService.databases.listDocuments(
        AppwriteConfig.databaseId,
        this.collectionId,
        [Query.equal('email', email), Query.limit(1)]
      );

      if (response.documents.length > 0) {
        return response.documents[0] as unknown as Teacher;
      }
      return null;
    } catch (error) {
      console.error('Error fetching teacher by email:', error);
      throw error;
    }
  }

  /**
   * Get teachers by department
   */
  async getTeachersByDepartment(department: string): Promise<Teacher[]> {
    return this.getTeachers({ department, is_active: true });
  }

  /**
   * Search teachers by name, email, or employee ID
   */
  async searchTeachers(searchTerm: string): Promise<Teacher[]> {
    try {
      const allTeachers = await this.getTeachers({ is_active: true });
      
      const term = searchTerm.toLowerCase();
      return allTeachers.filter(teacher =>
        teacher.full_name.toLowerCase().includes(term) ||
        teacher.email.toLowerCase().includes(term) ||
        teacher.employee_id?.toLowerCase().includes(term) ||
        teacher.department.toLowerCase().includes(term)
      );
    } catch (error) {
      console.error('Error searching teachers:', error);
      throw error;
    }
  }

  /**
   * Create a new teacher
   */
  async createTeacher(teacherData: TeacherFormData): Promise<Teacher> {
    try {
      // Check if teacher with this email already exists
      const existing = await this.getTeacherByEmail(teacherData.email);
      if (existing) {
        throw new Error('A teacher with this email already exists');
      }

      const data = {
        ...teacherData,
        is_active: teacherData.is_active !== undefined ? teacherData.is_active : true,
        created_at: new Date().toISOString(),
      };

      const response = await appwriteService.databases.createDocument(
        AppwriteConfig.databaseId,
        this.collectionId,
        ID.unique(),
        data
      );

      return response as unknown as Teacher;
    } catch (error) {
      console.error('Error creating teacher:', error);
      throw error;
    }
  }

  /**
   * Update teacher information
   */
  async updateTeacher(teacherId: string, updates: Partial<TeacherFormData>): Promise<Teacher> {
    try {
      const data = {
        ...updates,
        updated_at: new Date().toISOString(),
      };

      const response = await appwriteService.databases.updateDocument(
        AppwriteConfig.databaseId,
        this.collectionId,
        teacherId,
        data
      );

      return response as unknown as Teacher;
    } catch (error) {
      console.error('Error updating teacher:', error);
      throw error;
    }
  }

  /**
   * Toggle teacher active status
   */
  async toggleTeacherStatus(teacherId: string): Promise<Teacher> {
    try {
      const teacher = await this.getTeacher(teacherId);
      return this.updateTeacher(teacherId, { is_active: !teacher.is_active });
    } catch (error) {
      console.error('Error toggling teacher status:', error);
      throw error;
    }
  }

  /**
   * Delete a teacher
   */
  async deleteTeacher(teacherId: string): Promise<void> {
    try {
      await appwriteService.databases.deleteDocument(
        AppwriteConfig.databaseId,
        this.collectionId,
        teacherId
      );
    } catch (error) {
      console.error('Error deleting teacher:', error);
      throw error;
    }
  }

  /**
   * Get teacher statistics
   */
  async getTeacherStats() {
    try {
      const allTeachers = await this.getTeachers();
      
      // Count by department
      const byDepartment: Record<string, number> = {};
      allTeachers.forEach(teacher => {
        byDepartment[teacher.department] = (byDepartment[teacher.department] || 0) + 1;
      });

      // Count by designation
      const byDesignation: Record<string, number> = {};
      allTeachers.forEach(teacher => {
        if (teacher.designation) {
          byDesignation[teacher.designation] = (byDesignation[teacher.designation] || 0) + 1;
        }
      });

      return {
        total: allTeachers.length,
        active: allTeachers.filter(t => t.is_active).length,
        inactive: allTeachers.filter(t => !t.is_active).length,
        byDepartment,
        byDesignation,
      };
    } catch (error) {
      console.error('Error fetching teacher stats:', error);
      throw error;
    }
  }

  /**
   * Get all departments (unique values)
   */
  async getDepartments(): Promise<string[]> {
    try {
      const teachers = await this.getTeachers();
      const departments = new Set(teachers.map(t => t.department));
      return Array.from(departments).sort();
    } catch (error) {
      console.error('Error fetching departments:', error);
      throw error;
    }
  }

  /**
   * Get all subjects taught (unique values)
   */
  async getAllSubjects(): Promise<string[]> {
    try {
      const teachers = await this.getTeachers();
      const subjectsSet = new Set<string>();
      
      teachers.forEach(teacher => {
        if (teacher.subjects) {
          teacher.subjects.forEach(subject => subjectsSet.add(subject));
        }
      });
      
      return Array.from(subjectsSet).sort();
    } catch (error) {
      console.error('Error fetching subjects:', error);
      throw error;
    }
  }

  /**
   * Get teachers teaching a specific subject
   */
  async getTeachersBySubject(subject: string): Promise<Teacher[]> {
    try {
      const allTeachers = await this.getTeachers({ is_active: true });
      return allTeachers.filter(teacher => 
        teacher.subjects?.includes(subject)
      );
    } catch (error) {
      console.error('Error fetching teachers by subject:', error);
      throw error;
    }
  }
}

export const teacherService = new TeacherService();
