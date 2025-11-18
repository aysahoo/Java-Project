# Troubleshooting Guide - Assignment Portal

Common issues and their solutions for the Assignment Portal application.

## 📋 Table of Contents
- [Installation Issues](#installation-issues)
- [Database Issues](#database-issues)
- [Compilation Issues](#compilation-issues)
- [Deployment Issues](#deployment-issues)
- [Runtime Issues](#runtime-issues)
- [Performance Issues](#performance-issues)
- [Security Issues](#security-issues)
- [General Debugging](#general-debugging)

## 🔧 Installation Issues

### Issue 1: Java Not Found

**Error:**
```
bash: java: command not found
```

**Solution:**

```bash
# Check Java installation
which java

# If not installed, install Java
# Ubuntu/Debian
sudo apt install openjdk-11-jdk

# macOS
brew install openjdk@11

# Verify
java -version
javac -version

# Set JAVA_HOME (add to ~/.bashrc or ~/.zshrc)
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64  # Linux
export JAVA_HOME=/usr/local/opt/openjdk@11           # macOS
export PATH=$JAVA_HOME/bin:$PATH
```

---

### Issue 2: CATALINA_HOME Not Set

**Error:**
```
Error: CATALINA_HOME not set and Tomcat not found
```

**Solution:**

```bash
# Find Tomcat installation
find /opt -name "tomcat" 2>/dev/null
find /usr/local -name "tomcat" 2>/dev/null

# Set CATALINA_HOME
export CATALINA_HOME=/path/to/tomcat

# Make permanent (add to ~/.bashrc or ~/.zshrc)
echo 'export CATALINA_HOME=/opt/tomcat' >> ~/.bashrc
source ~/.bashrc

# Verify
echo $CATALINA_HOME
ls $CATALINA_HOME/bin
```

---

### Issue 3: Permission Denied

**Error:**
```
Permission denied: ./setup.sh
```

**Solution:**

```bash
# Make scripts executable
chmod +x setup.sh
chmod +x compile.sh
chmod +x deploy.sh
chmod +x monitor.sh

# Or make all .sh files executable
chmod +x *.sh
```

---

## 🗄️ Database Issues

### Issue 4: MySQL Connection Failed

**Error:**
```
Communications link failure
```

**Symptoms:**
- Application can't connect to database
- "Communications link failure" in logs

**Solution:**

```bash
# 1. Check if MySQL is running
sudo systemctl status mysql          # Linux
brew services list | grep mysql      # macOS

# 2. Start MySQL if stopped
sudo systemctl start mysql           # Linux
brew services start mysql            # macOS

# 3. Test connection
mysql -u root -p -e "SELECT 1"

# 4. Check MySQL is listening
sudo netstat -tlnp | grep 3306       # Linux
lsof -i :3306                        # macOS

# 5. Check db.properties configuration
cat WEB-INF/classes/db.properties

# 6. Verify MySQL user can connect
mysql -u app_user -p -h localhost assignment_portal
```

**Common db.properties fixes:**

```properties
# Make sure these match your MySQL setup
db.url=jdbc:mysql://localhost:3306/assignment_portal?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
db.username=root
db.password=your_actual_password

# For MySQL 8.0+, may need:
db.url=jdbc:mysql://localhost:3306/assignment_portal?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&useUnicode=true&characterEncoding=UTF-8
```

---

### Issue 5: Access Denied for User

**Error:**
```
java.sql.SQLException: Access denied for user 'root'@'localhost'
```

**Solution:**

```bash
# Reset MySQL root password
sudo mysql

# In MySQL prompt:
ALTER USER 'root'@'localhost' IDENTIFIED BY 'new_password';
FLUSH PRIVILEGES;
EXIT;

# Update db.properties with new password
nano WEB-INF/classes/db.properties

# Or create dedicated user
mysql -u root -p
```

```sql
CREATE USER 'app_user'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON assignment_portal.* TO 'app_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

---

### Issue 6: Database Does Not Exist

**Error:**
```
Unknown database 'assignment_portal'
```

**Solution:**

```bash
# Check if database exists
mysql -u root -p -e "SHOW DATABASES;"

# Create database if missing
mysql -u root -p < database/schema.sql

# Or manually:
mysql -u root -p
```

```sql
CREATE DATABASE assignment_portal;
USE assignment_portal;
SOURCE /path/to/assignment-portal/database/schema.sql;
EXIT;
```

---

### Issue 7: Table Doesn't Exist

**Error:**
```
Table 'assignment_portal.users' doesn't exist
```

**Solution:**

```bash
# Verify tables exist
mysql -u root -p assignment_portal -e "SHOW TABLES;"

# If no tables, run schema
mysql -u root -p assignment_portal < database/schema.sql

# Verify again
mysql -u root -p assignment_portal -e "SHOW TABLES;"
```

---

## 🔨 Compilation Issues

### Issue 8: servlet-api.jar Not Found

**Error:**
```
package javax.servlet does not exist
```

**Solution:**

```bash
# Verify servlet-api.jar exists
ls $CATALINA_HOME/lib/servlet-api.jar

# If not found, check for alternative names
ls $CATALINA_HOME/lib/ | grep servlet

# Set CLASSPATH explicitly in compile.sh
export CLASSPATH="$CATALINA_HOME/lib/servlet-api.jar:$CLASSPATH"

# Or if using different name:
export CLASSPATH="$CATALINA_HOME/lib/servlet-api-4.0.jar:$CLASSPATH"
```

---

### Issue 9: MySQL Connector Not Found

**Error:**
```
ClassNotFoundException: com.mysql.cj.jdbc.Driver
```

**Solution:**

```bash
# Check if MySQL connector exists
ls WEB-INF/lib/*.jar

# If missing, download from:
# https://dev.mysql.com/downloads/connector/j/

# Extract and copy to lib directory
unzip mysql-connector-j-8.1.0.zip
cp mysql-connector-j-8.1.0/mysql-connector-j-8.1.0.jar WEB-INF/lib/

# Verify
ls -la WEB-INF/lib/mysql-connector-*.jar
```

---

### Issue 10: Compilation Errors

**Error:**
```
incompatible types: String cannot be converted to int
```

**Solution:**

```bash
# Check Java version compatibility
javac -version

# Ensure source and target compatibility
javac -source 8 -target 8 -d WEB-INF/classes -cp $CLASSPATH *.java

# If using Java 11+, use --release flag
javac --release 8 -d WEB-INF/classes -cp $CLASSPATH *.java

# Clean and recompile
find WEB-INF/classes -name "*.class" -delete
./compile.sh
```

---

## 🚀 Deployment Issues

### Issue 11: Port 8080 Already in Use

**Error:**
```
Address already in use: bind
```

**Solution:**

```bash
# Find process using port 8080
# Linux
sudo lsof -i :8080
sudo netstat -tulpn | grep 8080

# macOS
lsof -i :8080

# Kill the process
sudo kill -9 <PID>

# Or change Tomcat port
nano $CATALINA_HOME/conf/server.xml

# Change:
<Connector port="8080" ...>
# To:
<Connector port="8090" ...>

# Restart Tomcat
$CATALINA_HOME/bin/shutdown.sh
$CATALINA_HOME/bin/startup.sh
```

---

### Issue 12: Application Not Deploying

**Error:**
Application doesn't appear in Tomcat webapps

**Solution:**

```bash
# 1. Check Tomcat is running
ps aux | grep tomcat
sudo systemctl status tomcat

# 2. Check catalina.out for errors
tail -f $CATALINA_HOME/logs/catalina.out

# 3. Verify deployment directory
ls -la $CATALINA_HOME/webapps/assignment-portal/

# 4. Check file permissions
sudo chown -R tomcat:tomcat $CATALINA_HOME/webapps/assignment-portal/

# 5. Try manual deployment
./deploy.sh

# 6. Check web.xml syntax
xmllint --noout WEB-INF/web.xml

# 7. Clean and redeploy
rm -rf $CATALINA_HOME/webapps/assignment-portal
rm -rf $CATALINA_HOME/work/Catalina/localhost/assignment-portal
./deploy.sh
```

---

### Issue 13: 404 Not Found After Deployment

**Error:**
```
HTTP Status 404 – Not Found
```

**Solution:**

```bash
# 1. Verify application is deployed
ls $CATALINA_HOME/webapps/ | grep assignment

# 2. Check correct URL
# Should be: http://localhost:8080/assignment-portal/
# NOT: http://localhost:8080/

# 3. Check web.xml welcome file
cat WEB-INF/web.xml | grep welcome-file

# 4. Access index.html directly
curl http://localhost:8080/assignment-portal/index.html

# 5. Check Tomcat logs
tail -50 $CATALINA_HOME/logs/catalina.out
tail -50 $CATALINA_HOME/logs/localhost.*.log
```

---

## 🏃 Runtime Issues

### Issue 14: Login Fails with Correct Credentials

**Error:**
"Invalid username or password" even with correct credentials

**Solution:**

```sql
-- Check if user exists
SELECT username, email, role FROM users;

-- Verify password hash
SELECT username, password FROM users WHERE username = 'alice.brown';

-- Reset password if needed
UPDATE users 
SET password = SHA2('student123', 256) 
WHERE username = 'alice.brown';

-- Verify hash matches
SELECT SHA2('student123', 256);
```

**Also check:**

```bash
# Check servlet logs
tail -f $CATALINA_HOME/logs/catalina.out

# Verify LoginServlet is loaded
curl -I http://localhost:8080/assignment-portal/login
```

---

### Issue 15: Session Timeout Too Quickly

**Error:**
User gets logged out frequently

**Solution:**

```xml
<!-- Edit WEB-INF/web.xml -->
<session-config>
    <session-timeout>60</session-timeout>  <!-- Minutes -->
</session-config>
```

Or programmatically:

```java
// In LoginServlet.java
session.setMaxInactiveInterval(60 * 60);  // 60 minutes in seconds
```

---

### Issue 16: File Upload Fails

**Error:**
```
The temporary upload location is not valid
```

**Solution:**

```bash
# 1. Create temp directory
sudo mkdir -p /tmp/tomcat
sudo chown -R tomcat:tomcat /tmp/tomcat

# 2. Or create in Tomcat work directory
mkdir -p $CATALINA_HOME/work/Tomcat/localhost/assignment-portal

# 3. Check file size limit in web.xml
cat WEB-INF/web.xml | grep max-file-size

# 4. Increase if needed
```

```xml
<multipart-config>
    <max-file-size>10485760</max-file-size>      <!-- 10MB -->
    <max-request-size>15728640</max-request-size>
</multipart-config>
```

---

### Issue 17: "Too Many Connections" Error

**Error:**
```
Too many connections
```

**Solution:**

```sql
-- Check current connections
SHOW PROCESSLIST;

-- Check max connections
SHOW VARIABLES LIKE 'max_connections';

-- Increase max connections
SET GLOBAL max_connections = 200;

-- Make permanent in my.cnf
sudo nano /etc/mysql/my.cnf
```

```ini
[mysqld]
max_connections = 200
```

**Also check connection pool:**

```properties
# db.properties
db.pool.maxTotal=50  # Should be less than max_connections
```

---

### Issue 18: NullPointerException in Servlet

**Error:**
```
java.lang.NullPointerException
```

**Common Causes:**

1. **Session attribute is null:**
```java
// Bad
User user = (User) session.getAttribute("user");
String name = user.getFullName();  // NPE if user is null

// Good
User user = (User) session.getAttribute("user");
if (user != null) {
    String name = user.getFullName();
}
```

2. **Request parameter is null:**
```java
// Bad
int id = Integer.parseInt(request.getParameter("id"));  // NPE if null

// Good
String idStr = request.getParameter("id");
if (idStr != null && !idStr.isEmpty()) {
    int id = Integer.parseInt(idStr);
}
```

3. **Database result is null:**
```java
// Bad
User user = userDAO.getUserById(id);
session.setAttribute("username", user.getUsername());  // NPE if user not found

// Good
User user = userDAO.getUserById(id);
if (user != null) {
    session.setAttribute("username", user.getUsername());
}
```

---

## ⚡ Performance Issues

### Issue 19: Slow Database Queries

**Solution:**

```sql
-- Enable slow query log
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 2;

-- Check slow queries
sudo tail -f /var/log/mysql/slow-query.log

-- Add indexes for slow queries
CREATE INDEX idx_submissions_student ON submissions(student_id);
CREATE INDEX idx_assignments_course ON assignments(course_id);

-- Analyze query performance
EXPLAIN SELECT * FROM submissions WHERE student_id = 3;

-- Optimize tables
OPTIMIZE TABLE users, courses, assignments, submissions;
```

---

### Issue 20: Application Slow Under Load

**Solution:**

```bash
# 1. Increase Tomcat memory
nano $CATALINA_HOME/bin/setenv.sh
```

```bash
export CATALINA_OPTS="-Xms1024M -Xmx2048M"
```

```bash
# 2. Increase connection pool
nano WEB-INF/classes/db.properties
```

```properties
db.pool.initialSize=20
db.pool.maxTotal=100
```

```bash
# 3. Enable compression in Tomcat
nano $CATALINA_HOME/conf/server.xml
```

```xml
<Connector port="8080" 
           compression="on"
           compressionMinSize="2048"
           compressibleMimeType="text/html,text/xml,text/plain,text/css,text/javascript,application/javascript">
```

---

## 🔒 Security Issues

### Issue 21: SQL Injection Vulnerability

**Vulnerable Code:**
```java
// BAD - Never do this!
String sql = "SELECT * FROM users WHERE username = '" + username + "'";
```

**Solution:**
```java
// GOOD - Always use PreparedStatement
String sql = "SELECT * FROM users WHERE username = ?";
PreparedStatement pstmt = conn.prepareStatement(sql);
pstmt.setString(1, username);
```

---

### Issue 22: XSS Vulnerability in JSP

**Vulnerable Code:**
```jsp
<!-- BAD -->
<p>Welcome, <%= request.getParameter("name") %></p>
```

**Solution:**
```jsp
<!-- GOOD - Use JSTL c:out to escape -->
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<p>Welcome, <c:out value="${param.name}" /></p>

<!-- Or manually escape -->
<p>Welcome, <%= org.apache.commons.text.StringEscapeUtils.escapeHtml4(name) %></p>
```

---

## 🔍 General Debugging

### Enable Debug Logging

**Tomcat:**
```bash
# Edit logging.properties
nano $CATALINA_HOME/conf/logging.properties
```

```properties
# Set to FINE for debug output
org.apache.catalina.level = FINE
```

**Application:**
```java
// Add debug statements
System.out.println("DEBUG: User ID = " + userId);
System.out.println("DEBUG: Query = " + sql);

// Or use logger
private static final Logger logger = Logger.getLogger(ClassName.class.getName());
logger.info("Processing login for user: " + username);
logger.warning("Failed login attempt: " + username);
logger.severe("Database error: " + e.getMessage());
```

### Check All Logs

```bash
# Tomcat logs
tail -f $CATALINA_HOME/logs/catalina.out
tail -f $CATALINA_HOME/logs/localhost.*.log

# MySQL logs
sudo tail -f /var/log/mysql/error.log

# System logs
sudo tail -f /var/log/syslog           # Ubuntu
sudo tail -f /var/log/messages         # CentOS
```

### Test Database Connection

```java
// TestConnection.java
import java.sql.*;

public class TestConnection {
    public static void main(String[] args) {
        String url = "jdbc:mysql://localhost:3306/assignment_portal";
        String user = "root";
        String password = "password";
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(url, user, password);
            System.out.println("✅ Connected successfully!");
            
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM users");
            if (rs.next()) {
                System.out.println("Users count: " + rs.getInt(1));
            }
            
            conn.close();
        } catch (Exception e) {
            System.err.println("❌ Connection failed!");
            e.printStackTrace();
        }
    }
}
```

```bash
# Compile and run
javac -cp WEB-INF/lib/mysql-connector-*.jar TestConnection.java
java -cp .:WEB-INF/lib/mysql-connector-*.jar TestConnection
```

---

## 📞 Getting Help

### Collect Diagnostic Information

Before asking for help, collect:

1. **Error messages** from logs
2. **Tomcat version:** `$CATALINA_HOME/bin/version.sh`
3. **Java version:** `java -version`
4. **MySQL version:** `mysql --version`
5. **OS information:** `uname -a` or `cat /etc/os-release`
6. **Last 50 lines of catalina.out:** `tail -50 $CATALINA_HOME/logs/catalina.out`

### Common Commands Reference

```bash
# Check service status
sudo systemctl status tomcat
sudo systemctl status mysql

# Restart services
sudo systemctl restart tomcat
sudo systemctl restart mysql

# View logs
tail -f $CATALINA_HOME/logs/catalina.out
tail -f /var/log/mysql/error.log

# Test connectivity
curl -I http://localhost:8080/assignment-portal/
mysql -u root -p -e "SELECT 1"

# Check ports
sudo netstat -tulpn | grep -E '8080|3306'
lsof -i :8080

# Clean deployment
rm -rf $CATALINA_HOME/webapps/assignment-portal
rm -rf $CATALINA_HOME/work/Catalina/localhost/assignment-portal
./deploy.sh
```

---

## 🎯 Quick Fixes Checklist

When something goes wrong, try these in order:

- [ ] Check if Tomcat is running: `ps aux | grep tomcat`
- [ ] Check if MySQL is running: `ps aux | grep mysql`
- [ ] Check Tomcat logs: `tail -f $CATALINA_HOME/logs/catalina.out`
- [ ] Verify database connection: `mysql -u root -p`
- [ ] Check file permissions: `ls -la WEB-INF/classes/`
- [ ] Restart Tomcat: `sudo systemctl restart tomcat`
- [ ] Clean and redeploy: `./deploy.sh`
- [ ] Clear browser cache and cookies
- [ ] Test with different browser
- [ ] Check firewall: `sudo ufw status`

---

**Still having issues? Check the logs! 🔍**

Most problems can be diagnosed from:
- `$CATALINA_HOME/logs/catalina.out`
- `/var/log/mysql/error.log`
- Browser developer console (F12)
