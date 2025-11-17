# Assignment Portal - Testing Guide

## ✅ System Status

The application is **LIVE** and **WORKING**! 

- **URL**: http://localhost:8080/assignment-portal/
- **Database**: PostgreSQL (Neon Cloud) - Connected ✓
- **Server**: Apache Tomcat 9.0.112 - Running ✓

## 🔐 Demo Accounts

### Administrator
- **Username**: `admin`
- **Password**: `admin123`
- **Dashboard**: http://localhost:8080/assignment-portal/admin/dashboard
- **Features**: Manage users, courses, view analytics

### Teacher (Dr. John Smith)
- **Username**: `john.smith`
- **Password**: `teacher123`
- **Dashboard**: http://localhost:8080/assignment-portal/teacher/dashboard
- **Features**: Create assignments, grade submissions, manage courses

### Student (Alice Brown)
- **Username**: `alice.brown`
- **Password**: `student123`
- **Dashboard**: http://localhost:8080/assignment-portal/student/dashboard
- **Features**: View courses, submit assignments, check grades

## 🧪 Testing Workflow

### 1. Test Login Flow
```bash
# Open in browser
open http://localhost:8080/assignment-portal/

# Or test with curl
curl -c cookies.txt -X POST http://localhost:8080/assignment-portal/login \
  -d "username=admin&password=admin123"
```

### 2. Test Each Dashboard

#### Admin Dashboard
1. Login as admin
2. Navigate to http://localhost:8080/assignment-portal/admin/dashboard
3. Verify you see:
   - Total Users count
   - Total Courses count
   - Active Assignments count
   - System Analytics

#### Teacher Dashboard
1. Login as `john.smith`
2. Navigate to http://localhost:8080/assignment-portal/teacher/dashboard
3. Verify you see:
   - Your courses (CS101, CS201)
   - Assignments you created
   - Pending submissions for grading
   - Student performance stats

#### Student Dashboard
1. Login as `alice.brown`
2. Navigate to http://localhost:8080/assignment-portal/student/dashboard
3. Verify you see:
   - Enrolled courses
   - Pending assignments
   - Submitted assignments
   - Your grades

### 3. Test Database Connection

The connection pool should initialize on first login. Check logs:

```bash
# View connection pool initialization
grep -i "connection pool" /opt/homebrew/opt/tomcat@9/libexec/logs/catalina.out

# Expected output:
# New database connection created (x5)
# Database connection pool initialized with 5 connections
```

### 4. Test Role-Based Access

```bash
# Student should NOT access admin dashboard
curl -c cookies-student.txt -X POST http://localhost:8080/assignment-portal/login \
  -d "username=alice.brown&password=student123"
  
curl -b cookies-student.txt http://localhost:8080/assignment-portal/admin/dashboard
# Should redirect to login page
```

## 🐛 Troubleshooting

### "Database error: An I/O error occurred"
This happens when Neon's serverless database auto-suspends after inactivity.

**Solution**: Just try logging in again. The first request wakes up the database, the second will succeed.

```bash
# If you get I/O error, wait 2 seconds and retry
sleep 2
curl -X POST http://localhost:8080/assignment-portal/login \
  -d "username=admin&password=admin123"
```

### "No suitable driver" error
Connection pool failed to initialize.

**Solution**: Check that postgresql.jar is in WEB-INF/lib:
```bash
ls -lh /opt/homebrew/opt/tomcat@9/libexec/webapps/assignment-portal/WEB-INF/lib/
```

### Dashboard shows 404
Servlet mapping might be incorrect.

**Solution**: Check web.xml has correct mappings:
```bash
grep -A5 "AdminDashboardServlet" \
  /Users/ayushranjansahoo/Documents/Desktop/java-awt/assignment-portal/WEB-INF/web.xml
```

### Tomcat not responding
Server might have crashed.

**Solution**: Restart Tomcat:
```bash
/opt/homebrew/opt/tomcat@9/libexec/bin/shutdown.sh
sleep 2
/opt/homebrew/opt/tomcat@9/libexec/bin/startup.sh
```

## 📊 Database Sample Data

The database is pre-populated with:

- **3 Users**: 1 admin, 1 teacher, 1 student
- **2 Courses**: CS101, CS201 (both taught by John Smith)
- **3 Assignments**: 
  - CS101: Hello World (due Nov 30)
  - CS101: Calculator (due Dec 15)
  - CS201: Linked Lists (due Dec 1)
- **2 Enrollments**: Alice is enrolled in both courses

## 🚀 Next Steps

### Implement Dashboard Functionality

Currently, dashboards show static data. To make them dynamic:

1. **Student Dashboard** - Fetch real data:
   ```java
   // In StudentDashboardServlet.doGet()
   CourseDAO courseDAO = new CourseDAO();
   List<Course> courses = courseDAO.getCoursesByStudent(userId);
   request.setAttribute("courses", courses);
   ```

2. **Implement POST handlers** for:
   - Submit assignment (`SubmitAssignmentServlet`)
   - Grade submission (`GradeSubmissionServlet`)
   - Create user/course (Admin functions)

3. **Add file upload** for assignment submissions

### Add More Features

- Email notifications
- Assignment comments/feedback
- Bulk grading
- Export grades to CSV/PDF
- Course analytics charts
- Late submission penalties

## 📝 Log Files

- **Application logs**: `/opt/homebrew/opt/tomcat@9/libexec/logs/catalina.out`
- **Access logs**: `/opt/homebrew/opt/tomcat@9/libexec/logs/localhost_access_log.*.txt`
- **Error logs**: `/opt/homebrew/opt/tomcat@9/libexec/logs/localhost.YYYY-MM-DD.log`

```bash
# Tail application logs
tail -f /opt/homebrew/opt/tomcat@9/libexec/logs/catalina.out

# View recent errors
tail -50 /opt/homebrew/opt/tomcat@9/libexec/logs/localhost.$(date +%Y-%m-%d).log
```

## ✅ Verification Checklist

- [ ] Tomcat is running on port 8080
- [ ] PostgreSQL connection pool initialized
- [ ] Login page accessible at /assignment-portal/
- [ ] Admin login works
- [ ] Teacher login works
- [ ] Student login works
- [ ] Admin dashboard loads
- [ ] Teacher dashboard loads
- [ ] Student dashboard loads
- [ ] Logout functionality works
- [ ] Role-based access control works

---

**Last Updated**: November 17, 2025  
**Status**: ✅ OPERATIONAL  
**Known Issues**: Neon serverless database may need wake-up on first request after inactivity
