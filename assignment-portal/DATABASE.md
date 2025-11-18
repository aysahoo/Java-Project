# Database Documentation - Assignment Portal

This document provides comprehensive information about the database schema, design decisions, and data relationships.

## 📋 Table of Contents
- [Database Overview](#database-overview)
- [Schema Diagram](#schema-diagram)
- [Table Definitions](#table-definitions)
- [Relationships](#relationships)
- [Indexes](#indexes)
- [Views](#views)
- [Sample Queries](#sample-queries)
- [Data Migration](#data-migration)
- [Backup & Restore](#backup--restore)

## 🗄️ Database Overview

### Database Name
```
assignment_portal
```

### Database Type
- **Primary:** MySQL 8.0+
- **Alternative:** PostgreSQL (schema available in `database/schema-postgres.sql`)

### Character Set & Collation
```sql
DEFAULT CHARACTER SET = utf8mb4
DEFAULT COLLATE = utf8mb4_unicode_ci
```

### Total Tables
- **6 Core Tables:** users, courses, enrollments, assignments, submissions, activity_log
- **1 View:** student_dashboard

## 📊 Schema Diagram

```
┌─────────────────┐
│     USERS       │
│─────────────────│
│ PK user_id      │──┐
│    username     │  │
│    password     │  │
│    email        │  │
│    full_name    │  │
│    role         │  │
│    is_active    │  │
│    created_at   │  │
│    updated_at   │  │
└─────────────────┘  │
                     │
        ┌────────────┼────────────┐
        │            │            │
        │            │            │
┌───────▼──────┐ ┌──▼──────────┐ │
│   COURSES    │ │ ASSIGNMENTS  │ │
│──────────────│ │──────────────│ │
│PK course_id  │ │PK assign_id  │ │
│  course_code │ │FK course_id  │─┤
│  course_name │ │  title       │ │
│  description │ │  description │ │
│FK teacher_id │─┤  max_marks   │ │
│  is_active   │ │  due_date    │ │
│  created_at  │ │FK created_by │─┘
└──────┬───────┘ │  file_path   │
       │         │  is_active   │
       │         └──────┬───────┘
       │                │
       │         ┌──────▼────────┐
       │         │  SUBMISSIONS  │
       │         │───────────────│
       │         │PK submit_id   │
       │         │FK assign_id   │──┐
       │         │FK student_id  │  │
       │         │  file_path    │  │
       │         │  file_name    │  │
       │         │  file_size_kb │  │
       │         │  submit_date  │  │
       │         │  marks_obtain │  │
       │         │  feedback     │  │
       │         │FK graded_by   │──┤
       │         │  graded_at    │  │
       │         │  status       │  │
       │         │  is_late      │  │
       │         └───────────────┘  │
       │                            │
       │         ┌──────────────────┘
┌──────▼────────┐│
│  ENROLLMENTS  ││
│───────────────││
│PK enroll_id   ││
│FK student_id  │┘
│FK course_id   │─┘
│  enroll_date  │
│  status       │
└───────────────┘

┌─────────────────┐
│  ACTIVITY_LOG   │
│─────────────────│
│ PK log_id       │
│ FK user_id      │──┘
│    action       │
│    entity_type  │
│    entity_id    │
│    details      │
│    ip_address   │
│    timestamp    │
└─────────────────┘
```

## 📋 Table Definitions

### 1. USERS Table

Stores all system users (Students, Teachers, Administrators).

```sql
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role ENUM('STUDENT', 'TEACHER', 'ADMIN') NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_username (username),
    INDEX idx_role (role),
    INDEX idx_email (email)
);
```

**Columns:**
- `user_id` - Unique identifier (Primary Key)
- `username` - Unique login username
- `password` - Hashed password (SHA-256)
- `email` - Unique email address
- `full_name` - User's full name
- `role` - User role: STUDENT, TEACHER, or ADMIN
- `is_active` - Account status flag
- `created_at` - Account creation timestamp
- `updated_at` - Last update timestamp

**Constraints:**
- Unique username and email
- Role must be one of: STUDENT, TEACHER, ADMIN
- Password stored as SHA2 hash (never plain text)

---

### 2. COURSES Table

Stores course information managed by teachers.

```sql
CREATE TABLE courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_code VARCHAR(20) UNIQUE NOT NULL,
    course_name VARCHAR(100) NOT NULL,
    description TEXT,
    teacher_id INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (teacher_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_teacher (teacher_id),
    INDEX idx_course_code (course_code)
);
```

**Columns:**
- `course_id` - Unique identifier (Primary Key)
- `course_code` - Unique course code (e.g., CS101)
- `course_name` - Course title
- `description` - Course description
- `teacher_id` - Foreign Key to users table (teacher)
- `is_active` - Course active status
- `created_at` - Course creation timestamp
- `updated_at` - Last update timestamp

**Constraints:**
- `teacher_id` must reference a valid user with TEACHER role
- Unique course_code
- ON DELETE CASCADE: Deleting teacher deletes their courses

---

### 3. ENROLLMENTS Table

Manages student enrollments in courses (Many-to-Many relationship).

```sql
CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('ACTIVE', 'DROPPED', 'COMPLETED') DEFAULT 'ACTIVE',
    
    FOREIGN KEY (student_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
    UNIQUE KEY unique_enrollment (student_id, course_id),
    INDEX idx_student (student_id),
    INDEX idx_course (course_id)
);
```

**Columns:**
- `enrollment_id` - Unique identifier (Primary Key)
- `student_id` - Foreign Key to users table (student)
- `course_id` - Foreign Key to courses table
- `enrollment_date` - Enrollment timestamp
- `status` - Enrollment status: ACTIVE, DROPPED, COMPLETED

**Constraints:**
- Composite unique key on (student_id, course_id) - prevents duplicate enrollments
- `student_id` must reference a valid user with STUDENT role
- ON DELETE CASCADE: Deleting student/course deletes enrollments

---

### 4. ASSIGNMENTS Table

Stores assignment details created by teachers.

```sql
CREATE TABLE assignments (
    assignment_id INT PRIMARY KEY AUTO_INCREMENT,
    course_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    max_marks INT NOT NULL DEFAULT 100,
    due_date DATETIME NOT NULL,
    file_path VARCHAR(500),
    allowed_file_types VARCHAR(100) DEFAULT 'pdf,docx,zip',
    max_file_size_mb INT DEFAULT 10,
    created_by INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_course (course_id),
    INDEX idx_due_date (due_date),
    INDEX idx_created_by (created_by)
);
```

**Columns:**
- `assignment_id` - Unique identifier (Primary Key)
- `course_id` - Foreign Key to courses table
- `title` - Assignment title
- `description` - Detailed assignment description
- `max_marks` - Maximum possible marks (default: 100)
- `due_date` - Submission deadline
- `file_path` - Path to assignment document (optional)
- `allowed_file_types` - Comma-separated allowed file extensions
- `max_file_size_mb` - Maximum upload file size in MB
- `created_by` - Foreign Key to users table (teacher who created it)
- `is_active` - Assignment active status
- `created_at` - Creation timestamp
- `updated_at` - Last update timestamp

**Constraints:**
- `course_id` must exist in courses table
- `created_by` must reference a valid TEACHER
- ON DELETE CASCADE: Deleting course deletes assignments

---

### 5. SUBMISSIONS Table

Stores student assignment submissions and grading information.

```sql
CREATE TABLE submissions (
    submission_id INT PRIMARY KEY AUTO_INCREMENT,
    assignment_id INT NOT NULL,
    student_id INT NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    original_filename VARCHAR(255) NOT NULL,
    file_size_kb INT NOT NULL,
    submission_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    marks_obtained INT,
    feedback TEXT,
    graded_by INT,
    graded_at TIMESTAMP NULL,
    status ENUM('SUBMITTED', 'GRADED', 'LATE', 'RESUBMITTED') DEFAULT 'SUBMITTED',
    is_late BOOLEAN DEFAULT FALSE,
    
    FOREIGN KEY (assignment_id) REFERENCES assignments(assignment_id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (graded_by) REFERENCES users(user_id) ON DELETE SET NULL,
    INDEX idx_assignment (assignment_id),
    INDEX idx_student (student_id),
    INDEX idx_status (status),
    INDEX idx_submission_date (submission_date)
);
```

**Columns:**
- `submission_id` - Unique identifier (Primary Key)
- `assignment_id` - Foreign Key to assignments table
- `student_id` - Foreign Key to users table (student)
- `file_path` - Server path to uploaded file
- `original_filename` - Original uploaded filename
- `file_size_kb` - File size in kilobytes
- `submission_date` - Submission timestamp
- `marks_obtained` - Marks given by teacher (NULL if not graded)
- `feedback` - Teacher's feedback (NULL if not graded)
- `graded_by` - Foreign Key to users table (teacher who graded)
- `graded_at` - Grading timestamp
- `status` - Submission status: SUBMITTED, GRADED, LATE, RESUBMITTED
- `is_late` - Flag for late submissions

**Constraints:**
- `assignment_id` must exist in assignments table
- `student_id` must reference a valid STUDENT
- `graded_by` must reference a valid TEACHER (if not NULL)
- ON DELETE CASCADE: Deleting assignment/student deletes submissions
- ON DELETE SET NULL: Deleting grader keeps submission but sets graded_by to NULL

---

### 6. ACTIVITY_LOG Table

Audit log for tracking user actions and system events.

```sql
CREATE TABLE activity_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50),
    entity_id INT,
    details TEXT,
    ip_address VARCHAR(45),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    INDEX idx_user (user_id),
    INDEX idx_action (action),
    INDEX idx_timestamp (timestamp)
);
```

**Columns:**
- `log_id` - Unique identifier (Primary Key)
- `user_id` - Foreign Key to users table (nullable)
- `action` - Action performed (e.g., LOGIN, SUBMIT_ASSIGNMENT, GRADE)
- `entity_type` - Type of entity affected (e.g., assignment, course)
- `entity_id` - ID of affected entity
- `details` - Additional details in JSON or text format
- `ip_address` - IP address of user (supports IPv4 and IPv6)
- `timestamp` - Action timestamp

**Constraints:**
- ON DELETE SET NULL: Deleting user keeps log but sets user_id to NULL

---

## 🔗 Relationships

### One-to-Many Relationships

1. **Users → Courses**
   - One teacher can create many courses
   - FK: `courses.teacher_id` → `users.user_id`

2. **Users → Assignments**
   - One teacher can create many assignments
   - FK: `assignments.created_by` → `users.user_id`

3. **Courses → Assignments**
   - One course can have many assignments
   - FK: `assignments.course_id` → `courses.course_id`

4. **Assignments → Submissions**
   - One assignment can have many submissions
   - FK: `submissions.assignment_id` → `assignments.assignment_id`

5. **Users → Submissions (as Student)**
   - One student can make many submissions
   - FK: `submissions.student_id` → `users.user_id`

6. **Users → Submissions (as Grader)**
   - One teacher can grade many submissions
   - FK: `submissions.graded_by` → `users.user_id`

### Many-to-Many Relationships

1. **Students ↔ Courses (via Enrollments)**
   - Many students can enroll in many courses
   - Bridge table: `enrollments`
   - FKs: `enrollments.student_id` → `users.user_id`
         `enrollments.course_id` → `courses.course_id`

---

## 🔍 Indexes

### Performance Indexes

1. **Users Table:**
   - `idx_username` - Fast username lookups during login
   - `idx_email` - Email validation and searches
   - `idx_role` - Role-based queries (get all students/teachers)

2. **Courses Table:**
   - `idx_teacher` - Find courses by teacher
   - `idx_course_code` - Unique course code lookups

3. **Enrollments Table:**
   - `idx_student` - Find enrollments by student
   - `idx_course` - Find enrollments by course
   - `unique_enrollment` - Prevent duplicate enrollments

4. **Assignments Table:**
   - `idx_course` - Find assignments by course
   - `idx_due_date` - Sort assignments by due date
   - `idx_created_by` - Find assignments by teacher

5. **Submissions Table:**
   - `idx_assignment` - Find submissions for an assignment
   - `idx_student` - Find submissions by student
   - `idx_status` - Filter by submission status
   - `idx_submission_date` - Sort by submission date

6. **Activity Log Table:**
   - `idx_user` - Find actions by user
   - `idx_action` - Filter by action type
   - `idx_timestamp` - Sort by time for audit trails

---

## 📊 Views

### student_dashboard View

Provides aggregated data for student dashboard.

```sql
CREATE VIEW student_dashboard AS
SELECT 
    u.user_id,
    u.full_name,
    c.course_id,
    c.course_name,
    c.course_code,
    COUNT(DISTINCT a.assignment_id) as total_assignments,
    COUNT(DISTINCT s.submission_id) as submitted_assignments,
    AVG(s.marks_obtained) as average_marks,
    SUM(CASE WHEN s.is_late = TRUE THEN 1 ELSE 0 END) as late_submissions
FROM users u
JOIN enrollments e ON u.user_id = e.student_id AND e.status = 'ACTIVE'
JOIN courses c ON e.course_id = c.course_id AND c.is_active = TRUE
LEFT JOIN assignments a ON c.course_id = a.course_id AND a.is_active = TRUE
LEFT JOIN submissions s ON a.assignment_id = s.assignment_id 
    AND s.student_id = u.user_id
WHERE u.role = 'STUDENT' AND u.is_active = TRUE
GROUP BY u.user_id, c.course_id;
```

**Usage:**
```sql
-- Get dashboard data for a specific student
SELECT * FROM student_dashboard WHERE user_id = 3;

-- Get course performance
SELECT course_name, total_assignments, submitted_assignments, average_marks
FROM student_dashboard 
WHERE user_id = 3
ORDER BY average_marks DESC;
```

---

## 📝 Sample Queries

### User Management

**1. Create a new student:**
```sql
INSERT INTO users (username, password, email, full_name, role) 
VALUES ('bob.johnson', SHA2('student123', 256), 'bob@student.edu', 'Bob Johnson', 'STUDENT');
```

**2. Get all active teachers:**
```sql
SELECT user_id, username, full_name, email 
FROM users 
WHERE role = 'TEACHER' AND is_active = TRUE
ORDER BY full_name;
```

**3. Update user email:**
```sql
UPDATE users 
SET email = 'new.email@example.com', updated_at = CURRENT_TIMESTAMP
WHERE user_id = 5;
```

### Course Operations

**4. Get courses taught by a specific teacher:**
```sql
SELECT c.course_id, c.course_code, c.course_name, 
       COUNT(e.enrollment_id) as total_students
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id AND e.status = 'ACTIVE'
WHERE c.teacher_id = 2 AND c.is_active = TRUE
GROUP BY c.course_id;
```

**5. Enroll a student in a course:**
```sql
INSERT INTO enrollments (student_id, course_id, status)
VALUES (3, 1, 'ACTIVE');
```

**6. Get all students enrolled in a course:**
```sql
SELECT u.user_id, u.username, u.full_name, u.email, e.enrollment_date
FROM users u
JOIN enrollments e ON u.user_id = e.student_id
WHERE e.course_id = 1 AND e.status = 'ACTIVE'
ORDER BY u.full_name;
```

### Assignment Management

**7. Create a new assignment:**
```sql
INSERT INTO assignments 
    (course_id, title, description, max_marks, due_date, created_by)
VALUES 
    (1, 'Midterm Project', 'Build a web application', 100, 
     '2025-12-15 23:59:59', 2);
```

**8. Get upcoming assignments for a course:**
```sql
SELECT assignment_id, title, due_date, max_marks
FROM assignments
WHERE course_id = 1 
  AND is_active = TRUE 
  AND due_date > NOW()
ORDER BY due_date ASC;
```

**9. Get overdue assignments:**
```sql
SELECT a.assignment_id, a.title, a.due_date, c.course_name
FROM assignments a
JOIN courses c ON a.course_id = c.course_id
WHERE a.due_date < NOW() AND a.is_active = TRUE
ORDER BY a.due_date DESC;
```

### Submission Tracking

**10. Submit an assignment:**
```sql
INSERT INTO submissions 
    (assignment_id, student_id, file_path, original_filename, 
     file_size_kb, is_late, status)
VALUES 
    (1, 3, '/uploads/submission_123.pdf', 'my_assignment.pdf', 
     512, FALSE, 'SUBMITTED');
```

**11. Get all submissions for grading:**
```sql
SELECT s.submission_id, u.full_name, u.email, 
       s.submission_date, s.original_filename, s.status
FROM submissions s
JOIN users u ON s.student_id = u.user_id
WHERE s.assignment_id = 1
ORDER BY s.submission_date ASC;
```

**12. Grade a submission:**
```sql
UPDATE submissions
SET marks_obtained = 85,
    feedback = 'Good work! Well structured code.',
    graded_by = 2,
    graded_at = CURRENT_TIMESTAMP,
    status = 'GRADED'
WHERE submission_id = 10;
```

**13. Get student's submission history:**
```sql
SELECT a.title, c.course_name, s.submission_date, 
       s.marks_obtained, a.max_marks, s.status, s.is_late
FROM submissions s
JOIN assignments a ON s.assignment_id = a.assignment_id
JOIN courses c ON a.course_id = c.course_id
WHERE s.student_id = 3
ORDER BY s.submission_date DESC;
```

### Analytics & Reporting

**14. Get course statistics:**
```sql
SELECT 
    c.course_name,
    COUNT(DISTINCT e.student_id) as enrolled_students,
    COUNT(DISTINCT a.assignment_id) as total_assignments,
    COUNT(DISTINCT s.submission_id) as total_submissions,
    AVG(s.marks_obtained) as average_score
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id AND e.status = 'ACTIVE'
LEFT JOIN assignments a ON c.course_id = a.course_id AND a.is_active = TRUE
LEFT JOIN submissions s ON a.assignment_id = s.assignment_id AND s.status = 'GRADED'
WHERE c.course_id = 1
GROUP BY c.course_id;
```

**15. Get top performers:**
```sql
SELECT u.full_name, AVG(s.marks_obtained) as avg_marks
FROM users u
JOIN submissions s ON u.user_id = s.student_id
WHERE s.status = 'GRADED' AND u.role = 'STUDENT'
GROUP BY u.user_id
HAVING AVG(s.marks_obtained) >= 80
ORDER BY avg_marks DESC
LIMIT 10;
```

**16. Get submission rate by assignment:**
```sql
SELECT 
    a.title,
    a.due_date,
    COUNT(DISTINCT e.student_id) as enrolled_students,
    COUNT(DISTINCT s.submission_id) as submissions,
    ROUND(COUNT(DISTINCT s.submission_id) * 100.0 / 
          COUNT(DISTINCT e.student_id), 2) as submission_rate
FROM assignments a
JOIN courses c ON a.course_id = c.course_id
JOIN enrollments e ON c.course_id = e.course_id AND e.status = 'ACTIVE'
LEFT JOIN submissions s ON a.assignment_id = s.assignment_id 
    AND s.student_id = e.student_id
WHERE a.assignment_id = 1
GROUP BY a.assignment_id;
```

---

## 🔄 Data Migration

### Export Database

**Complete database export:**
```bash
mysqldump -u root -p assignment_portal > backup_$(date +%Y%m%d).sql
```

**Export structure only:**
```bash
mysqldump -u root -p --no-data assignment_portal > schema_only.sql
```

**Export specific table:**
```bash
mysqldump -u root -p assignment_portal users > users_backup.sql
```

### Import Database

**Import from SQL file:**
```bash
mysql -u root -p assignment_portal < backup_20251118.sql
```

**Import with progress:**
```bash
pv backup.sql | mysql -u root -p assignment_portal
```

---

## 💾 Backup & Restore

### Automated Backup Script

```bash
#!/bin/bash
# backup-db.sh

BACKUP_DIR="/var/backups/mysql"
DATE=$(date +%Y%m%d_%H%M%S)
DB_NAME="assignment_portal"

mkdir -p $BACKUP_DIR

mysqldump -u root -p$MYSQL_PASSWORD \
  --single-transaction \
  --routines \
  --triggers \
  $DB_NAME | gzip > $BACKUP_DIR/${DB_NAME}_${DATE}.sql.gz

# Keep only last 7 days
find $BACKUP_DIR -name "*.sql.gz" -mtime +7 -delete
```

### Restore from Backup

```bash
# Decompress and restore
gunzip < backup_20251118.sql.gz | mysql -u root -p assignment_portal
```

---

## 🔧 Database Maintenance

### Optimize Tables

```sql
-- Optimize all tables
OPTIMIZE TABLE users, courses, enrollments, assignments, submissions, activity_log;

-- Analyze tables for better query performance
ANALYZE TABLE users, courses, enrollments, assignments, submissions;
```

### Check Table Integrity

```sql
CHECK TABLE users, courses, enrollments, assignments, submissions;
```

### Monitor Database Size

```sql
SELECT 
    table_name AS 'Table',
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size (MB)'
FROM information_schema.TABLES
WHERE table_schema = 'assignment_portal'
ORDER BY (data_length + index_length) DESC;
```

---

**Database documentation complete! 📊**
