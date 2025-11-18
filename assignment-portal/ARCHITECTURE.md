# System Architecture - Assignment Portal

This document provides an in-depth look at the system architecture, design patterns, and implementation details of the Assignment Portal.

## 📋 Table of Contents
- [Architecture Overview](#architecture-overview)
- [Design Patterns](#design-patterns)
- [Application Layers](#application-layers)
- [Component Details](#component-details)
- [Multithreading Implementation](#multithreading-implementation)
- [Security Architecture](#security-architecture)
- [Data Flow](#data-flow)
- [Scalability Considerations](#scalability-considerations)

## 🏛️ Architecture Overview

The Assignment Portal follows a **3-tier layered architecture** pattern, separating concerns into distinct layers:

```
┌─────────────────────────────────────────────────────────┐
│                  CLIENT LAYER (Browser)                  │
│                    HTML5 + CSS3 + JS                     │
└───────────────────────┬─────────────────────────────────┘
                        │ HTTP/HTTPS
                        │
┌───────────────────────▼─────────────────────────────────┐
│              PRESENTATION LAYER (JSP)                    │
│  ┌─────────────────────────────────────────────────┐   │
│  │ login.jsp │ student-dashboard.jsp │             │   │
│  │ teacher-dashboard.jsp │ admin-dashboard.jsp     │   │
│  └─────────────────────────────────────────────────┘   │
└───────────────────────┬─────────────────────────────────┘
                        │
┌───────────────────────▼─────────────────────────────────┐
│           BUSINESS LOGIC LAYER (Servlets)                │
│  ┌─────────────────────────────────────────────────┐   │
│  │         Servlet Container (Tomcat)              │   │
│  │  ┌──────────────┐  ┌─────────────────────┐    │   │
│  │  │ LoginServlet │  │ SubmitAssignment    │    │   │
│  │  │ LogoutServlet│  │ GradeSubmission     │    │   │
│  │  │ Dashboard    │  │ Student/Teacher/    │    │   │
│  │  │ Servlets     │  │ AdminServlets       │    │   │
│  │  └──────────────┘  └─────────────────────┘    │   │
│  └─────────────────────────────────────────────────┘   │
│                        │                                 │
│  ┌─────────────────────▼─────────────────────────┐     │
│  │           Utility Components                   │     │
│  │  • FileUploadHandler                          │     │
│  │  • ValidationUtil                             │     │
│  │  • SessionManager                             │     │
│  └────────────────────────────────────────────────┘    │
└───────────────────────┬─────────────────────────────────┘
                        │
┌───────────────────────▼─────────────────────────────────┐
│            DATA ACCESS LAYER (DAO)                       │
│  ┌─────────────────────────────────────────────────┐   │
│  │ UserDAO │ CourseDAO │ AssignmentDAO │           │   │
│  │ SubmissionDAO │ EnrollmentDAO                   │   │
│  └──────────────────────┬──────────────────────────┘   │
│                         │                               │
│  ┌──────────────────────▼──────────────────────────┐   │
│  │    DatabaseConnectionPool (Thread-Safe)         │   │
│  │  ┌────────────────────────────────────────┐    │   │
│  │  │  BlockingQueue<Connection>             │    │   │
│  │  │  • Pool Size: 5-20 connections         │    │   │
│  │  │  • Connection Reuse                    │    │   │
│  │  │  • Timeout Management                  │    │   │
│  │  └────────────────────────────────────────┘    │   │
│  └─────────────────────────────────────────────────┘   │
└───────────────────────┬─────────────────────────────────┘
                        │ JDBC
┌───────────────────────▼─────────────────────────────────┐
│                 DATABASE LAYER (MySQL)                   │
│  ┌─────────────────────────────────────────────────┐   │
│  │ users │ courses │ assignments │ submissions     │   │
│  │ enrollments │ activity_log                      │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

## 🎨 Design Patterns

### 1. Model-View-Controller (MVC)

The application implements MVC pattern:

- **Model:** POJO classes in `com.assignmentportal.model`
  ```java
  User.java, Course.java, Assignment.java, Submission.java, Enrollment.java
  ```

- **View:** JSP pages in `jsp/`
  ```
  login.jsp, student-dashboard.jsp, teacher-dashboard.jsp, admin-dashboard.jsp
  ```

- **Controller:** Servlets in `com.assignmentportal.servlet`
  ```java
  LoginServlet, StudentDashboardServlet, SubmitAssignmentServlet, etc.
  ```

### 2. Data Access Object (DAO) Pattern

Abstracts database operations:

```java
// UserDAO.java
public class UserDAO {
    private DatabaseConnectionPool connectionPool;
    
    public User authenticate(String username, String password) {...}
    public boolean createUser(User user) {...}
    public User getUserById(int userId) {...}
    public List<User> getAllUsers() {...}
}
```

**Benefits:**
- ✅ Separation of business logic and data access
- ✅ Easier to test and maintain
- ✅ Database implementation can change without affecting business logic

### 3. Singleton Pattern

Used for DatabaseConnectionPool:

```java
public class DatabaseConnectionPool {
    private static DatabaseConnectionPool instance;
    
    private DatabaseConnectionPool() {
        loadConfiguration();
        initializePool();
    }
    
    public static synchronized DatabaseConnectionPool getInstance() {
        if (instance == null) {
            instance = new DatabaseConnectionPool();
        }
        return instance;
    }
}
```

**Benefits:**
- ✅ Single connection pool instance across application
- ✅ Resource efficiency
- ✅ Centralized configuration

### 4. Factory Pattern

Implicit in DAO object creation:

```java
public class DAOFactory {
    public static UserDAO getUserDAO() {
        return new UserDAO();
    }
    
    public static CourseDAO getCourseDAO() {
        return new CourseDAO();
    }
}
```

### 5. Front Controller Pattern

Implemented via `web.xml` servlet mappings:

```xml
<servlet-mapping>
    <servlet-name>LoginServlet</servlet-name>
    <url-pattern>/login</url-pattern>
</servlet-mapping>
```

All requests route through appropriate servlets based on URL patterns.

## 🎯 Application Layers

### 1. Presentation Layer (JSP)

**Responsibilities:**
- Display data to users
- Capture user input
- Minimal business logic (only presentation logic)

**Key Components:**
```
jsp/
├── login.jsp              # Authentication page
├── student-dashboard.jsp  # Student view
├── teacher-dashboard.jsp  # Teacher view
└── admin-dashboard.jsp    # Administrator view
```

**Example Structure:**
```jsp
<%@ page session="true" %>
<%@ page import="com.assignmentportal.model.User" %>

<%
    User user = (User) session.getAttribute("user");
    if (user == null || !user.getRole().equals("STUDENT")) {
        response.sendRedirect("login");
        return;
    }
%>

<!-- Display student dashboard -->
```

### 2. Business Logic Layer (Servlets)

**Responsibilities:**
- Process user requests
- Validate input
- Execute business rules
- Manage sessions
- Coordinate between presentation and data layers

**Key Components:**

#### Authentication Servlets
```java
LoginServlet.java    // User authentication
LogoutServlet.java   // Session termination
```

#### Student Servlets
```java
StudentDashboardServlet.java  // Display enrolled courses, assignments
SubmitAssignmentServlet.java  // Handle assignment submission
```

#### Teacher Servlets
```java
TeacherDashboardServlet.java  // Display courses, assignments
GradeSubmissionServlet.java   // Grade student submissions
```

#### Admin Servlets
```java
AdminDashboardServlet.java    // System administration
```

**Servlet Lifecycle:**
1. `init()` - Initialize DAO objects
2. `doGet()` - Handle GET requests (display forms)
3. `doPost()` - Handle POST requests (process forms)
4. `destroy()` - Cleanup resources

### 3. Data Access Layer (DAO)

**Responsibilities:**
- Database CRUD operations
- Query execution
- Result set mapping to objects
- Transaction management

**Key Components:**

```java
UserDAO.java         // User management
CourseDAO.java       // Course management
AssignmentDAO.java   // Assignment management
SubmissionDAO.java   // Submission management
```

**DAO Pattern Implementation:**

```java
public class AssignmentDAO {
    private DatabaseConnectionPool connectionPool;
    
    public AssignmentDAO() {
        this.connectionPool = DatabaseConnectionPool.getInstance();
    }
    
    // Create
    public int createAssignment(Assignment assignment) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = connectionPool.getConnection();
            String sql = "INSERT INTO assignments (...) VALUES (...)";
            pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            // Set parameters...
            pstmt.executeUpdate();
            rs = pstmt.getGeneratedKeys();
            if (rs.next()) return rs.getInt(1);
            return -1;
        } finally {
            closeResources(rs, pstmt, conn);
        }
    }
    
    // Read
    public Assignment getAssignmentById(int id) throws SQLException {...}
    
    // Update
    public boolean updateAssignment(Assignment assignment) throws SQLException {...}
    
    // Delete
    public boolean deleteAssignment(int id) throws SQLException {...}
}
```

## 🔧 Component Details

### 1. DatabaseConnectionPool

**Purpose:** Manage database connections efficiently using multithreading.

**Architecture:**

```java
public class DatabaseConnectionPool {
    // Thread-safe connection pools
    private BlockingQueue<Connection> connectionPool;
    private BlockingQueue<Connection> usedConnections;
    
    // Configuration
    private int initialPoolSize = 5;
    private int maxPoolSize = 20;
    private long maxWaitTime = 10000; // 10 seconds
    
    // Connection management
    public Connection getConnection() throws SQLException {
        Connection conn = connectionPool.poll(maxWaitTime, TimeUnit.MILLISECONDS);
        if (conn == null) {
            throw new SQLException("Timeout waiting for connection");
        }
        usedConnections.offer(conn);
        return conn;
    }
    
    public void releaseConnection(Connection conn) {
        usedConnections.remove(conn);
        connectionPool.offer(conn);
    }
}
```

**Key Features:**
- ✅ Thread-safe using `BlockingQueue`
- ✅ Connection reuse
- ✅ Configurable pool size
- ✅ Timeout management
- ✅ Automatic connection validation

### 2. FileUploadHandler

**Purpose:** Handle file uploads with validation.

```java
public class FileUploadHandler {
    private static final long MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB
    private static final String[] ALLOWED_EXTENSIONS = {"pdf", "docx", "zip"};
    
    public String handleUpload(Part filePart, String uploadPath) 
            throws IOException, ServletException {
        // Validate file
        validateFile(filePart);
        
        // Generate unique filename
        String fileName = generateUniqueFileName(filePart);
        
        // Save file
        String filePath = uploadPath + File.separator + fileName;
        filePart.write(filePath);
        
        return filePath;
    }
    
    private void validateFile(Part filePart) throws ServletException {
        // Check file size
        if (filePart.getSize() > MAX_FILE_SIZE) {
            throw new ServletException("File too large");
        }
        
        // Check file extension
        String fileName = getFileName(filePart);
        String extension = getFileExtension(fileName);
        if (!isAllowedExtension(extension)) {
            throw new ServletException("File type not allowed");
        }
    }
}
```

### 3. ValidationUtil

**Purpose:** Input validation and sanitization.

```java
public class ValidationUtil {
    public static boolean isValidEmail(String email) {
        String regex = "^[A-Za-z0-9+_.-]+@(.+)$";
        return email != null && email.matches(regex);
    }
    
    public static boolean isValidUsername(String username) {
        // 3-50 characters, alphanumeric and underscore
        String regex = "^[a-zA-Z0-9_]{3,50}$";
        return username != null && username.matches(regex);
    }
    
    public static String sanitizeInput(String input) {
        if (input == null) return "";
        // Remove HTML tags and scripts
        return input.replaceAll("<[^>]*>", "")
                   .replaceAll("(?i)<script.*?>.*?</script>", "");
    }
}
```

## 🔄 Multithreading Implementation

### Connection Pool Threading

**Why Multithreading?**
- ✅ Handle concurrent user requests
- ✅ Efficient resource utilization
- ✅ Better performance under load
- ✅ Prevent connection exhaustion

**Implementation:**

```java
public class DatabaseConnectionPool {
    // Thread-safe queue for available connections
    private BlockingQueue<Connection> connectionPool;
    
    // Thread-safe queue for in-use connections
    private BlockingQueue<Connection> usedConnections;
    
    private void initializePool() {
        connectionPool = new ArrayBlockingQueue<>(maxPoolSize);
        usedConnections = new ArrayBlockingQueue<>(maxPoolSize);
        
        // Create initial connections
        for (int i = 0; i < initialPoolSize; i++) {
            connectionPool.add(createConnection());
        }
    }
    
    public Connection getConnection() throws SQLException {
        try {
            // Wait for available connection (thread-safe)
            Connection conn = connectionPool.poll(maxWaitTime, TimeUnit.MILLISECONDS);
            
            if (conn == null) {
                // Try creating new connection if pool not full
                if (usedConnections.size() < maxPoolSize) {
                    conn = createConnection();
                } else {
                    throw new SQLException("Connection pool exhausted");
                }
            }
            
            // Validate connection
            if (!conn.isValid(2)) {
                conn = createConnection();
            }
            
            usedConnections.offer(conn);
            return conn;
            
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new SQLException("Thread interrupted while waiting for connection");
        }
    }
    
    public void releaseConnection(Connection conn) {
        if (conn != null) {
            usedConnections.remove(conn);
            connectionPool.offer(conn);
        }
    }
}
```

**Thread Safety Mechanisms:**

1. **BlockingQueue:**
   - Thread-safe queue implementation
   - Automatic synchronization
   - Blocking operations (poll, offer)

2. **Synchronized Methods:**
   - Singleton getInstance() method is synchronized
   - Prevents multiple instances in multithreaded environment

3. **Connection Validation:**
   - Validates connections before use
   - Replaces stale connections automatically

### Servlet Thread Safety

**Servlet Container (Tomcat) Threading:**
- Single servlet instance serves multiple requests
- Each request handled in separate thread
- Servlets must be thread-safe

**Thread-Safe Servlet Implementation:**

```java
public class StudentDashboardServlet extends HttpServlet {
    private UserDAO userDAO;  // Thread-safe (no shared state)
    
    @Override
    public void init() throws ServletException {
        // Initialize once per servlet
        userDAO = new UserDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, 
                        HttpServletResponse response)
            throws ServletException, IOException {
        // Each request gets its own thread and local variables
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        // Thread-safe: local variables only
        List<Course> courses = getCourses(user.getUserId());
        
        request.setAttribute("courses", courses);
        request.getRequestDispatcher("/jsp/student-dashboard.jsp")
               .forward(request, response);
    }
    
    private List<Course> getCourses(int userId) {
        // DAO operations are thread-safe
        // Each thread gets its own connection from pool
        try {
            return new CourseDAO().getCoursesByStudent(userId);
        } catch (SQLException e) {
            // Handle error
            return new ArrayList<>();
        }
    }
}
```

**Thread Safety Best Practices:**
- ✅ No instance variables for request data
- ✅ Use local variables in doGet/doPost
- ✅ DAOs obtain connections per request
- ✅ Connections released after use

## 🔒 Security Architecture

### 1. Authentication

**Password Security:**
```sql
-- Passwords stored as SHA-256 hash
INSERT INTO users (username, password, ...) 
VALUES ('user', SHA2('password123', 256), ...);

-- Authentication query
SELECT * FROM users 
WHERE username = ? AND password = SHA2(?, 256);
```

### 2. Session Management

```java
// Create session on login
HttpSession session = request.getSession(true);
session.setAttribute("user", user);
session.setAttribute("userId", user.getUserId());
session.setAttribute("role", user.getRole());
session.setMaxInactiveInterval(30 * 60); // 30 minutes

// Validate session on protected pages
User user = (User) session.getAttribute("user");
if (user == null) {
    response.sendRedirect("login");
    return;
}
```

### 3. Role-Based Access Control (RBAC)

```java
// Check role before allowing access
String userRole = (String) session.getAttribute("role");
if (!"TEACHER".equals(userRole)) {
    response.sendError(HttpServletResponse.SC_FORBIDDEN);
    return;
}
```

### 4. SQL Injection Prevention

```java
// ALWAYS use PreparedStatement
String sql = "SELECT * FROM users WHERE username = ? AND password = ?";
PreparedStatement pstmt = conn.prepareStatement(sql);
pstmt.setString(1, username);
pstmt.setString(2, password);
```

### 5. XSS Protection

```jsp
<!-- Escape output in JSP -->
<c:out value="${user.fullName}" escapeXml="true"/>

<!-- Or use JSTL -->
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
```

### 6. File Upload Security

```java
// Validate file type
private static final String[] ALLOWED_TYPES = {"pdf", "docx", "zip"};

// Validate file size
if (file.getSize() > MAX_FILE_SIZE) {
    throw new ServletException("File too large");
}

// Generate unique filename (prevent overwriting)
String uniqueFileName = UUID.randomUUID() + "_" + originalFileName;

// Store outside web root
String uploadPath = "/var/uploads/assignment-portal";
```

## 📊 Data Flow

### Student Submission Flow

```
1. Student clicks "Submit Assignment"
   ↓
2. Browser sends POST to /student/submit
   ↓
3. SubmitAssignmentServlet receives request
   ↓
4. Servlet validates session and role
   ↓
5. FileUploadHandler validates and saves file
   ↓
6. SubmissionDAO creates database record
   ├─→ Gets connection from pool
   ├─→ Executes INSERT statement
   └─→ Returns connection to pool
   ↓
7. Servlet sets success message
   ↓
8. Redirect to student dashboard
   ↓
9. StudentDashboardServlet loads updated data
   ↓
10. JSP displays success message
```

### Teacher Grading Flow

```
1. Teacher opens submission for grading
   ↓
2. Browser sends GET to /teacher/grade?id=X
   ↓
3. GradeSubmissionServlet receives request
   ↓
4. Servlet validates teacher role
   ↓
5. SubmissionDAO fetches submission details
   ↓
6. JSP displays grading form
   ↓
7. Teacher submits grade (POST)
   ↓
8. Servlet validates marks and feedback
   ↓
9. SubmissionDAO updates submission
   ├─→ Sets marks_obtained
   ├─→ Sets feedback
   ├─→ Sets graded_by
   ├─→ Sets status = 'GRADED'
   └─→ Records grading timestamp
   ↓
10. Activity logged to activity_log table
   ↓
11. Redirect to teacher dashboard
```

## 📈 Scalability Considerations

### Current Architecture

**Supports:**
- ✅ 100-500 concurrent users
- ✅ Single server deployment
- ✅ Connection pooling for efficiency

### Future Enhancements

**Horizontal Scaling:**
```
Load Balancer
    │
    ├─→ App Server 1 (Tomcat)
    ├─→ App Server 2 (Tomcat)
    └─→ App Server 3 (Tomcat)
            │
            ↓
    Database Cluster
    ├─→ Master (Write)
    └─→ Slave (Read)
```

**Caching Layer:**
- Redis/Memcached for session storage
- Cache frequently accessed data
- Reduce database load

**CDN for Static Content:**
- Serve CSS, JS, images from CDN
- Reduce server load
- Faster page loads

**Database Optimization:**
- Read replicas for query distribution
- Sharding for large datasets
- Query optimization and indexing

---

**Architecture documentation complete! 🏗️**
