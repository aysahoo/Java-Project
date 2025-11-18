# Development Guide - Assignment Portal

Complete guide for developers working on the Assignment Portal project.

## 📋 Table of Contents
- [Development Environment Setup](#development-environment-setup)
- [Project Structure](#project-structure)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Adding New Features](#adding-new-features)
- [Testing](#testing)
- [Debugging](#debugging)
- [Best Practices](#best-practices)
- [Common Tasks](#common-tasks)

## 💻 Development Environment Setup

### IDE Setup

#### IntelliJ IDEA (Recommended)

1. **Install IntelliJ IDEA:**
   - Download Community or Ultimate edition
   - Ultimate has better Java EE support

2. **Import Project:**
   ```
   File → Open → Select assignment-portal directory
   ```

3. **Configure Tomcat:**
   ```
   Run → Edit Configurations → + → Tomcat Server → Local
   - CATALINA_HOME: /path/to/tomcat
   - Deployment: Add artifact → assignment-portal:war exploded
   ```

4. **Configure JDK:**
   ```
   File → Project Structure → Project
   - Project SDK: Select JDK 11 or higher
   - Project language level: 8 or higher
   ```

5. **Enable Auto-Reload:**
   ```
   Run → Edit Configurations → Tomcat → On 'Update' action: Update classes and resources
   ```

#### Eclipse IDE

1. **Install Eclipse IDE for Enterprise Java Developers**

2. **Import Project:**
   ```
   File → Import → Existing Projects into Workspace
   ```

3. **Configure Tomcat:**
   ```
   Window → Preferences → Server → Runtime Environments
   Add → Apache Tomcat v9.0 → Select installation directory
   ```

4. **Add to Server:**
   ```
   Right-click project → Run As → Run on Server
   ```

#### VS Code

1. **Install Extensions:**
   - Extension Pack for Java (Microsoft)
   - Tomcat for Java
   - Java Debugger

2. **Configure:**
   ```json
   // .vscode/settings.json
   {
     "java.configuration.runtimes": [
       {
         "name": "JavaSE-11",
         "path": "/path/to/jdk-11"
       }
     ]
   }
   ```

### Database Setup for Development

1. **Install MySQL Workbench** (Optional but recommended)
   ```bash
   brew install --cask mysql-workbench  # macOS
   ```

2. **Create Development Database:**
   ```sql
   CREATE DATABASE assignment_portal_dev;
   ```

3. **Use Separate Config:**
   ```properties
   # db-dev.properties
   db.url=jdbc:mysql://localhost:3306/assignment_portal_dev
   db.username=dev_user
   db.password=dev_password
   ```

### Version Control

**Initialize Git (if not already done):**
```bash
cd assignment-portal
git init
git add .
git commit -m "Initial commit"
```

**Configure `.gitignore`:**
```gitignore
# Compiled files
*.class
WEB-INF/classes/**/*.class

# IDE files
.idea/
.vscode/
*.iml
.project
.classpath
.settings/

# Build files
target/
build/
dist/

# Logs
*.log
logs/

# Database
*.sql.backup
cookies.txt

# OS files
.DS_Store
Thumbs.db

# Sensitive files
db.properties
```

## 📂 Project Structure

### Source Organization

```
WEB-INF/classes/com/assignmentportal/
│
├── model/              # Data models (POJOs)
│   ├── User.java
│   ├── Course.java
│   ├── Assignment.java
│   ├── Submission.java
│   └── Enrollment.java
│
├── dao/                # Data Access Objects
│   ├── UserDAO.java
│   ├── CourseDAO.java
│   ├── AssignmentDAO.java
│   └── SubmissionDAO.java
│
├── servlet/            # Servlets (Controllers)
│   ├── LoginServlet.java
│   ├── LogoutServlet.java
│   ├── StudentDashboardServlet.java
│   ├── TeacherDashboardServlet.java
│   ├── AdminDashboardServlet.java
│   ├── SubmitAssignmentServlet.java
│   └── GradeSubmissionServlet.java
│
└── util/               # Utility classes
    ├── DatabaseConnectionPool.java
    ├── FileUploadHandler.java
    └── ValidationUtil.java
```

### Configuration Files

```
WEB-INF/
├── web.xml             # Deployment descriptor
└── classes/
    └── db.properties   # Database configuration
```

### View Files

```
jsp/
├── login.jsp
├── student-dashboard.jsp
├── teacher-dashboard.jsp
└── admin-dashboard.jsp
```

## 🔄 Development Workflow

### 1. Start Development

```bash
# Pull latest changes
git pull origin main

# Create feature branch
git checkout -b feature/your-feature-name

# Start development
```

### 2. Make Changes

Follow this order:
1. **Model** - Add/modify data structures
2. **DAO** - Add/modify database operations
3. **Servlet** - Add/modify business logic
4. **JSP** - Add/modify UI

### 3. Test Changes

```bash
# Compile
./compile.sh

# Check for errors
# Fix any compilation errors

# Deploy to local Tomcat
./deploy.sh

# Test in browser
open http://localhost:8080/assignment-portal/
```

### 4. Commit Changes

```bash
# Add files
git add .

# Commit with descriptive message
git commit -m "Add feature: <description>"

# Push to remote
git push origin feature/your-feature-name
```

### 5. Create Pull Request

- Go to GitHub
- Create pull request from your branch to main
- Request code review
- Merge after approval

## 📝 Coding Standards

### Java Code Style

**Naming Conventions:**

```java
// Classes: PascalCase
public class StudentDashboardServlet {}

// Methods: camelCase
public void getStudentCourses() {}

// Variables: camelCase
private String userName;
private int userId;

// Constants: UPPER_SNAKE_CASE
private static final int MAX_FILE_SIZE = 10485760;
private static final String DEFAULT_ROLE = "STUDENT";

// Packages: lowercase
package com.assignmentportal.servlet;
```

**Code Formatting:**

```java
// Indentation: 4 spaces
public class Example {
    private int value;
    
    public void method() {
        if (condition) {
            // code
        } else {
            // code
        }
    }
}

// Braces: Same line for control structures
if (condition) {
    // code
}

// Braces: New line for methods and classes
public void method() 
{
    // Alternative style (choose one and be consistent)
}
```

**Comments:**

```java
/**
 * JavaDoc for classes and public methods
 * 
 * @param userId The ID of the user
 * @return User object or null if not found
 * @throws SQLException if database error occurs
 */
public User getUserById(int userId) throws SQLException {
    // Implementation comments for complex logic
    Connection conn = null;
    try {
        // Get connection from pool
        conn = connectionPool.getConnection();
        
        // Execute query
        // ...
    } finally {
        // Always release connection
        connectionPool.releaseConnection(conn);
    }
}
```

### SQL Coding Standards

```java
// Use uppercase for SQL keywords
String sql = "SELECT * FROM users WHERE username = ?";

// Format complex queries
String sql = "SELECT u.user_id, u.full_name, c.course_name " +
            "FROM users u " +
            "JOIN enrollments e ON u.user_id = e.student_id " +
            "JOIN courses c ON e.course_id = c.course_id " +
            "WHERE u.user_id = ?";

// Always use PreparedStatement
PreparedStatement pstmt = conn.prepareStatement(sql);
pstmt.setInt(1, userId);
```

### JSP Coding Standards

```jsp
<%-- Comments use JSP comment syntax --%>

<%-- Always specify page directives --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.assignmentportal.model.User" %>

<%-- Use JSTL when possible --%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- Escape output to prevent XSS --%>
<c:out value="${user.fullName}" />

<%-- Keep Java code minimal in JSP --%>
<%-- Business logic belongs in servlets --%>
```

## ✨ Adding New Features

### Example: Add "Course Announcements" Feature

#### Step 1: Create Model

```java
// WEB-INF/classes/com/assignmentportal/model/Announcement.java
package com.assignmentportal.model;

import java.sql.Timestamp;

public class Announcement {
    private int announcementId;
    private int courseId;
    private String title;
    private String content;
    private int createdBy;
    private Timestamp createdAt;
    
    // Constructors
    public Announcement() {}
    
    public Announcement(int courseId, String title, String content, int createdBy) {
        this.courseId = courseId;
        this.title = title;
        this.content = content;
        this.createdBy = createdBy;
    }
    
    // Getters and setters
    public int getAnnouncementId() { return announcementId; }
    public void setAnnouncementId(int announcementId) { 
        this.announcementId = announcementId; 
    }
    
    // ... more getters/setters
}
```

#### Step 2: Update Database Schema

```sql
-- database/add_announcements.sql
CREATE TABLE announcements (
    announcement_id INT PRIMARY KEY AUTO_INCREMENT,
    course_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_course (course_id),
    INDEX idx_created_at (created_at)
);
```

```bash
# Apply migration
mysql -u root -p assignment_portal < database/add_announcements.sql
```

#### Step 3: Create DAO

```java
// WEB-INF/classes/com/assignmentportal/dao/AnnouncementDAO.java
package com.assignmentportal.dao;

import com.assignmentportal.model.Announcement;
import com.assignmentportal.util.DatabaseConnectionPool;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AnnouncementDAO {
    private DatabaseConnectionPool connectionPool;
    
    public AnnouncementDAO() {
        this.connectionPool = DatabaseConnectionPool.getInstance();
    }
    
    public int createAnnouncement(Announcement announcement) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = connectionPool.getConnection();
            String sql = "INSERT INTO announcements (course_id, title, content, created_by) " +
                        "VALUES (?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            pstmt.setInt(1, announcement.getCourseId());
            pstmt.setString(2, announcement.getTitle());
            pstmt.setString(3, announcement.getContent());
            pstmt.setInt(4, announcement.getCreatedBy());
            
            int rowsAffected = pstmt.executeUpdate();
            if (rowsAffected > 0) {
                rs = pstmt.getGeneratedKeys();
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
            return -1;
        } finally {
            closeResources(rs, pstmt, conn);
        }
    }
    
    public List<Announcement> getAnnouncementsByCourse(int courseId) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<Announcement> announcements = new ArrayList<>();
        
        try {
            conn = connectionPool.getConnection();
            String sql = "SELECT * FROM announcements WHERE course_id = ? " +
                        "ORDER BY created_at DESC";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, courseId);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                announcements.add(extractAnnouncementFromResultSet(rs));
            }
            return announcements;
        } finally {
            closeResources(rs, pstmt, conn);
        }
    }
    
    private Announcement extractAnnouncementFromResultSet(ResultSet rs) 
            throws SQLException {
        Announcement announcement = new Announcement();
        announcement.setAnnouncementId(rs.getInt("announcement_id"));
        announcement.setCourseId(rs.getInt("course_id"));
        announcement.setTitle(rs.getString("title"));
        announcement.setContent(rs.getString("content"));
        announcement.setCreatedBy(rs.getInt("created_by"));
        announcement.setCreatedAt(rs.getTimestamp("created_at"));
        return announcement;
    }
    
    private void closeResources(ResultSet rs, PreparedStatement pstmt, Connection conn) {
        try { if (rs != null) rs.close(); } catch (SQLException e) {}
        try { if (pstmt != null) pstmt.close(); } catch (SQLException e) {}
        if (conn != null) connectionPool.releaseConnection(conn);
    }
}
```

#### Step 4: Create Servlet

```java
// WEB-INF/classes/com/assignmentportal/servlet/AnnouncementServlet.java
package com.assignmentportal.servlet;

import com.assignmentportal.dao.AnnouncementDAO;
import com.assignmentportal.model.Announcement;
import com.assignmentportal.model.User;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

public class AnnouncementServlet extends HttpServlet {
    private AnnouncementDAO announcementDAO;
    
    @Override
    public void init() throws ServletException {
        announcementDAO = new AnnouncementDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }
        
        String courseIdStr = request.getParameter("courseId");
        if (courseIdStr == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Course ID required");
            return;
        }
        
        try {
            int courseId = Integer.parseInt(courseIdStr);
            List<Announcement> announcements = 
                announcementDAO.getAnnouncementsByCourse(courseId);
            
            request.setAttribute("announcements", announcements);
            request.setAttribute("courseId", courseId);
            request.getRequestDispatcher("/jsp/announcements.jsp")
                   .forward(request, response);
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Unable to load announcements");
            request.getRequestDispatcher("/jsp/error.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");
        
        if (user == null || !"TEACHER".equals(user.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        
        String courseIdStr = request.getParameter("courseId");
        String title = request.getParameter("title");
        String content = request.getParameter("content");
        
        // Validate input
        if (courseIdStr == null || title == null || title.trim().isEmpty() ||
            content == null || content.trim().isEmpty()) {
            request.setAttribute("error", "All fields are required");
            doGet(request, response);
            return;
        }
        
        try {
            int courseId = Integer.parseInt(courseIdStr);
            Announcement announcement = new Announcement(courseId, title, content, 
                                                        user.getUserId());
            int id = announcementDAO.createAnnouncement(announcement);
            
            if (id > 0) {
                response.sendRedirect("announcements?courseId=" + courseId + 
                                     "&success=Announcement created");
            } else {
                request.setAttribute("error", "Failed to create announcement");
                doGet(request, response);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
            doGet(request, response);
        }
    }
}
```

#### Step 5: Update web.xml

```xml
<!-- Add servlet definition -->
<servlet>
    <servlet-name>AnnouncementServlet</servlet-name>
    <servlet-class>com.assignmentportal.servlet.AnnouncementServlet</servlet-class>
</servlet>

<servlet-mapping>
    <servlet-name>AnnouncementServlet</servlet-name>
    <url-pattern>/announcements</url-pattern>
</servlet-mapping>
```

#### Step 6: Create JSP View

```jsp
<%-- jsp/announcements.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.assignmentportal.model.Announcement" %>
<%@ page import="com.assignmentportal.model.User" %>

<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login");
        return;
    }
    
    List<Announcement> announcements = 
        (List<Announcement>) request.getAttribute("announcements");
    Integer courseId = (Integer) request.getAttribute("courseId");
%>

<!DOCTYPE html>
<html>
<head>
    <title>Course Announcements</title>
</head>
<body>
    <h1>Course Announcements</h1>
    
    <%-- Display announcements --%>
    <% if (announcements != null && !announcements.isEmpty()) { %>
        <% for (Announcement ann : announcements) { %>
            <div class="announcement">
                <h3><%= ann.getTitle() %></h3>
                <p><%= ann.getContent() %></p>
                <small>Posted: <%= ann.getCreatedAt() %></small>
            </div>
        <% } %>
    <% } else { %>
        <p>No announcements yet.</p>
    <% } %>
    
    <%-- Form for teachers to create announcements --%>
    <% if ("TEACHER".equals(user.getRole())) { %>
        <h2>Create Announcement</h2>
        <form method="post" action="announcements">
            <input type="hidden" name="courseId" value="<%= courseId %>">
            <input type="text" name="title" placeholder="Title" required>
            <textarea name="content" placeholder="Content" required></textarea>
            <button type="submit">Post Announcement</button>
        </form>
    <% } %>
</body>
</html>
```

#### Step 7: Compile and Deploy

```bash
# Compile
./compile.sh

# Deploy
./deploy.sh

# Test
# Visit: http://localhost:8080/assignment-portal/announcements?courseId=1
```

## 🧪 Testing

### Manual Testing Checklist

- [ ] Login with all roles (Student, Teacher, Admin)
- [ ] Access all dashboards
- [ ] Submit assignment (various file types and sizes)
- [ ] Grade submission
- [ ] Test concurrent access (multiple browsers)
- [ ] Test session timeout
- [ ] Test invalid inputs
- [ ] Test file upload limits

### Database Testing

```sql
-- Test data insertion
INSERT INTO users (username, password, email, full_name, role)
VALUES ('test.user', SHA2('test123', 256), 'test@test.com', 'Test User', 'STUDENT');

-- Verify
SELECT * FROM users WHERE username = 'test.user';

-- Clean up
DELETE FROM users WHERE username = 'test.user';
```

### Load Testing

```bash
# Install Apache Bench
brew install httpd  # macOS

# Simple load test (100 requests, 10 concurrent)
ab -n 100 -c 10 http://localhost:8080/assignment-portal/
```

## 🐛 Debugging

### Enable Detailed Logging

```java
// Add to servlet
System.out.println("DEBUG: User ID = " + userId);
System.out.println("DEBUG: Query = " + sql);

// Or use logging framework
import java.util.logging.Logger;

private static final Logger logger = Logger.getLogger(ClassName.class.getName());
logger.info("Processing request for user: " + username);
logger.warning("Failed to connect to database");
logger.severe("Critical error: " + e.getMessage());
```

### View Tomcat Logs

```bash
# Real-time log viewing
tail -f $CATALINA_HOME/logs/catalina.out

# View all logs
ls -la $CATALINA_HOME/logs/

# Search for errors
grep -i "error" $CATALINA_HOME/logs/catalina.out
grep -i "exception" $CATALINA_HOME/logs/catalina.out
```

### Debug Database Queries

```java
// Print query before execution
System.out.println("Executing query: " + sql);
System.out.println("Parameters: " + Arrays.toString(parameters));

// Check connection pool
System.out.println("Available connections: " + 
                  connectionPool.getAvailableConnectionCount());
```

### Browser Developer Tools

1. Open DevTools (F12)
2. Check Network tab for:
   - HTTP status codes
   - Request/response headers
   - Form data
3. Check Console for JavaScript errors

## 📚 Best Practices

### Security

- ✅ Always use PreparedStatement (never string concatenation)
- ✅ Validate all user input
- ✅ Hash passwords (SHA-256 or better: BCrypt)
- ✅ Use HTTPS in production
- ✅ Set secure session cookies
- ✅ Implement CSRF protection for forms
- ✅ Validate file uploads (type, size)
- ✅ Store files outside web root

### Performance

- ✅ Use connection pooling
- ✅ Close resources in finally blocks
- ✅ Use database indexes
- ✅ Minimize database queries
- ✅ Cache frequently accessed data
- ✅ Use pagination for large result sets

### Code Quality

- ✅ Follow DRY principle (Don't Repeat Yourself)
- ✅ Use meaningful variable names
- ✅ Keep methods short and focused
- ✅ Write JavaDoc for public APIs
- ✅ Handle exceptions properly
- ✅ Use appropriate data structures

## 🔧 Common Tasks

### Add New User Role

1. Update User model enum
2. Update database schema
3. Add role-specific servlets
4. Add role checks in existing servlets
5. Create role-specific JSP pages

### Add New Database Table

1. Create SQL migration file
2. Apply migration
3. Create Model class
4. Create DAO class
5. Update related servlets

### Modify UI

1. Edit JSP files in `jsp/`
2. Add CSS styles
3. Test in multiple browsers
4. Ensure mobile responsiveness

---

**Happy coding! 👨‍💻**
