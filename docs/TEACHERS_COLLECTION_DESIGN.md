# Teachers Collection Design

## Overview

This document describes the design of a dedicated `teachers` collection for the web dashboard, separating teacher details from the generic `users` collection.

## Why a Separate Teachers Collection?

### Current Issues with Users Collection

1. **Mixed Data Model**: The `users` collection mixes student-specific fields (year, shift, group, class_roll) with teacher/admin data
2. **Limited Teacher Info**: No space for teacher-specific details like subjects taught, qualifications, office hours
3. **Query Performance**: Filtering teachers from all users requires filtering by role every time
4. **UI Complexity**: Web dashboard needs to handle student fields that don't apply to teachers
5. **Scalability**: As the system grows, separating concerns makes maintenance easier

### Benefits of Dedicated Teachers Collection

✅ **Clean Separation**: Teacher data separate from student data  
✅ **Rich Teacher Profiles**: Store qualifications, subjects, office hours, etc.  
✅ **Better Performance**: Direct queries to teachers collection (no role filtering)  
✅ **Easier Management**: Web dashboard focuses on teacher-specific fields  
✅ **Future-Proof**: Easy to add teacher-specific features (class schedules, consultation bookings)

---

## Teachers Collection Schema

### Collection Details

- **Collection ID**: `teachers`
- **Database**: `rpi_communication`
- **Purpose**: Store comprehensive teacher profiles for web dashboard

### Attributes

| Attribute      | Type     | Size | Required | Array | Default | Description                             |
| -------------- | -------- | ---- | -------- | ----- | ------- | --------------------------------------- |
| user_id        | string   | 255  | ✅ Yes   | No    | -       | Reference to Appwrite Auth user ID      |
| email          | email    | 255  | ✅ Yes   | No    | -       | Teacher's email (must match auth email) |
| full_name      | string   | 255  | ✅ Yes   | No    | -       | Full name of teacher                    |
| employee_id    | string   | 50   | No       | No    | -       | Employee/Staff ID                       |
| department     | string   | 100  | ✅ Yes   | No    | -       | Department (CSE, EEE, Civil, etc.)      |
| designation    | string   | 100  | No       | No    | -       | Position (Professor, Lecturer, etc.)    |
| subjects       | string   | 500  | No       | Yes   | []      | List of subjects taught                 |
| qualification  | string   | 255  | No       | No    | -       | Highest degree (PhD, M.Sc., etc.)       |
| specialization | string   | 255  | No       | No    | -       | Area of expertise                       |
| phone_number   | string   | 20   | No       | No    | -       | Contact phone                           |
| office_room    | string   | 50   | No       | No    | -       | Office room number                      |
| office_hours   | string   | 255  | No       | No    | -       | Available consultation hours            |
| joining_date   | datetime | -    | No       | No    | -       | Date of joining                         |
| photo_url      | url      | 2000 | No       | No    | -       | Profile photo URL                       |
| bio            | string   | 1000 | No       | No    | -       | Short biography                         |
| is_active      | boolean  | -    | ✅ Yes   | No    | true    | Active status                           |
| created_at     | datetime | -    | ✅ Yes   | No    | now()   | Record creation timestamp               |
| updated_at     | datetime | -    | No       | No    | -       | Last update timestamp                   |

### Indexes

1. **email** (Unique, ASC)

   - Ensures one teacher record per email
   - Fast lookup by email

2. **user_id** (Key, ASC)

   - Link to Appwrite Auth user
   - Fast lookup by auth ID

3. **department** (Key, ASC)

   - Filter teachers by department
   - Department-wise statistics

4. **is_active** (Key, ASC)

   - Quick filtering of active teachers
   - Dashboard displays

5. **created_at** (Key, DESC)
   - Sort by newest first
   - Recent additions tracking

### Permissions

#### Read

- `any` - Anyone can view teacher profiles (public directory)
- Alternative: `users` - Only authenticated users can view

#### Create

- `label:admin` - Only admins can add new teachers

#### Update

- `user:[USER_ID]` - Teachers can update their own profile
- `label:admin` - Admins can update any teacher

#### Delete

- `label:admin` - Only admins can remove teacher records

---

## Data Migration Strategy

### Option 1: Manual Migration (Recommended for Small Datasets)

1. Export existing teacher users from `users` collection
2. Create records in `teachers` collection manually through dashboard
3. Keep `users` collection for authentication reference

### Option 2: Script-Based Migration

```bash
# Migration script to copy teacher data
./scripts/migrate-teachers-to-collection.sh
```

### Option 3: Dual Mode (Gradual Migration)

- Keep both systems running
- New teachers added to `teachers` collection
- Gradually migrate old records
- Eventually deprecate teacher role in `users` collection

---

## Web Dashboard Integration

### Changes Required

1. **New Service**: `teacher.service.ts`

   - CRUD operations for teachers
   - Department filtering
   - Statistics and analytics

2. **Updated Pages**:

   - New `TeachersPage.tsx` - Manage teachers separately
   - Keep `UsersPage.tsx` for students and admins only
   - Update `DashboardPage.tsx` statistics

3. **New Components**:
   - `TeacherForm.tsx` - Form with teacher-specific fields
   - `TeacherCard.tsx` - Display teacher profile
   - `TeacherFilters.tsx` - Filter by department, subject

### UI Mockup

```
┌─────────────────────────────────────────────────────────┐
│ Teachers Management                                      │
├─────────────────────────────────────────────────────────┤
│ Search: [____________]  Dept: [All ▼]  [+ Add Teacher]  │
├─────────────────────────────────────────────────────────┤
│ Name          │ Dept │ Designation │ Subjects │ Status  │
├───────────────┼──────┼─────────────┼──────────┼─────────┤
│ Dr. John Doe  │ CSE  │ Professor   │ DS, Algo │ Active  │
│ Jane Smith    │ EEE  │ Lecturer    │ Circuit  │ Active  │
│ ...           │ ...  │ ...         │ ...      │ ...     │
└─────────────────────────────────────────────────────────┘
```

---

## API Examples

### Create Teacher

```typescript
const teacher = await teacherService.createTeacher({
  user_id: authUserId,
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
  joining_date: "2020-01-15",
  bio: "Experienced professor with 10 years in academia",
  is_active: true,
});
```

### Query Teachers

```typescript
// Get all active teachers
const teachers = await teacherService.getTeachers({ is_active: true });

// Get teachers by department
const cseTeachers = await teacherService.getTeachersByDepartment("CSE");

// Search teachers
const results = await teacherService.searchTeachers("John");
```

### Update Teacher

```typescript
await teacherService.updateTeacher(teacherId, {
  office_hours: "Mon-Fri 3-5 PM",
  subjects: ["Data Structures", "Algorithms", "AI", "ML"],
});
```

---

## Implementation Steps

### Step 1: Create Collection

```bash
./scripts/create-teachers-collection.sh
```

### Step 2: Add Service

```bash
# Created at: apps/web/src/services/teacher.service.ts
```

### Step 3: Add UI Components

```bash
# apps/web/src/pages/TeachersPage.tsx
# apps/web/src/components/TeacherForm.tsx
```

### Step 4: Update Navigation

```typescript
// Add to sidebar menu
{
  label: 'Teachers',
  icon: <SchoolIcon />,
  path: '/teachers'
}
```

### Step 5: Test

- Create sample teachers
- Test CRUD operations
- Verify permissions
- Check statistics

---

## Comparison: Before vs After

### Before (Users Collection)

**Teachers mixed with students:**

```json
{
  "$id": "abc123",
  "email": "teacher@college.edu",
  "display_name": "John Doe",
  "role": "teacher",
  "department": "CSE",
  "year": null, // ❌ Not applicable
  "shift": null, // ❌ Not applicable
  "group": null, // ❌ Not applicable
  "class_roll": null // ❌ Not applicable
}
```

**Issues:**

- ❌ Wasted fields (year, shift, group for teachers)
- ❌ Missing teacher-specific data
- ❌ Need to filter by role constantly
- ❌ Confusing UI with student fields

### After (Teachers Collection)

**Dedicated teacher profiles:**

```json
{
  "$id": "xyz789",
  "user_id": "abc123",
  "email": "teacher@college.edu",
  "full_name": "Dr. John Doe",
  "employee_id": "EMP001",
  "department": "Computer Science",
  "designation": "Professor",
  "subjects": ["DS", "Algo", "AI"],
  "qualification": "PhD in CS",
  "office_room": "CSE-301",
  "office_hours": "Mon-Wed 2-4 PM",
  "is_active": true
}
```

**Benefits:**

- ✅ Rich teacher information
- ✅ Clean, purpose-built schema
- ✅ Direct queries (no role filtering)
- ✅ Better UI/UX for management

---

## Future Enhancements

Once the teachers collection is in place, you can easily add:

1. **Class Schedules**

   - Link teachers to timetable entries
   - Show teacher's weekly schedule

2. **Student Assignments**

   - Which courses each teacher handles
   - Student enrollment per teacher

3. **Performance Analytics**

   - Teaching hours
   - Student feedback ratings
   - Course completion rates

4. **Consultation Booking**

   - Students can book office hour slots
   - Calendar integration

5. **Research Profiles**
   - Publications
   - Research interests
   - Projects

---

## Migration Checklist

- [ ] Create `teachers` collection in Appwrite
- [ ] Set up indexes and permissions
- [ ] Create `teacher.service.ts`
- [ ] Build `TeachersPage.tsx`
- [ ] Add navigation menu item
- [ ] Migrate existing teacher data
- [ ] Test CRUD operations
- [ ] Update dashboard statistics
- [ ] Deploy to production
- [ ] Document for users

---

## Related Documents

- [Appwrite Collections Schema](../archive_docs/APPWRITE_COLLECTIONS_SCHEMA.md)
- [Web Dashboard Guide](./WEB_DASHBOARD.md)
- [Appwrite Setup Instructions](../archive_docs/APPWRITE_SETUP_INSTRUCTIONS.md)

---

**Status**: Design Complete ✅  
**Next**: Implementation  
**Estimated Time**: 2-3 hours
