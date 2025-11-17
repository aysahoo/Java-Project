-- Assignment Portal Database Schema
-- MySQL Database

DROP DATABASE IF EXISTS assignment_portal;
CREATE DATABASE assignment_portal;
USE assignment_portal;

-- Users Table
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

-- Courses Table
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

-- Enrollments Table (Student-Course relationship)
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

-- Assignments Table
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

-- Submissions Table
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

-- Activity Log Table (for analytics and auditing)
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

-- Insert default users
INSERT INTO users (username, password, email, full_name, role, is_active) VALUES
('admin', SHA2('admin123', 256), 'admin@assignment-portal.com', 'System Administrator', 'ADMIN', TRUE),
('john.smith', SHA2('teacher123', 256), 'john.smith@university.edu', 'Dr. John Smith', 'TEACHER', TRUE),
('alice.brown', SHA2('student123', 256), 'alice.brown@student.edu', 'Alice Brown', 'STUDENT', TRUE);

-- Insert sample courses
INSERT INTO courses (course_code, course_name, description, teacher_id) VALUES
('CS101', 'Introduction to Programming', 'Fundamentals of programming using Java', 2),
('CS201', 'Data Structures and Algorithms', 'Advanced data structures and algorithm design', 2);

-- Insert sample enrollments
INSERT INTO enrollments (student_id, course_id, status) VALUES
(3, 1, 'ACTIVE'), -- Alice in CS101
(3, 2, 'ACTIVE'); -- Alice in CS201

-- Insert sample assignments
INSERT INTO assignments (course_id, title, description, max_marks, due_date, created_by) VALUES
(1, 'Assignment 1: Hello World', 'Create a simple Hello World program in Java', 100, '2025-11-30 23:59:59', 2),
(1, 'Assignment 2: Calculator', 'Build a basic calculator application', 100, '2025-12-15 23:59:59', 2),
(2, 'Assignment 1: Linked Lists', 'Implement various linked list operations', 100, '2025-12-01 23:59:59', 2);

-- Create views for common queries

-- View: Student Dashboard Summary
CREATE VIEW student_dashboard AS
SELECT 
    u.user_id,
    u.full_name,
    c.course_id,
    c.course_name,
    c.course_code,
    COUNT(DISTINCT a.assignment_id) as total_assignments,
    COUNT(DISTINCT s.submission_id) as submitted_assignments,
    AVG(s.marks_obtained) as average_marks
FROM users u
JOIN enrollments e ON u.user_id = e.student_id
JOIN courses c ON e.course_id = c.course_id
LEFT JOIN assignments a ON c.course_id = a.course_id
LEFT JOIN submissions s ON a.assignment_id = s.assignment_id AND s.student_id = u.user_id
WHERE u.role = 'STUDENT' AND e.status = 'ACTIVE'
GROUP BY u.user_id, c.course_id;

-- View: Teacher Assignment Overview
CREATE VIEW teacher_assignment_overview AS
SELECT 
    a.assignment_id,
    a.title,
    c.course_name,
    c.course_code,
    a.due_date,
    COUNT(DISTINCT s.submission_id) as total_submissions,
    COUNT(DISTINCT CASE WHEN s.status = 'GRADED' THEN s.submission_id END) as graded_count,
    AVG(s.marks_obtained) as average_marks
FROM assignments a
JOIN courses c ON a.course_id = c.course_id
LEFT JOIN submissions s ON a.assignment_id = s.assignment_id
GROUP BY a.assignment_id;

-- View: System Analytics
CREATE VIEW system_analytics AS
SELECT 
    (SELECT COUNT(*) FROM users WHERE role = 'STUDENT' AND is_active = TRUE) as total_students,
    (SELECT COUNT(*) FROM users WHERE role = 'TEACHER' AND is_active = TRUE) as total_teachers,
    (SELECT COUNT(*) FROM courses WHERE is_active = TRUE) as total_courses,
    (SELECT COUNT(*) FROM assignments WHERE is_active = TRUE) as total_assignments,
    (SELECT COUNT(*) FROM submissions) as total_submissions,
    (SELECT COUNT(*) FROM submissions WHERE status = 'GRADED') as graded_submissions;
