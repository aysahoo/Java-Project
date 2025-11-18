# API Documentation - Assignment Portal

Complete reference for all servlet endpoints, request/response formats, and usage examples.

## 📋 Table of Contents
- [Overview](#overview)
- [Base URL](#base-url)
- [Authentication](#authentication)
- [Common Response Codes](#common-response-codes)
- [Endpoints](#endpoints)
  - [Authentication APIs](#authentication-apis)
  - [Student APIs](#student-apis)
  - [Teacher APIs](#teacher-apis)
  - [Admin APIs](#admin-apis)
- [Models](#models)
- [Error Handling](#error-handling)

## 🌐 Overview

The Assignment Portal uses **Servlet-based REST-like architecture** with URL patterns defined in `web.xml`. All endpoints require authentication except the login page.

### Architecture
- **Protocol:** HTTP/HTTPS
- **Content Type:** `application/x-www-form-urlencoded` (forms), `multipart/form-data` (file uploads)
- **Session Management:** Cookie-based sessions (JSESSIONID)
- **Authentication:** Session-based with role validation

## 🔗 Base URL

```
Development:  http://localhost:8080/assignment-portal
Production:   https://your-domain.com/assignment-portal
```

## 🔐 Authentication

### Session-Based Authentication

All protected endpoints require an active session:

```java
HttpSession session = request.getSession();
User user = (User) session.getAttribute("user");

if (user == null) {
    response.sendRedirect("/login");
    return;
}
```

### Session Attributes

After successful login, session contains:

```java
session.getAttribute("user");      // User object
session.getAttribute("userId");    // int
session.getAttribute("username");  // String
session.getAttribute("fullName");  // String
session.getAttribute("role");      // String (STUDENT/TEACHER/ADMIN)
```

### Session Timeout

**Default:** 30 minutes of inactivity

```xml
<!-- web.xml -->
<session-config>
    <session-timeout>30</session-timeout>
</session-config>
```

## 📊 Common Response Codes

| Code | Meaning | Description |
|------|---------|-------------|
| 200 | OK | Request successful |
| 302 | Found | Redirect to another page |
| 400 | Bad Request | Invalid input data |
| 401 | Unauthorized | Not authenticated |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource not found |
| 500 | Internal Server Error | Server error occurred |

## 🔌 Endpoints

### Authentication APIs

#### 1. Login Page (GET)

Display login form.

**Endpoint:** `/login`  
**Method:** `GET`  
**Authentication:** None  
**Access:** Public  

**Request:**
```http
GET /assignment-portal/login HTTP/1.1
Host: localhost:8080
```

**Response:**
- Displays `login.jsp`
- No authentication required

---

#### 2. Login (POST)

Authenticate user and create session.

**Endpoint:** `/login`  
**Method:** `POST`  
**Authentication:** None  
**Access:** Public  

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| username | String | Yes | User's username |
| password | String | Yes | User's password (plain text) |

**Request:**
```http
POST /assignment-portal/login HTTP/1.1
Host: localhost:8080
Content-Type: application/x-www-form-urlencoded

username=alice.brown&password=student123
```

**Success Response:**
- **Code:** 302 (Redirect)
- **Redirect Location:** Based on user role:
  - STUDENT → `/student/dashboard`
  - TEACHER → `/teacher/dashboard`
  - ADMIN → `/admin/dashboard`
- **Session Created:** Yes

**Error Response:**
- **Code:** 200 (re-display login page)
- **Error Message:** "Invalid username or password"

**Example (cURL):**
```bash
curl -X POST http://localhost:8080/assignment-portal/login \
  -d "username=alice.brown&password=student123" \
  -c cookies.txt
```

---

#### 3. Logout

Terminate user session.

**Endpoint:** `/logout`  
**Method:** `GET` or `POST`  
**Authentication:** Required  
**Access:** All authenticated users  

**Request:**
```http
GET /assignment-portal/logout HTTP/1.1
Host: localhost:8080
Cookie: JSESSIONID=ABC123...
```

**Response:**
- **Code:** 302 (Redirect)
- **Redirect Location:** `/login`
- **Session:** Invalidated

**Example (cURL):**
```bash
curl -X GET http://localhost:8080/assignment-portal/logout \
  -b cookies.txt
```

---

### Student APIs

#### 4. Student Dashboard

Display student's courses, assignments, and submissions.

**Endpoint:** `/student/dashboard`  
**Method:** `GET`  
**Authentication:** Required  
**Role:** STUDENT  

**Request:**
```http
GET /assignment-portal/student/dashboard HTTP/1.1
Host: localhost:8080
Cookie: JSESSIONID=ABC123...
```

**Response:**
- **Code:** 200
- **View:** `student-dashboard.jsp`
- **Data Provided:**
  - Enrolled courses
  - Pending assignments
  - Submitted assignments
  - Grades received

**Attributes Set:**
```java
request.setAttribute("courses", List<Course>);
request.setAttribute("assignments", List<Assignment>);
request.setAttribute("submissions", List<Submission>);
request.setAttribute("stats", Map<String, Object>);
```

**Example Response Data:**
```json
{
  "courses": [
    {
      "courseId": 1,
      "courseName": "Introduction to Programming",
      "courseCode": "CS101",
      "teacherName": "Dr. John Smith"
    }
  ],
  "assignments": [
    {
      "assignmentId": 1,
      "title": "Assignment 1: Hello World",
      "dueDate": "2025-11-30 23:59:59",
      "maxMarks": 100,
      "status": "pending"
    }
  ],
  "submissions": [
    {
      "submissionId": 5,
      "assignmentTitle": "Assignment 1",
      "submissionDate": "2025-11-18 14:30:00",
      "marksObtained": 85,
      "status": "GRADED"
    }
  ]
}
```

---

#### 5. Submit Assignment (GET)

Display assignment submission form.

**Endpoint:** `/student/submit`  
**Method:** `GET`  
**Authentication:** Required  
**Role:** STUDENT  

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| assignmentId | int | Yes | ID of assignment to submit |

**Request:**
```http
GET /assignment-portal/student/submit?assignmentId=1 HTTP/1.1
Host: localhost:8080
Cookie: JSESSIONID=ABC123...
```

**Response:**
- **Code:** 200
- Displays submission form with assignment details

---

#### 6. Submit Assignment (POST)

Upload and submit assignment file.

**Endpoint:** `/student/submit`  
**Method:** `POST`  
**Authentication:** Required  
**Role:** STUDENT  
**Content-Type:** `multipart/form-data`  

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| assignmentId | int | Yes | Assignment ID |
| file | File | Yes | Assignment file (PDF, DOCX, ZIP) |

**File Constraints:**
- **Max Size:** 10 MB
- **Allowed Types:** .pdf, .docx, .doc, .zip, .rar
- **Naming:** Automatically renamed to unique filename

**Request:**
```http
POST /assignment-portal/student/submit HTTP/1.1
Host: localhost:8080
Cookie: JSESSIONID=ABC123...
Content-Type: multipart/form-data; boundary=----WebKitFormBoundary

------WebKitFormBoundary
Content-Disposition: form-data; name="assignmentId"

1
------WebKitFormBoundary
Content-Disposition: form-data; name="file"; filename="my_assignment.pdf"
Content-Type: application/pdf

[binary file content]
------WebKitFormBoundary--
```

**Success Response:**
- **Code:** 302 (Redirect)
- **Redirect:** `/student/dashboard`
- **Message:** "Assignment submitted successfully"

**Error Responses:**

| Error | Message |
|-------|---------|
| File too large | "File size exceeds 10MB limit" |
| Invalid file type | "Only PDF, DOCX, and ZIP files allowed" |
| Late submission | "Warning: Submitted after due date" |
| Duplicate submission | "Assignment already submitted" |

**Example (cURL):**
```bash
curl -X POST http://localhost:8080/assignment-portal/student/submit \
  -b cookies.txt \
  -F "assignmentId=1" \
  -F "file=@/path/to/assignment.pdf"
```

**Database Changes:**
```sql
INSERT INTO submissions 
  (assignment_id, student_id, file_path, original_filename, 
   file_size_kb, is_late, status)
VALUES (1, 3, '/uploads/abc123_assignment.pdf', 'my_assignment.pdf', 
        512, FALSE, 'SUBMITTED');
```

---

### Teacher APIs

#### 7. Teacher Dashboard

Display teacher's courses and assignment statistics.

**Endpoint:** `/teacher/dashboard`  
**Method:** `GET`  
**Authentication:** Required  
**Role:** TEACHER  

**Request:**
```http
GET /assignment-portal/teacher/dashboard HTTP/1.1
Host: localhost:8080
Cookie: JSESSIONID=ABC123...
```

**Response:**
- **Code:** 200
- **View:** `teacher-dashboard.jsp`

**Attributes Set:**
```java
request.setAttribute("courses", List<Course>);
request.setAttribute("assignments", List<Assignment>);
request.setAttribute("pendingGrading", List<Submission>);
request.setAttribute("stats", Map<String, Object>);
```

**Example Response Data:**
```json
{
  "courses": [
    {
      "courseId": 1,
      "courseName": "Introduction to Programming",
      "courseCode": "CS101",
      "enrolledStudents": 45,
      "activeAssignments": 3
    }
  ],
  "assignments": [
    {
      "assignmentId": 1,
      "title": "Assignment 1: Hello World",
      "totalSubmissions": 40,
      "gradedSubmissions": 25,
      "pendingGrading": 15
    }
  ],
  "stats": {
    "totalCourses": 2,
    "totalAssignments": 5,
    "pendingGrading": 20,
    "averageScore": 78.5
  }
}
```

---

#### 8. View Submissions

View all submissions for an assignment.

**Endpoint:** `/teacher/grade`  
**Method:** `GET`  
**Authentication:** Required  
**Role:** TEACHER  

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| assignmentId | int | Yes | Assignment ID |

**Request:**
```http
GET /assignment-portal/teacher/grade?assignmentId=1 HTTP/1.1
Host: localhost:8080
Cookie: JSESSIONID=ABC123...
```

**Response:**
- **Code:** 200
- Displays list of submissions with grading interface

**Attributes Set:**
```java
request.setAttribute("assignment", Assignment);
request.setAttribute("submissions", List<Submission>);
```

---

#### 9. Grade Submission

Submit grades and feedback for a submission.

**Endpoint:** `/teacher/grade`  
**Method:** `POST`  
**Authentication:** Required  
**Role:** TEACHER  

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| submissionId | int | Yes | Submission ID |
| marksObtained | int | Yes | Marks awarded (0 to max_marks) |
| feedback | String | No | Teacher's feedback/comments |

**Request:**
```http
POST /assignment-portal/teacher/grade HTTP/1.1
Host: localhost:8080
Cookie: JSESSIONID=ABC123...
Content-Type: application/x-www-form-urlencoded

submissionId=5&marksObtained=85&feedback=Good+work!+Well+structured+code.
```

**Success Response:**
- **Code:** 302 (Redirect)
- **Redirect:** Back to grading page
- **Message:** "Submission graded successfully"

**Validation:**
- Marks must be between 0 and assignment's max_marks
- Teacher must be the course instructor
- Submission must exist and be in SUBMITTED status

**Database Changes:**
```sql
UPDATE submissions 
SET marks_obtained = 85,
    feedback = 'Good work! Well structured code.',
    graded_by = 2,
    graded_at = CURRENT_TIMESTAMP,
    status = 'GRADED'
WHERE submission_id = 5;
```

**Example (cURL):**
```bash
curl -X POST http://localhost:8080/assignment-portal/teacher/grade \
  -b cookies.txt \
  -d "submissionId=5&marksObtained=85&feedback=Good work!"
```

---

### Admin APIs

#### 10. Admin Dashboard

System administration and analytics.

**Endpoint:** `/admin/dashboard`  
**Method:** `GET`  
**Authentication:** Required  
**Role:** ADMIN  

**Request:**
```http
GET /assignment-portal/admin/dashboard HTTP/1.1
Host: localhost:8080
Cookie: JSESSIONID=ABC123...
```

**Response:**
- **Code:** 200
- **View:** `admin-dashboard.jsp`

**Attributes Set:**
```java
request.setAttribute("totalUsers", int);
request.setAttribute("totalCourses", int);
request.setAttribute("totalAssignments", int);
request.setAttribute("totalSubmissions", int);
request.setAttribute("recentActivity", List<ActivityLog>);
request.setAttribute("systemStats", Map<String, Object>);
```

**Example Response Data:**
```json
{
  "systemStats": {
    "totalUsers": 150,
    "totalStudents": 120,
    "totalTeachers": 25,
    "totalAdmins": 5,
    "totalCourses": 30,
    "totalAssignments": 120,
    "totalSubmissions": 850,
    "averageGrade": 76.8
  },
  "recentActivity": [
    {
      "logId": 1001,
      "username": "alice.brown",
      "action": "SUBMIT_ASSIGNMENT",
      "timestamp": "2025-11-18 14:30:00",
      "details": "Submitted Assignment 1 for CS101"
    }
  ]
}
```

---

## 📦 Models

### User Model

```java
{
  "userId": 1,
  "username": "alice.brown",
  "email": "alice.brown@student.edu",
  "fullName": "Alice Brown",
  "role": "STUDENT",  // STUDENT | TEACHER | ADMIN
  "isActive": true,
  "createdAt": "2025-01-01 10:00:00",
  "updatedAt": "2025-11-18 14:00:00"
}
```

### Course Model

```java
{
  "courseId": 1,
  "courseCode": "CS101",
  "courseName": "Introduction to Programming",
  "description": "Fundamentals of programming using Java",
  "teacherId": 2,
  "teacherName": "Dr. John Smith",
  "isActive": true,
  "createdAt": "2025-01-01 10:00:00"
}
```

### Assignment Model

```java
{
  "assignmentId": 1,
  "courseId": 1,
  "title": "Assignment 1: Hello World",
  "description": "Create a simple Hello World program in Java",
  "maxMarks": 100,
  "dueDate": "2025-11-30 23:59:59",
  "filePath": "/uploads/assignments/assignment1.pdf",
  "allowedFileTypes": "pdf,docx,zip",
  "maxFileSizeMb": 10,
  "createdBy": 2,
  "isActive": true,
  "createdAt": "2025-11-01 10:00:00"
}
```

### Submission Model

```java
{
  "submissionId": 5,
  "assignmentId": 1,
  "studentId": 3,
  "studentName": "Alice Brown",
  "filePath": "/uploads/submissions/abc123_assignment.pdf",
  "originalFilename": "my_assignment.pdf",
  "fileSizeKb": 512,
  "submissionDate": "2025-11-18 14:30:00",
  "marksObtained": 85,
  "feedback": "Good work! Well structured code.",
  "gradedBy": 2,
  "gradedByName": "Dr. John Smith",
  "gradedAt": "2025-11-19 10:00:00",
  "status": "GRADED",  // SUBMITTED | GRADED | LATE | RESUBMITTED
  "isLate": false
}
```

### Enrollment Model

```java
{
  "enrollmentId": 1,
  "studentId": 3,
  "courseId": 1,
  "enrollmentDate": "2025-01-05 10:00:00",
  "status": "ACTIVE"  // ACTIVE | DROPPED | COMPLETED
}
```

## ❌ Error Handling

### Error Response Format

Errors are communicated via:
1. **Redirect with error message** (in session)
2. **HTTP error codes** (401, 403, 404, 500)
3. **Error attribute** (for same-page display)

### Common Error Scenarios

#### 1. Unauthorized Access

```java
// Session expired or not authenticated
response.sendRedirect("/assignment-portal/login");
```

#### 2. Forbidden Access

```java
// User lacks required role
response.sendError(HttpServletResponse.SC_FORBIDDEN, 
                  "You don't have permission to access this resource");
```

#### 3. Validation Error

```java
// Invalid input
request.setAttribute("error", "Invalid marks. Must be between 0 and 100");
request.getRequestDispatcher("/jsp/grade-form.jsp").forward(request, response);
```

#### 4. Database Error

```java
// SQL exception
request.setAttribute("error", "Database error: Unable to save submission");
request.getRequestDispatcher("/jsp/error.jsp").forward(request, response);
```

#### 5. File Upload Error

```java
// File validation failed
throw new ServletException("File size exceeds 10MB limit");
```

### Error Messages

| Error Type | Message Template |
|------------|------------------|
| Authentication | "Invalid username or password" |
| Authorization | "You don't have permission to perform this action" |
| Validation | "{Field} is required" / "{Field} must be {constraint}" |
| File Upload | "File size exceeds {limit}" / "File type not allowed" |
| Database | "Unable to {action}. Please try again later" |
| Not Found | "{Resource} not found" |

---

## 🔍 Testing Examples

### Test Login

```bash
# Login as student
curl -X POST http://localhost:8080/assignment-portal/login \
  -d "username=alice.brown&password=student123" \
  -c cookies.txt -v
```

### Test Dashboard Access

```bash
# Access student dashboard
curl -X GET http://localhost:8080/assignment-portal/student/dashboard \
  -b cookies.txt
```

### Test File Upload

```bash
# Submit assignment
curl -X POST http://localhost:8080/assignment-portal/student/submit \
  -b cookies.txt \
  -F "assignmentId=1" \
  -F "file=@assignment.pdf"
```

### Test Grading

```bash
# Grade submission
curl -X POST http://localhost:8080/assignment-portal/teacher/grade \
  -b cookies.txt \
  -d "submissionId=5&marksObtained=85&feedback=Excellent work!"
```

### Test Logout

```bash
# Logout
curl -X GET http://localhost:8080/assignment-portal/logout \
  -b cookies.txt -v
```

---

## 📚 Additional Resources

- **Servlet Specification:** https://javaee.github.io/servlet-spec/
- **HTTP Status Codes:** https://developer.mozilla.org/en-US/docs/Web/HTTP/Status
- **cURL Documentation:** https://curl.se/docs/

---

**API documentation complete! 🚀**
