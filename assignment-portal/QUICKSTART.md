f# Assignment Portal - Quick Start Guide

## ⚡ Get Started in 5 Minutes

### Prerequisites
- Java 8 or higher
- MySQL 8.0
- Apache Tomcat 9.0
- MySQL Connector/J JAR

### Step 1: Download MySQL Connector
```bash
# Download from: https://dev.mysql.com/downloads/connector/j/
# Or use wget:
cd assignment-portal/WEB-INF/lib/
wget https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.33/mysql-connector-java-8.0.33.jar
```

### Step 2: Setup Database
```bash
# Start MySQL
mysql.server start  # macOS
# OR
sudo systemctl start mysql  # Linux

# Create database
mysql -u root -p < database/schema.sql
# Enter your MySQL password when prompted
```

### Step 3: Configure Database Connection
Edit `database/db.properties`:
```properties
db.username=root
db.password=YOUR_MYSQL_PASSWORD
```

### Step 4: One-Command Setup
```bash
# Make scripts executable
chmod +x setup.sh compile.sh deploy.sh

# Run complete setup
./setup.sh
```

The script will:
1. ✅ Check all prerequisites
2. ✅ Setup database (if needed)
3. ✅ Compile all Java files
4. ✅ Deploy to Tomcat
5. ✅ Start the server

### Step 5: Access Application
Open browser and go to:
```
http://localhost:8080/assignment-portal/
```

## 🔑 Default Login Credentials

### Admin Account
- **Username:** `admin`
- **Password:** `admin123`
- **Capabilities:** Full system access

### Teacher Accounts
- **Username:** `john.smith` | **Password:** `teacher123`
- **Username:** `mary.johnson` | **Password:** `teacher123`
- **Capabilities:** Create assignments, grade submissions

### Student Accounts
- **Username:** `alice.brown` | **Password:** `student123`
- **Username:** `bob.wilson` | **Password:** `student123`
- **Username:** `charlie.davis` | **Password:** `student123`
- **Capabilities:** Submit assignments, view grades

## 🎯 Manual Setup (Alternative)

### 1. Set Environment Variables
```bash
export CATALINA_HOME=/path/to/tomcat
export CLASSPATH=$CATALINA_HOME/lib/servlet-api.jar:WEB-INF/lib/mysql-connector-java-8.0.33.jar
```

### 2. Compile Java Files
```bash
./compile.sh
# OR manually:
find WEB-INF/classes/com -name "*.java" -type f | xargs javac -d WEB-INF/classes -cp $CLASSPATH
```

### 3. Deploy to Tomcat
```bash
./deploy.sh
# OR manually:
cp -r . $CATALINA_HOME/webapps/assignment-portal/
```

### 4. Start Tomcat
```bash
$CATALINA_HOME/bin/startup.sh

# View logs
tail -f $CATALINA_HOME/logs/catalina.out
```

### 5. Stop Tomcat
```bash
$CATALINA_HOME/bin/shutdown.sh
```

## 📋 Quick Test Checklist

### Test Student Features
- [ ] Login as student (alice.brown / student123)
- [ ] View enrolled courses
- [ ] View assignments
- [ ] Upload assignment (test.pdf)
- [ ] View submission history

### Test Teacher Features
- [ ] Login as teacher (john.smith / teacher123)
- [ ] View courses
- [ ] Create new assignment
- [ ] View student submissions
- [ ] Grade a submission

### Test Admin Features
- [ ] Login as admin (admin / admin123)
- [ ] View dashboard analytics
- [ ] Create new user
- [ ] Create new course
- [ ] Manage enrollments

## 🔧 Common Issues & Fixes

### Issue: "Connection refused"
**Fix:** Start MySQL
```bash
mysql.server start  # macOS
sudo systemctl start mysql  # Linux
```

### Issue: "Port 8080 already in use"
**Fix:** Change Tomcat port in `server.xml`
```xml
<Connector port="8081" protocol="HTTP/1.1"/>
```

### Issue: "ClassNotFoundException: com.mysql.cj.jdbc.Driver"
**Fix:** Add MySQL connector to WEB-INF/lib/
```bash
cd WEB-INF/lib/
wget https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.33/mysql-connector-java-8.0.33.jar
```

### Issue: "Access denied for user 'root'"
**Fix:** Update password in `database/db.properties`
```properties
db.password=YOUR_CORRECT_PASSWORD
```

### Issue: "Table 'assignment_portal.users' doesn't exist"
**Fix:** Run database schema
```bash
mysql -u root -p < database/schema.sql
```

## 🎨 Sample Files for Testing

Create test files for upload:
```bash
# Create sample PDF (dummy file)
echo "Sample Assignment" > test.pdf

# Create sample DOCX (rename txt to docx for testing)
echo "Assignment submission" > test.docx

# Create sample ZIP
zip test.zip test.pdf test.docx
```

## 📱 Application URLs

| Feature | URL |
|---------|-----|
| Home Page | http://localhost:8080/assignment-portal/ |
| Login | http://localhost:8080/assignment-portal/login |
| Logout | http://localhost:8080/assignment-portal/logout |
| Student Dashboard | http://localhost:8080/assignment-portal/student/dashboard |
| Teacher Dashboard | http://localhost:8080/assignment-portal/teacher/dashboard |
| Admin Dashboard | http://localhost:8080/assignment-portal/admin/dashboard |

## 🔍 Verify Installation

### Check Database
```sql
mysql -u root -p

USE assignment_portal;

-- Check tables
SHOW TABLES;

-- Check users
SELECT user_id, username, role FROM users;

-- Check courses
SELECT course_id, course_code, course_name FROM courses;

-- Check enrollments
SELECT * FROM enrollments;
```

### Check Tomcat Deployment
```bash
# Check if deployed
ls $CATALINA_HOME/webapps/ | grep assignment-portal

# Check if compiled
ls $CATALINA_HOME/webapps/assignment-portal/WEB-INF/classes/com/assignmentportal/
```

### Check Logs
```bash
# Tomcat logs
tail -f $CATALINA_HOME/logs/catalina.out

# Application logs (if configured)
tail -f $CATALINA_HOME/logs/assignment-portal.log
```

## 📞 Need Help?

### Debug Mode
Add to `catalina.sh`:
```bash
export JAVA_OPTS="$JAVA_OPTS -Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005"
```

### Enable Detailed Logging
Edit `$CATALINA_HOME/conf/logging.properties`:
```properties
org.apache.catalina.core.ContainerBase.[Catalina].level = FINE
```

## ✅ Success Indicators

You'll know it's working when:
1. ✅ Database tables created (8 tables)
2. ✅ Sample data inserted (3 students, 2 teachers, 1 admin)
3. ✅ Java files compiled (no errors)
4. ✅ Tomcat starts without errors
5. ✅ Can login with any test account
6. ✅ Can navigate dashboards
7. ✅ File upload works

## 🚀 Next Steps

After successful setup:
1. Explore student features
2. Try teacher workflows
3. Test admin capabilities
4. Upload test assignments
5. Grade submissions
6. Check analytics

---

**Happy Learning! 🎓**

For detailed documentation, see:
- README.md - Project overview
- IMPLEMENTATION_GUIDE.md - Technical details
- database/schema.sql - Database structure
