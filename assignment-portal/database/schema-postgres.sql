-- Assignment Portal Database Schema
-- PostgreSQL Database for Neon

-- Drop existing tables if they exist
DROP TABLE IF EXISTS activity_log CASCADE;
DROP TABLE IF EXISTS submissions CASCADE;
DROP TABLE IF EXISTS assignments CASCADE;
DROP TABLE IF EXISTS enrollments CASCADE;
DROP TABLE IF EXISTS courses CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Drop views if they exist
DROP VIEW IF EXISTS student_dashboard CASCADE;
DROP VIEW IF EXISTS teacher_assignment_overview CASCADE;
DROP VIEW IF EXISTS system_analytics CASCADE;

-- Users Table
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('STUDENT', 'TEACHER', 'ADMIN')),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_username ON users(username);
CREATE INDEX idx_role ON users(role);
CREATE INDEX idx_email ON users(email);

-- Courses Table
CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    course_code VARCHAR(20) UNIQUE NOT NULL,
    course_name VARCHAR(100) NOT NULL,
    description TEXT,
    teacher_id INTEGER NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (teacher_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE INDEX idx_teacher ON courses(teacher_id);
CREATE INDEX idx_course_code ON courses(course_code);

-- Enrollments Table (Student-Course relationship)
CREATE TABLE enrollments (
    enrollment_id SERIAL PRIMARY KEY,
    student_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'DROPPED', 'COMPLETED')),
    FOREIGN KEY (student_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
    UNIQUE (student_id, course_id)
);

CREATE INDEX idx_student ON enrollments(student_id);
CREATE INDEX idx_course ON enrollments(course_id);

-- Assignments Table
CREATE TABLE assignments (
    assignment_id SERIAL PRIMARY KEY,
    course_id INTEGER NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    max_marks INTEGER NOT NULL DEFAULT 100,
    due_date TIMESTAMP NOT NULL,
    file_path VARCHAR(500),
    allowed_file_types VARCHAR(100) DEFAULT 'pdf,docx,zip',
    max_file_size_mb INTEGER DEFAULT 10,
    created_by INTEGER NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE INDEX idx_course_assignment ON assignments(course_id);
CREATE INDEX idx_due_date ON assignments(due_date);
CREATE INDEX idx_created_by ON assignments(created_by);

-- Submissions Table
CREATE TABLE submissions (
    submission_id SERIAL PRIMARY KEY,
    assignment_id INTEGER NOT NULL,
    student_id INTEGER NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    original_filename VARCHAR(255) NOT NULL,
    file_size_kb INTEGER NOT NULL,
    submission_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    marks_obtained INTEGER,
    feedback TEXT,
    graded_by INTEGER,
    graded_at TIMESTAMP,
    status VARCHAR(20) DEFAULT 'SUBMITTED' CHECK (status IN ('SUBMITTED', 'GRADED', 'LATE', 'RESUBMITTED')),
    is_late BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (assignment_id) REFERENCES assignments(assignment_id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (graded_by) REFERENCES users(user_id) ON DELETE SET NULL
);

CREATE INDEX idx_assignment ON submissions(assignment_id);
CREATE INDEX idx_student_submission ON submissions(student_id);
CREATE INDEX idx_status ON submissions(status);
CREATE INDEX idx_submission_date ON submissions(submission_date);

-- Activity Log Table (for analytics and auditing)
CREATE TABLE activity_log (
    log_id SERIAL PRIMARY KEY,
    user_id INTEGER,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50),
    entity_id INTEGER,
    details TEXT,
    ip_address VARCHAR(45),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL
);

CREATE INDEX idx_user_log ON activity_log(user_id);
CREATE INDEX idx_action ON activity_log(action);
CREATE INDEX idx_timestamp ON activity_log(timestamp);

-- Insert default users
-- Note: PostgreSQL uses MD5 or pgcrypto for password hashing
INSERT INTO users (username, password, email, full_name, role, is_active) VALUES
('admin', md5('admin123'), 'admin@assignment-portal.com', 'System Administrator', 'ADMIN', TRUE),
('john.smith', md5('teacher123'), 'john.smith@university.edu', 'Dr. John Smith', 'TEACHER', TRUE),
('alice.brown', md5('student123'), 'alice.brown@student.edu', 'Alice Brown', 'STUDENT', TRUE);

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
GROUP BY u.user_id, c.course_id, u.full_name, c.course_name, c.course_code;

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
GROUP BY a.assignment_id, a.title, c.course_name, c.course_code, a.due_date;

-- View: System Analytics
CREATE VIEW system_analytics AS
SELECT 
    (SELECT COUNT(*) FROM users WHERE role = 'STUDENT' AND is_active = TRUE) as total_students,
    (SELECT COUNT(*) FROM users WHERE role = 'TEACHER' AND is_active = TRUE) as total_teachers,
    (SELECT COUNT(*) FROM courses WHERE is_active = TRUE) as total_courses,
    (SELECT COUNT(*) FROM assignments WHERE is_active = TRUE) as total_assignments,
    (SELECT COUNT(*) FROM submissions) as total_submissions,
    (SELECT COUNT(*) FROM submissions WHERE status = 'GRADED') as graded_submissions;

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_courses_updated_at BEFORE UPDATE ON courses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_assignments_updated_at BEFORE UPDATE ON assignments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
