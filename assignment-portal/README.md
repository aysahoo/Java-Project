# 🎓 Assignment Portal - Complete Java Web Application

A comprehensive assignment submission and management system built with **Java Servlets**, **JSP**, **PostgreSQL (Neon)**, and deployed on **Apache Tomcat 9**.

---

## 📋 Table of Contents

1. [Project Overview](#project-overview)
2. [Features](#features)
3. [Technology Stack](#technology-stack)
4. [Architecture](#architecture)
5. [Database Schema](#database-schema)
6. [Installation & Setup](#installation--setup)
7. [Access & Login](#access--login)
8. [Project Structure](#project-structure)
9. [Monitoring & Management](#monitoring--management)
10. [API Endpoints](#api-endpoints)
11. [Multithreading Implementation](#multithreading-implementation)
12. [Troubleshooting](#troubleshooting)

---

## 🎯 Project Overview

The **Assignment Portal** is a web-based application that allows:
- **Students** to submit assignments, view grades, and track their progress
- **Teachers** to create assignments, grade submissions, and manage courses
- **Admins** to manage users, courses, and view system analytics

### Key Highlights
- ✅ **Role-Based Access Control** (Student, Teacher, Admin)
- ✅ **Multithreading** for connection pooling and file upload processing
- ✅ **Cloud Database** using Neon PostgreSQL
- ✅ **Secure Authentication** with MD5 password hashing
- ✅ **File Upload Support** (PDF, DOCX, ZIP - up to 10MB)
- ✅ **RESTful Servlet Architecture**

---

## ✨ Features

### For Students 👨‍🎓
- View enrolled courses and assignments
- Submit assignment files
- Track submission status (Submitted, Graded, Late)
- View grades and feedback from teachers
- Dashboard with statistics

### For Teachers 👨‍🏫
- Create and manage courses
- Create assignments with due dates
- View and download student submissions
- Grade submissions and provide feedback
- Teacher dashboard with course overview

### For Admins 👑
- User management (Create, Edit, Disable users)
- Course management
- System analytics and reports
- Activity logging and monitoring

---

## 🛠 Technology Stack

| Component | Technology | Version |
|-----------|-----------|---------|
| **Backend** | Java Servlets | Java 8+ |
| **Frontend** | JSP, HTML5, CSS3 | - |
| **Database** | PostgreSQL (Neon) | Cloud |
| **Application Server** | Apache Tomcat | 9.0.112 |
| **JDBC Driver** | PostgreSQL JDBC | 42.7.1 |
| **Build Tool** | Manual Compilation | - |
| **OS** | macOS | - |

---

## 🏗 Architecture

### Design Pattern: **MVC (Model-View-Controller)**

```
┌─────────────────────────────────────────────────────────────┐
│                         Presentation Layer                   │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │  index.html │  │  login.jsp  │  │ dashboards  │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Controller Layer (Servlets)             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ LoginServlet │  │SubmitServlet │  │ GradeServlet │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Business Layer (DAO)                    │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ UserDAO  │  │CourseDAO │  │AssignDAO │  │SubmitDAO │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                              │
│  ┌───────────────────────────────────────────────┐          │
│  │  PostgreSQL Database (Neon Cloud)              │          │
│  │  - users, courses, assignments, submissions    │          │
│  └───────────────────────────────────────────────┘          │
└─────────────────────────────────────────────────────────────┘
```

### Utility Layer
- **DatabaseConnectionPool**: Thread-safe connection pooling using `ArrayBlockingQueue`
- **FileUploadHandler**: Async file upload processing using `ExecutorService`
- **ValidationUtil**: Input validation and sanitization

---

## 🗄 Database Schema

### Tables (8 Total)

#### 1. **users**
```sql
- user_id (SERIAL PRIMARY KEY)
- username (VARCHAR UNIQUE)
- password (VARCHAR - MD5 hashed)
- email (VARCHAR UNIQUE)
- full_name (VARCHAR)
- role (VARCHAR - STUDENT/TEACHER/ADMIN)
- is_active (BOOLEAN)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
```

#### 2. **courses**
```sql
- course_id (SERIAL PRIMARY KEY)
- course_code (VARCHAR UNIQUE)
- course_name (VARCHAR)
- description (TEXT)
- teacher_id (INTEGER FK → users)
- is_active (BOOLEAN)
- created_at, updated_at (TIMESTAMP)
```

#### 3. **enrollments**
```sql
- enrollment_id (SERIAL PRIMARY KEY)
- student_id (INTEGER FK → users)
- course_id (INTEGER FK → courses)
- enrollment_date (TIMESTAMP)
- status (VARCHAR - ACTIVE/DROPPED/COMPLETED)
```

#### 4. **assignments**
```sql
- assignment_id (SERIAL PRIMARY KEY)
- course_id (INTEGER FK → courses)
- title (VARCHAR)
- description (TEXT)
- max_marks (INTEGER)
- due_date (TIMESTAMP)
- file_path (VARCHAR)
- allowed_file_types (VARCHAR)
- max_file_size_mb (INTEGER)
- created_by (INTEGER FK → users)
- is_active (BOOLEAN)
- created_at, updated_at (TIMESTAMP)
```

#### 5. **submissions**
```sql
- submission_id (SERIAL PRIMARY KEY)
- assignment_id (INTEGER FK → assignments)
- student_id (INTEGER FK → users)
- file_path (VARCHAR)
- original_filename (VARCHAR)
- file_size_kb (INTEGER)
- submission_date (TIMESTAMP)
- marks_obtained (INTEGER)
- feedback (TEXT)
- graded_by (INTEGER FK → users)
- graded_at (TIMESTAMP)
- status (VARCHAR - SUBMITTED/GRADED/LATE/RESUBMITTED)
- is_late (BOOLEAN)
```

#### 6. **activity_log**
```sql
- log_id (SERIAL PRIMARY KEY)
- user_id (INTEGER FK → users)
- action (VARCHAR)
- entity_type (VARCHAR)
- entity_id (INTEGER)
- details (TEXT)
- ip_address (VARCHAR)
- timestamp (TIMESTAMP)
```

### Views (3 Total)
1. **student_dashboard** - Aggregated student statistics
2. **teacher_assignment_overview** - Assignment submission stats
3. **system_analytics** - Overall system metrics

### Database Connection
- **Provider**: Neon PostgreSQL (Cloud)
- **Region**: ap-southeast-1 (Singapore)
- **Database**: neondb
- **SSL**: Required

---

## 🚀 Installation & Setup

### Prerequisites
- ✅ Java 8 or higher (OpenJDK 25.0.1 installed)
- ✅ Apache Tomcat 9.0.112
- ✅ PostgreSQL JDBC Driver (included in WEB-INF/lib/)
- ✅ Internet connection (for Neon database)

### Step 1: Navigate to Project
```bash
cd /Users/ayushranjansahoo/Documents/Desktop/java-awt/assignment-portal
```

### Step 2: Database Setup (Already Completed ✅)
The PostgreSQL database on Neon is already set up with:
- 3 Users (1 Admin, 1 Teacher, 1 Student)
- 2 Courses
- 3 Assignments
- 2 Enrollments
- All tables, indexes, and views

### Step 3: Deploy Application
```bash
export CATALINA_HOME=/opt/homebrew/opt/tomcat@9/libexec
./deploy.sh
```

### Step 4: Start Tomcat
```bash
/opt/homebrew/opt/tomcat@9/libexec/bin/startup.sh
```

### Step 5: Access Application
Open browser: **http://localhost:8080/assignment-portal/**

---

## 🔐 Access & Login

### Application URL
**http://localhost:8080/assignment-portal/**

Click "Get Started →" button to login

### Demo Accounts

| Role | Username | Password | Dashboard Features |
|------|----------|----------|-------------------|
| **Admin** | `admin` | `admin123` | User management, Analytics, System config |
| **Teacher** | `john.smith` | `teacher123` | Course management, Grading |
| **Student** | `alice.brown` | `student123` | Submit assignments, View grades |

### Tomcat Manager (Optional)
- **URL**: http://localhost:8080/manager/html
- **Username**: `admin`
- **Password**: `tomcat123`

---

## 📁 Project Structure

```
assignment-portal/
├── database/
│   ├── schema-postgres.sql       # PostgreSQL schema (ACTIVE)
│   ├── db.properties              # Database configuration
│   └── schema.sql                 # Old MySQL schema (deprecated)
│
├── WEB-INF/
│   ├── classes/
│   │   ├── com/assignmentportal/
│   │   │   ├── model/             # 5 Model classes
│   │   │   │   ├── User.java
│   │   │   │   ├── Course.java
│   │   │   │   ├── Assignment.java
│   │   │   │   ├── Submission.java
│   │   │   │   └── Enrollment.java
│   │   │   │
│   │   │   ├── dao/               # 4 DAO classes
│   │   │   │   ├── UserDAO.java
│   │   │   │   ├── CourseDAO.java
│   │   │   │   ├── AssignmentDAO.java
│   │   │   │   └── SubmissionDAO.java
│   │   │   │
│   │   │   ├── servlet/           # 7 Servlet classes
│   │   │   │   ├── LoginServlet.java
│   │   │   │   ├── LogoutServlet.java
│   │   │   │   ├── StudentDashboardServlet.java
│   │   │   │   ├── TeacherDashboardServlet.java
│   │   │   │   ├── AdminDashboardServlet.java
│   │   │   │   ├── SubmitAssignmentServlet.java
│   │   │   │   └── GradeSubmissionServlet.java
│   │   │   │
│   │   │   └── util/              # 3 Utility classes
│   │   │       ├── DatabaseConnectionPool.java
│   │   │       ├── FileUploadHandler.java
│   │   │       └── ValidationUtil.java
│   │   │
│   │   └── db.properties          # Database config (deployed)
│   │
│   ├── lib/
│   │   ├── postgresql.jar         # PostgreSQL JDBC (1.05MB) ✅
│   │   └── mysql-connector-j.jar  # Old MySQL driver (not used)
│   │
│   └── web.xml                    # Deployment descriptor
│
├── jsp/
│   ├── login.jsp                  # Login page
│   ├── student-dashboard.jsp      # Student dashboard
│   ├── teacher-dashboard.jsp      # Teacher dashboard
│   └── admin-dashboard.jsp        # Admin dashboard
│
├── index.html                     # Landing page
│
├── compile.sh                     # Compilation script
├── deploy.sh                      # Deployment script
├── monitor.sh                     # Monitoring dashboard ⭐
├── setup.sh                       # Initial setup script
│
└── Documentation/
    ├── README.md                  # This file (Main documentation)
    ├── QUICKSTART.md              # Quick start guide
    ├── IMPLEMENTATION_GUIDE.md    # Implementation details
    ├── FEATURES.md                # Feature documentation
    ├── PROJECT_SUMMARY.md         # Project summary
    └── DELIVERY.md                # Delivery checklist
```

**Statistics:**
- **Total Java Files**: 19
- **Total Lines of Code**: ~5,000+
- **Compiled Classes**: 21
- **JSP Pages**: 4
- **Database Tables**: 8
- **Database Views**: 3

---

## 📊 Monitoring & Management

### Monitor Dashboard
```bash
./monitor.sh
```

**Output includes:**
- 🐘 PostgreSQL Database Status (Neon)
- 🐱 Tomcat Server Status (PID, Memory)
- 📦 Application Deployment Status
- 🔗 Access URLs
- 📋 Log File Locations
- ⚡ Quick Action Commands

### Quick Actions

```bash
# View all users
./monitor.sh show-users

# View submissions
./monitor.sh show-submissions

# Restart Tomcat
./monitor.sh restart-tomcat

# Watch live logs
./monitor.sh live-logs

# Open application in browser
./monitor.sh open
```

### Direct Database Access
```bash
PGPASSWORD='npg_8Wts4DNhpeRY' psql \
  -h ep-floral-bush-a1ft2sv2-pooler.ap-southeast-1.aws.neon.tech \
  -U neondb_owner \
  -d neondb
```

### Log Files
- **Catalina Log**: `/opt/homebrew/opt/tomcat@9/libexec/logs/catalina.out`
- **Localhost Log**: `/opt/homebrew/opt/tomcat@9/libexec/logs/localhost.[date].log`
- **Database**: Neon PostgreSQL (Cloud - no local logs)

---

## 🌐 API Endpoints

### Authentication
| Method | Endpoint | Description | Access |
|--------|----------|-------------|--------|
| GET | `/login` | Show login page | Public |
| POST | `/login` | Authenticate user | Public |
| GET | `/logout` | Logout user | Authenticated |

### Student Endpoints
| Method | Endpoint | Description | Access |
|--------|----------|-------------|--------|
| GET | `/student/dashboard` | Student dashboard | Student |
| POST | `/student/submit` | Submit assignment | Student |

### Teacher Endpoints
| Method | Endpoint | Description | Access |
|--------|----------|-------------|--------|
| GET | `/teacher/dashboard` | Teacher dashboard | Teacher |
| POST | `/teacher/grade` | Grade submission | Teacher |

### Admin Endpoints
| Method | Endpoint | Description | Access |
|--------|----------|-------------|--------|
| GET | `/admin/dashboard` | Admin dashboard | Admin |

---

## ⚡ Multithreading Implementation

### 1. Connection Pool (ArrayBlockingQueue)
```java
private BlockingQueue<Connection> connectionPool;
private BlockingQueue<Connection> usedConnections;

// Thread-safe connection management
public Connection getConnection() throws SQLException {
    Connection conn = connectionPool.poll(maxWaitTime, TimeUnit.MILLISECONDS);
    if (conn != null) {
        usedConnections.offer(conn);
    }
    return conn;
}
```

**Features:**
- ✅ Initial pool size: 5 connections
- ✅ Maximum pool size: 20 connections
- ✅ Thread-safe blocking queue
- ✅ Connection timeout: 10 seconds
- ✅ Automatic connection reuse
- ✅ Graceful pool shutdown

### 2. File Upload Handler (ExecutorService)
```java
private ExecutorService executorService;

// Async file processing with thread pool
executorService = Executors.newFixedThreadPool(5);

// Process file uploads asynchronously
executorService.submit(() -> {
    // File validation and storage
});
```

**Features:**
- ✅ 5 worker threads for file processing
- ✅ Async upload handling
- ✅ File size validation (max 10MB)
- ✅ File type validation (PDF, DOCX, ZIP)
- ✅ Unique filename generation
- ✅ Graceful shutdown on context destroy

---

## 🔧 Troubleshooting

### Issue: 404 Not Found on /login
**Cause**: PostgreSQL JDBC driver not loaded  
**Solution**:
```bash
# Check db.properties
cat WEB-INF/classes/db.properties | grep db.driver
# Should show: db.driver=org.postgresql.Driver

# If incorrect, update and redeploy
cp database/db.properties WEB-INF/classes/
./deploy.sh
```

### Issue: Database Connection Errors
**Cause**: Network issues or incorrect credentials  
**Solution**:
```bash
# Test connection
PGPASSWORD='npg_8Wts4DNhpeRY' psql \
  -h ep-floral-bush-a1ft2sv2-pooler.ap-southeast-1.aws.neon.tech \
  -U neondb_owner \
  -d neondb \
  -c "SELECT 1;"

# Check internet connection
ping ep-floral-bush-a1ft2sv2-pooler.ap-southeast-1.aws.neon.tech
```

### Issue: Tomcat Not Starting
**Cause**: Port 8080 already in use  
**Solution**:
```bash
# Check port
lsof -i :8080

# Kill process if needed
kill -9 <PID>

# Restart Tomcat
/opt/homebrew/opt/tomcat@9/libexec/bin/startup.sh
```

### Issue: Login Fails with Correct Credentials
**Cause**: Passwords not properly hashed  
**Solution**:
```sql
-- Connect to database
PGPASSWORD='npg_8Wts4DNhpeRY' psql \
  -h ep-floral-bush-a1ft2sv2-pooler.ap-southeast-1.aws.neon.tech \
  -U neondb_owner \
  -d neondb

-- Check user passwords (should be MD5 hashes)
SELECT username, password FROM users;

-- If needed, reset password
UPDATE users SET password = md5('admin123') WHERE username = 'admin';
```

### Issue: JSP Pages Not Loading
**Cause**: JSP files not deployed  
**Solution**:
```bash
# Check deployed JSP files
ls -la /opt/homebrew/opt/tomcat@9/libexec/webapps/assignment-portal/jsp/

# Redeploy if missing
./deploy.sh
```

### Issue: File Upload Fails
**Cause**: Missing uploads directory  
**Solution**:
```bash
# Check uploads directory
ls -la /opt/homebrew/opt/tomcat@9/libexec/webapps/assignment-portal/uploads/

# Create if missing
mkdir -p /opt/homebrew/opt/tomcat@9/libexec/webapps/assignment-portal/uploads/
chmod 755 /opt/homebrew/opt/tomcat@9/libexec/webapps/assignment-portal/uploads/
```

---

## 📈 Current Database Statistics

Run `./monitor.sh` to see real-time statistics:

- **Users**: 3 (1 Admin, 1 Teacher, 1 Student)
- **Courses**: 2 (CS101, CS201)
- **Assignments**: 3 
- **Submissions**: 0 (ready for testing)
- **Enrollments**: 2 (Alice enrolled in both courses)

---

## 🎓 Academic Features

### Grading System
- Assignments have configurable max marks (default: 100)
- Teachers can assign marks and provide textual feedback
- Students can view grades and feedback on their dashboard
- Late submissions are automatically flagged based on due date
- Average grade calculation per student

### File Management
- **Supported Formats**: PDF, DOCX, DOC, ZIP, RAR
- **Maximum File Size**: 10MB (configurable)
- **Storage**: Server filesystem with unique naming
- **Async Processing**: Background thread pool for uploads
- **Validation**: File type and size validation before upload

### Security Features
- **Password Hashing**: MD5 (for demo - use BCrypt in production)
- **Role-Based Access**: Separate dashboards for Student/Teacher/Admin
- **Session Management**: 30-minute timeout
- **HTTP-Only Cookies**: Prevents XSS attacks
- **Input Validation**: SQL injection prevention
- **Sanitization**: XSS prevention in user inputs

### Analytics & Reporting
- Student progress tracking
- Teacher assignment overview
- Admin system analytics
- Activity logging for auditing
- Enrollment statistics

---

## 🚀 Testing the Application

### 1. Test Login Flow
```
1. Go to http://localhost:8080/assignment-portal/
2. Click "Get Started →"
3. Login with: admin / admin123
4. Should see Admin Dashboard
```

### 2. Test Student Dashboard
```
1. Logout from admin
2. Login with: alice.brown / student123
3. Should see:
   - 2 Enrolled Courses
   - 3 Pending Assignments
   - Course details for CS101 and CS201
```

### 3. Test Teacher Dashboard
```
1. Logout
2. Login with: john.smith / teacher123
3. Should see:
   - 2 Courses
   - 3 Assignments created
   - 1 Student enrolled
```

### 4. Test Database Connection
```bash
./monitor.sh show-users
# Should display all 3 users
```

---

## 🔄 Deployment Workflow

### Development Cycle
1. **Edit Java Files** in `WEB-INF/classes/`
2. **Compile**: `./compile.sh`
3. **Deploy**: `./deploy.sh`
4. **Restart**: `./monitor.sh restart-tomcat`
5. **Test**: Open browser

### Quick Deployment
```bash
# One-liner for redeploy
./compile.sh && export CATALINA_HOME=/opt/homebrew/opt/tomcat@9/libexec && ./deploy.sh && ./monitor.sh restart-tomcat
```

---

## 🌟 Future Enhancements

### Short Term
- [ ] Email notifications for new assignments
- [ ] PDF preview for submissions
- [ ] Assignment deadline countdown
- [ ] Bulk grading interface
- [ ] Export grades to CSV

### Long Term
- [ ] Real-time notifications using WebSockets
- [ ] Mobile responsive design
- [ ] Dark mode theme
- [ ] Advanced analytics dashboard
- [ ] Integration with Learning Management Systems (LMS)
- [ ] Video submission support
- [ ] Plagiarism detection
- [ ] Discussion forums per course

---

## 📝 Important Files

### Configuration Files
- `database/db.properties` - Database connection settings
- `WEB-INF/web.xml` - Servlet mappings and configuration
- `WEB-INF/classes/db.properties` - Deployed database config

### Script Files
- `compile.sh` - Compiles all Java files
- `deploy.sh` - Deploys application to Tomcat
- `monitor.sh` - System monitoring dashboard
- `setup.sh` - Initial database setup

### Database Files
- `database/schema-postgres.sql` - PostgreSQL schema (CURRENT)
- `database/schema.sql` - Old MySQL schema (DEPRECATED)

---

## 🎯 Project Checklist

- ✅ Database schema created (8 tables, 3 views)
- ✅ User authentication implemented
- ✅ Role-based access control working
- ✅ Student dashboard functional
- ✅ Teacher dashboard functional
- ✅ Admin dashboard functional
- ✅ File upload system ready
- ✅ Grading system implemented
- ✅ Multithreading (Connection Pool) ✓
- ✅ Multithreading (File Upload) ✓
- ✅ Deployed to Tomcat
- ✅ Connected to Neon PostgreSQL
- ✅ Monitoring dashboard created
- ✅ Documentation complete

---

## 📞 Quick Reference

### Start Application
```bash
/opt/homebrew/opt/tomcat@9/libexec/bin/startup.sh
```

### Stop Application
```bash
/opt/homebrew/opt/tomcat@9/libexec/bin/shutdown.sh
```

### View Logs
```bash
tail -f /opt/homebrew/opt/tomcat@9/libexec/logs/catalina.out
```

### Monitor Status
```bash
./monitor.sh
```

### Access Application
```
http://localhost:8080/assignment-portal/
```

---

## 👨‍💻 Development Information

- **Project Name**: Java Assignment Portal with Multithreading
- **Date Created**: November 17, 2025
- **Status**: ✅ Fully Functional and Tested
- **Environment**: macOS, Java 25.0.1, Tomcat 9.0.112
- **Database**: Neon PostgreSQL (Cloud)

---

## 📄 License

This is an educational project created for academic purposes.

---

**🎉 Application Status: FULLY OPERATIONAL**

**Access Now**: http://localhost:8080/assignment-portal/

**Login**: Use any of the demo accounts listed above

**Support**: Run `./monitor.sh` for system status and diagnostics

---

*Last Updated: November 17, 2025*
