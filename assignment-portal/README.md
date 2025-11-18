# Assignment Portal - Java Web Application

[![Java](https://img.shields.io/badge/Java-8%2B-orange.svg)](https://www.oracle.com/java/)
[![Servlet](https://img.shields.io/badge/Servlet-4.0-blue.svg)](https://javaee.github.io/servlet-spec/)
[![MySQL](https://img.shields.io/badge/MySQL-8.0-blue.svg)](https://www.mysql.com/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## 📋 Table of Contents
- [Overview](#overview)
- [Features](#features)
- [System Architecture](#system-architecture)
- [Technology Stack](#technology-stack)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Documentation](#documentation)
- [Default Credentials](#default-credentials)
- [Contributing](#contributing)
- [License](#license)

## 🎯 Overview

The **Assignment Portal** is a comprehensive web-based application built with Java Servlets and JSP for managing academic assignments. It provides a complete solution for students to submit assignments, teachers to grade submissions, and administrators to manage the entire system. The application features a custom-built **thread-safe connection pool** for efficient database management and supports **file uploads** with validation.

### Key Highlights
- 🔐 **Role-Based Access Control** (Student, Teacher, Admin)
- 📁 **File Upload System** with validation (max 10MB)
- 🔄 **Custom Database Connection Pool** using multithreading
- 📊 **Real-time Dashboard** for all user roles
- ⚡ **Thread-Safe Operations** for concurrent user access
- 🎨 **Responsive UI** with modern design

## ✨ Features

### For Students 👨‍🎓
- ✅ View enrolled courses and assignments
- 📤 Submit assignments with file uploads (PDF, DOCX, ZIP)
- 📊 Track submission status and grades
- 🕐 View submission deadlines and late submission indicators
- 📈 Monitor academic performance and average grades

### For Teachers 👨‍🏫
- ✅ Create and manage courses
- 📝 Create assignments with customizable settings
- 📥 View all student submissions
- ✍️ Grade submissions with feedback
- 📊 Track course and assignment analytics
- 👥 View enrolled students

### For Administrators 🔧
- ✅ Manage users (create, update, deactivate)
- 📚 Oversee all courses and assignments
- 📊 System-wide analytics and reporting
- 🔍 Activity log monitoring
- 🛠️ System configuration management

## 🏗️ System Architecture

The application follows a **3-tier architecture**:

```
┌─────────────────────────────────────────┐
│        Presentation Layer (JSP)          │
│  - login.jsp                             │
│  - student-dashboard.jsp                 │
│  - teacher-dashboard.jsp                 │
│  - admin-dashboard.jsp                   │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│      Business Logic Layer (Servlets)     │
│  - LoginServlet                          │
│  - StudentDashboardServlet               │
│  - TeacherDashboardServlet               │
│  - SubmitAssignmentServlet               │
│  - GradeSubmissionServlet                │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│       Data Access Layer (DAO)            │
│  - UserDAO                               │
│  - CourseDAO                             │
│  - AssignmentDAO                         │
│  - SubmissionDAO                         │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│         Database (MySQL)                 │
│  - users                                 │
│  - courses                               │
│  - assignments                           │
│  - submissions                           │
│  - enrollments                           │
│  - activity_log                          │
└─────────────────────────────────────────┘
```

### Key Architectural Components

1. **Connection Pool Manager** (`DatabaseConnectionPool.java`)
   - Thread-safe connection pooling using `BlockingQueue`
   - Configurable pool size (initial: 5, max: 20)
   - Automatic connection reuse and management

2. **Model Layer** (`com.assignmentportal.model`)
   - User, Course, Assignment, Submission, Enrollment
   - POJO classes with getters/setters

3. **DAO Layer** (`com.assignmentportal.dao`)
   - Database abstraction
   - CRUD operations for all entities
   - Prepared statements for SQL injection prevention

4. **Servlet Layer** (`com.assignmentportal.servlet`)
   - Request handling and routing
   - Session management
   - File upload handling

5. **Utility Layer** (`com.assignmentportal.util`)
   - File upload validation
   - Input validation
   - Helper functions

## 🛠️ Technology Stack

### Backend
- **Java 8+** - Core programming language
- **Java Servlets 4.0** - Web application framework
- **JSP (JavaServer Pages)** - Dynamic web pages
- **JDBC** - Database connectivity
- **MySQL 8.0** - Relational database

### Frontend
- **HTML5** - Markup
- **CSS3** - Styling with modern gradients
- **JavaScript** - Client-side interactions

### Server
- **Apache Tomcat 9.0+** - Servlet container

### Build & Deployment
- **Bash Scripts** - Automated compilation and deployment
- **Shell Scripting** - Setup automation

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

1. **Java Development Kit (JDK) 8 or higher**
   ```bash
   java -version
   javac -version
   ```

2. **Apache Tomcat 9.0+**
   - Download from: https://tomcat.apache.org/download-90.cgi
   - Set `CATALINA_HOME` environment variable

3. **MySQL 8.0+**
   ```bash
   mysql --version
   ```

4. **MySQL Connector/J**
   - Download from: https://dev.mysql.com/downloads/connector/j/
   - Place JAR file in `WEB-INF/lib/`

5. **Git** (optional, for version control)
   ```bash
   git --version
   ```

## 🚀 Quick Start

### 1. Clone or Download the Project
```bash
git clone https://github.com/aysahoo/Java-Project.git
cd Java-Project/assignment-portal
```

### 2. Configure Database
Edit `database/db.properties` with your MySQL credentials:
```properties
db.url=jdbc:mysql://localhost:3306/assignment_portal
db.username=root
db.password=your_password
```

### 3. Run Complete Setup
The easiest way to get started is using the automated setup script:
```bash
chmod +x setup.sh
./setup.sh
```

This script will:
- ✅ Check all prerequisites
- ✅ Create the database and tables
- ✅ Insert sample data
- ✅ Compile all Java files
- ✅ Deploy to Tomcat
- ✅ Start the server

### 4. Access the Application
Open your browser and navigate to:
```
http://localhost:8080/assignment-portal/
```

### Manual Setup (Alternative)

If you prefer manual setup:

**Step 1: Setup Database**
```bash
mysql -u root -p < database/schema.sql
```

**Step 2: Compile**
```bash
chmod +x compile.sh
./compile.sh
```

**Step 3: Deploy**
```bash
chmod +x deploy.sh
./deploy.sh
```

**Step 4: Start Tomcat**
```bash
$CATALINA_HOME/bin/startup.sh
```

## 📁 Project Structure

```
assignment-portal/
│
├── README.md                          # This file
├── SETUP.md                           # Detailed setup guide
├── ARCHITECTURE.md                    # System architecture documentation
├── API.md                             # API and servlet endpoints
├── DATABASE.md                        # Database schema and design
├── DEVELOPMENT.md                     # Development guide
├── DEPLOYMENT.md                      # Deployment instructions
├── TROUBLESHOOTING.md                 # Common issues and solutions
│
├── index.html                         # Landing page
├── setup.sh                          # Complete setup script
├── compile.sh                        # Compilation script
├── deploy.sh                         # Deployment script
├── monitor.sh                        # Monitoring script
├── cookies.txt                       # Session cookies (generated)
│
├── database/                         # Database files
│   ├── schema.sql                    # MySQL schema
│   ├── schema-postgres.sql           # PostgreSQL schema (alternative)
│   └── db.properties                 # Database configuration
│
├── jsp/                              # JSP pages
│   ├── login.jsp                     # Login page
│   ├── student-dashboard.jsp         # Student dashboard
│   ├── teacher-dashboard.jsp         # Teacher dashboard
│   └── admin-dashboard.jsp           # Admin dashboard
│
└── WEB-INF/                          # Web application resources
    ├── web.xml                       # Deployment descriptor
    │
    ├── classes/                      # Compiled Java classes
    │   ├── db.properties             # Runtime configuration
    │   └── com/assignmentportal/
    │       ├── model/                # Data models
    │       │   ├── User.java
    │       │   ├── Course.java
    │       │   ├── Assignment.java
    │       │   ├── Submission.java
    │       │   └── Enrollment.java
    │       │
    │       ├── dao/                  # Data Access Objects
    │       │   ├── UserDAO.java
    │       │   ├── CourseDAO.java
    │       │   ├── AssignmentDAO.java
    │       │   └── SubmissionDAO.java
    │       │
    │       ├── servlet/              # Servlets
    │       │   ├── LoginServlet.java
    │       │   ├── LogoutServlet.java
    │       │   ├── StudentDashboardServlet.java
    │       │   ├── TeacherDashboardServlet.java
    │       │   ├── AdminDashboardServlet.java
    │       │   ├── SubmitAssignmentServlet.java
    │       │   └── GradeSubmissionServlet.java
    │       │
    │       └── util/                 # Utility classes
    │           ├── DatabaseConnectionPool.java
    │           ├── FileUploadHandler.java
    │           └── ValidationUtil.java
    │
    └── lib/                          # External libraries
        └── mysql-connector-j-*.jar   # MySQL JDBC driver
```

## 📚 Documentation

This project includes comprehensive documentation:

- **[SETUP.md](SETUP.md)** - Detailed installation and configuration guide
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - System design and architecture
- **[DATABASE.md](DATABASE.md)** - Database schema, tables, and relationships
- **[API.md](API.md)** - Servlet endpoints and API documentation
- **[DEVELOPMENT.md](DEVELOPMENT.md)** - Development workflow and best practices
- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Production deployment guide
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Common issues and solutions

## 🔑 Default Credentials

After running the setup, use these credentials to login:

### Administrator
- **Username:** `admin`
- **Password:** `admin123`
- **Email:** admin@assignment-portal.com

### Teacher
- **Username:** `john.smith`
- **Password:** `teacher123`
- **Email:** john.smith@university.edu

### Student
- **Username:** `alice.brown`
- **Password:** `student123`
- **Email:** alice.brown@student.edu

⚠️ **Important:** Change default passwords in production!

## 🔒 Security Features

- ✅ Password hashing using SHA-256
- ✅ SQL injection prevention with prepared statements
- ✅ Session-based authentication
- ✅ Role-based access control
- ✅ File upload validation (type, size)
- ✅ Input validation and sanitization
- ✅ XSS protection in JSP pages

## 🧪 Testing

Test the application with different scenarios:

1. **Login as different roles**
2. **Create and manage courses**
3. **Upload assignments** (try different file types and sizes)
4. **Grade submissions**
5. **View dashboards** (concurrent access testing)

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Author

**Ayush Ranjan Sahoo**
- GitHub: [@aysahoo](https://github.com/aysahoo)

## 🙏 Acknowledgments

- Java Servlet API documentation
- Apache Tomcat community
- MySQL documentation
- Stack Overflow community

## 📞 Support

For questions or issues:
- 📧 Email: support@assignment-portal.com
- 🐛 Issues: [GitHub Issues](https://github.com/aysahoo/Java-Project/issues)
- 📖 Documentation: See `docs/` folder

## 🎓 Learning Resources

If you're new to these technologies:
- [Java Servlets Tutorial](https://docs.oracle.com/javaee/7/tutorial/servlets.htm)
- [JSP Tutorial](https://docs.oracle.com/javaee/7/tutorial/jsf-intro.htm)
- [MySQL Tutorial](https://dev.mysql.com/doc/)
- [Tomcat Documentation](https://tomcat.apache.org/tomcat-9.0-doc/)

---

**Made with ❤️ using Java, Servlets, and MySQL**
