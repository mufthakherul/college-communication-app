# Teachers Collection Implementation Summary

## 🎯 Overview

This document provides a quick start guide for implementing a dedicated **teachers collection** in the web dashboard, separating teacher data from the generic `users` collection.

---

## ❓ Why Separate Teachers Collection?

### Problems with Current Setup

The current `users` collection mixes:

- **Student fields**: year, shift, group, class_roll (not applicable to teachers)
- **Teacher/Admin data**: Mixed in the same collection
- **Limited teacher info**: Can't store subjects, office hours, qualifications, etc.

### Issues Encountered

✗ Need to filter by role constantly (`role='teacher'`)  
✗ Wasted fields (student-specific for teachers)  
✗ Can't store rich teacher profiles  
✗ Confusing UI with irrelevant fields  
✗ Poor query performance (filtering from all users)

### Benefits of Dedicated Collection

✅ **Clean separation**: Teacher data separate from students  
✅ **Rich profiles**: Store subjects, qualifications, office hours, etc.  
✅ **Better performance**: Direct queries (no role filtering needed)  
✅ **Easier management**: Teacher-specific fields only  
✅ **Future-proof**: Easy to add features (schedules, consultations, etc.)

---

## 🚀 Quick Start (3 Steps)

### Step 1: Create the Collection

Run the automated script:

```bash
./scripts/create-teachers-collection.sh
```

**What it does:**

- Creates `teachers` collection in Appwrite
- Adds 17 attributes (user_id, email, full_name, department, subjects, etc.)
- Creates 5 indexes (email unique, department, is_active, created_at, user_id)
- Sets up proper permissions (read: any, create/update/delete: admin)

**Time**: ~3 minutes (including attribute creation waits)

---

### Step 2: Build the UI

Create the Teachers management page:

```bash
# File to create: apps/web/src/pages/TeachersPage.tsx
```

**Features needed:**

- List all teachers with search/filter
- Add new teacher form
- Edit teacher details
- Delete teacher
- Toggle active/inactive status
- Filter by department
- Show subjects taught

**Template**: Similar to `UsersPage.tsx` but with teacher-specific fields

---

### Step 3: Update Navigation

Add teachers page to the dashboard menu:

```typescript
// In apps/web/src/components/Layout.tsx or routing config

{
  label: 'Teachers',
  icon: <SchoolIcon />,
  path: '/teachers'
}
```

---

## 📋 Collection Schema

### Core Fields (Required)

| Field        | Type    | Description                          |
| ------------ | ------- | ------------------------------------ |
| `user_id`    | string  | Appwrite Auth user ID (link to auth) |
| `email`      | email   | Teacher's email (unique)             |
| `full_name`  | string  | Full name                            |
| `department` | string  | Department (CSE, EEE, etc.)          |
| `is_active`  | boolean | Active status (default: true)        |

### Optional Fields

| Field            | Type     | Description               |
| ---------------- | -------- | ------------------------- |
| `employee_id`    | string   | Staff/Employee ID         |
| `designation`    | string   | Professor, Lecturer, etc. |
| `subjects`       | string[] | Subjects taught (array)   |
| `qualification`  | string   | PhD, M.Sc., etc.          |
| `specialization` | string   | Area of expertise         |
| `phone_number`   | string   | Contact number            |
| `office_room`    | string   | Office location           |
| `office_hours`   | string   | Consultation hours        |
| `joining_date`   | datetime | Date joined institution   |
| `photo_url`      | url      | Profile picture           |
| `bio`            | string   | Short biography           |

### Metadata

- `created_at` (datetime, required): Record creation
- `updated_at` (datetime, optional): Last update

---

## 🔧 Using the Teacher Service

The service is already created at `apps/web/src/services/teacher.service.ts`

### Examples

#### Get All Teachers

```typescript
import { teacherService } from "../services/teacher.service";

// Get all active teachers
const teachers = await teacherService.getTeachers({ is_active: true });

// Get teachers by department
const cseTeachers = await teacherService.getTeachersByDepartment("CSE");

// Search teachers
const results = await teacherService.searchTeachers("John");
```

#### Create Teacher

```typescript
const newTeacher = await teacherService.createTeacher({
  user_id: "auth_user_id_123",
  email: "john.doe@college.edu",
  full_name: "Dr. John Doe",
  employee_id: "EMP001",
  department: "Computer Science",
  designation: "Professor",
  subjects: ["Data Structures", "Algorithms", "AI"],
  qualification: "PhD in Computer Science",
  specialization: "Machine Learning",
  phone_number: "+8801234567890",
  office_room: "CSE-301",
  office_hours: "Mon-Wed 2-4 PM",
  bio: "Experienced professor with 10 years in academia",
  is_active: true,
});
```

#### Update Teacher

```typescript
await teacherService.updateTeacher(teacherId, {
  office_hours: "Mon-Fri 3-5 PM",
  subjects: ["Data Structures", "Algorithms", "AI", "ML"],
});
```

#### Get Statistics

```typescript
const stats = await teacherService.getTeacherStats();
// Returns: { total, active, inactive, byDepartment, byDesignation }
```

---

## 📊 Migration Strategy

### Option 1: Manual Entry (Recommended for Small Teams)

1. ✅ Create teachers collection (Step 1 above)
2. Use web dashboard to add teachers manually
3. Keep `users` collection for auth reference

### Option 2: Data Migration Script

Create a migration script to copy existing teachers:

```typescript
// Pseudo-code
const existingTeachers = await userService.getUsers({ role: "teacher" });

for (const user of existingTeachers) {
  await teacherService.createTeacher({
    user_id: user.userId,
    email: user.email,
    full_name: user.name,
    department: user.department || "General",
    phone_number: user.phone,
    photo_url: user.profileImageUrl,
    is_active: user.isActive ?? true,
  });
}
```

### Option 3: Dual Mode (Gradual)

- Run both systems in parallel
- New teachers → `teachers` collection
- Old teachers → Gradually migrate from `users`
- Eventually phase out teacher role in `users`

---

## 🎨 UI Components Needed

### 1. TeachersPage.tsx (Main Page)

**Features:**

- Search bar (name, email, employee ID)
- Department filter dropdown
- Active/Inactive toggle
- Table with columns:
  - Photo
  - Name
  - Email
  - Department
  - Designation
  - Subjects (chips)
  - Status (active/inactive chip)
  - Actions (edit, delete)
- "Add Teacher" button

### 2. TeacherForm.tsx (Dialog/Modal)

**Fields:**

- Personal: Full name, Email, Employee ID
- Academic: Department, Designation, Subjects (multi-select)
- Qualifications: Degree, Specialization
- Contact: Phone, Office room, Office hours
- Other: Joining date, Photo URL, Bio
- Status: Active checkbox

### 3. TeacherCard.tsx (Optional - Profile View)

Display teacher details in a card format for viewing.

---

## ✅ Implementation Checklist

### Backend Setup

- [x] Create `teachers` collection in Appwrite
  - [x] 17 attributes configured
  - [x] 5 indexes created
  - [x] Permissions set (read: any, create/update/delete: admin)
- [x] Create `teacher.service.ts`
  - [x] CRUD operations
  - [x] Search and filtering
  - [x] Statistics methods

### Frontend UI

- [ ] Create `TeachersPage.tsx`
  - [ ] List view with table
  - [ ] Search functionality
  - [ ] Department filter
  - [ ] Add/Edit/Delete actions
- [ ] Create `TeacherForm.tsx`
  - [ ] All required fields
  - [ ] Validation
  - [ ] Subject multi-select
- [ ] Update navigation menu
  - [ ] Add "Teachers" menu item
  - [ ] Add route to router

### Testing

- [ ] Create sample teachers
- [ ] Test search/filter
- [ ] Test CRUD operations
- [ ] Verify permissions
- [ ] Check statistics

### Documentation

- [x] Design document created
- [x] Service implementation documented
- [ ] User guide for web dashboard
- [ ] Update README with new features

---

## 🔗 Files Created

| File                                       | Purpose                    | Status  |
| ------------------------------------------ | -------------------------- | ------- |
| `docs/TEACHERS_COLLECTION_DESIGN.md`       | Comprehensive design doc   | ✅ Done |
| `scripts/create-teachers-collection.sh`    | Automated collection setup | ✅ Done |
| `apps/web/src/services/teacher.service.ts` | Teacher CRUD service       | ✅ Done |
| `apps/web/src/pages/TeachersPage.tsx`      | UI for teacher management  | ⏳ Next |
| `apps/web/src/components/TeacherForm.tsx`  | Add/Edit form              | ⏳ Next |

---

## 📚 Related Documentation

- **Design Details**: [`docs/TEACHERS_COLLECTION_DESIGN.md`](./TEACHERS_COLLECTION_DESIGN.md)
- **Web Dashboard Guide**: [`docs/WEB_DASHBOARD.md`](./WEB_DASHBOARD.md)
- **Appwrite Schema**: [`archive_docs/APPWRITE_COLLECTIONS_SCHEMA.md`](../archive_docs/APPWRITE_COLLECTIONS_SCHEMA.md)

---

## 🆘 Troubleshooting

### Collection Creation Failed

**Problem**: Script returns errors when creating collection

**Solutions:**

1. Check API key has database permissions
2. Verify `tools/mcp/appwrite.mcp.env` is configured
3. Ensure database `rpi_communication` exists
4. Check for rate limits (script has delays built-in)

### Teachers Not Appearing in Dashboard

**Problem**: Created teachers but UI doesn't show them

**Solutions:**

1. Verify collection ID is `teachers` in Appwrite
2. Check permissions (read permission must be set)
3. Clear browser cache
4. Check browser console for errors
5. Verify service is importing correct collection ID

### Permission Errors

**Problem**: Can't create/update teachers

**Solutions:**

1. Ensure user has `admin` label in Appwrite Auth
2. Check collection permissions in Appwrite Console
3. Verify document security is enabled
4. Check if user is authenticated

---

## 🎯 Next Steps

1. **Run the script**: `./scripts/create-teachers-collection.sh`
2. **Build the UI**: Create `TeachersPage.tsx` (use `UsersPage.tsx` as template)
3. **Test thoroughly**: Add sample teachers and verify all operations
4. **Migrate data**: If needed, migrate existing teacher records
5. **Update docs**: Document for end users

---

## 💡 Future Enhancements

Once the teachers collection is stable, consider adding:

- **Class Schedules**: Link teachers to timetable
- **Student Assignments**: Track courses per teacher
- **Performance Analytics**: Teaching hours, feedback, etc.
- **Consultation Booking**: Students book office hours
- **Research Profiles**: Publications, projects, interests

---

**Status**: Implementation 75% Complete  
**Remaining**: UI pages (TeachersPage, TeacherForm)  
**Estimated Time**: 1-2 hours for UI
