# Setup Guide - Assignment Portal

This comprehensive guide will walk you through setting up the Assignment Portal from scratch.

## 📋 Table of Contents
- [System Requirements](#system-requirements)
- [Installation Steps](#installation-steps)
- [Database Setup](#database-setup)
- [Configuration](#configuration)
- [Compilation](#compilation)
- [Deployment](#deployment)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)

## 💻 System Requirements

### Minimum Requirements
- **OS:** Windows 10, macOS 10.14+, or Linux (Ubuntu 18.04+)
- **RAM:** 4 GB
- **Disk Space:** 500 MB
- **Java:** JDK 8 or higher
- **Database:** MySQL 5.7+ or MySQL 8.0+
- **Server:** Apache Tomcat 9.0+

### Recommended Requirements
- **OS:** macOS 12+, Windows 11, or Ubuntu 20.04+
- **RAM:** 8 GB
- **Disk Space:** 1 GB
- **Java:** JDK 11 or JDK 17 (LTS versions)
- **Database:** MySQL 8.0+
- **Server:** Apache Tomcat 9.0.70+

## 🚀 Installation Steps

### Step 1: Install Java Development Kit (JDK)

#### macOS (using Homebrew)
```bash
brew install openjdk@11
```

#### Linux (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install openjdk-11-jdk
```

#### Windows
1. Download JDK from [Oracle](https://www.oracle.com/java/technologies/downloads/) or [AdoptOpenJDK](https://adoptium.net/)
2. Run the installer
3. Set `JAVA_HOME` environment variable:
   ```
   JAVA_HOME=C:\Program Files\Java\jdk-11
   ```

**Verify Installation:**
```bash
java -version
javac -version
```

Expected output:
```
java version "11.0.x" ...
javac 11.0.x
```

### Step 2: Install Apache Tomcat

#### macOS (using Homebrew)
```bash
brew install tomcat
```

#### Linux (Manual Installation)
```bash
# Download Tomcat 9
cd /opt
sudo wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.80/bin/apache-tomcat-9.0.80.tar.gz

# Extract
sudo tar xzvf apache-tomcat-9.0.80.tar.gz
sudo mv apache-tomcat-9.0.80 tomcat

# Set permissions
sudo chown -R $USER:$USER /opt/tomcat
sudo chmod +x /opt/tomcat/bin/*.sh
```

#### Windows
1. Download from https://tomcat.apache.org/download-90.cgi
2. Extract to `C:\Program Files\Apache Tomcat 9.0`
3. Set environment variable:
   ```
   CATALINA_HOME=C:\Program Files\Apache Tomcat 9.0
   ```

**Set CATALINA_HOME Environment Variable:**

**macOS/Linux:**
Add to `~/.bashrc` or `~/.zshrc`:
```bash
export CATALINA_HOME=/opt/tomcat
export PATH=$PATH:$CATALINA_HOME/bin
```

Apply changes:
```bash
source ~/.bashrc  # or source ~/.zshrc
```

**Verify Installation:**
```bash
echo $CATALINA_HOME
ls $CATALINA_HOME/bin
```

### Step 3: Install MySQL

#### macOS (using Homebrew)
```bash
brew install mysql
brew services start mysql

# Secure MySQL installation
mysql_secure_installation
```

#### Linux (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install mysql-server
sudo systemctl start mysql
sudo systemctl enable mysql

# Secure MySQL installation
sudo mysql_secure_installation
```

#### Windows
1. Download MySQL from https://dev.mysql.com/downloads/installer/
2. Run the installer
3. Choose "Developer Default" setup
4. Set root password during installation

**Verify Installation:**
```bash
mysql --version
```

**Test MySQL Connection:**
```bash
mysql -u root -p
```

### Step 4: Download MySQL Connector/J

The MySQL JDBC driver is required for database connectivity.

1. **Download:**
   - Visit: https://dev.mysql.com/downloads/connector/j/
   - Select "Platform Independent" version
   - Download the ZIP archive

2. **Extract and Copy:**
   ```bash
   # Extract the downloaded file
   unzip mysql-connector-j-8.1.0.zip
   
   # Copy JAR to project lib directory
   cp mysql-connector-j-8.1.0/mysql-connector-j-8.1.0.jar \
      /path/to/assignment-portal/WEB-INF/lib/
   ```

## 🗄️ Database Setup

### Step 1: Create Database

**Option A: Using MySQL Command Line**
```bash
# Login to MySQL
mysql -u root -p

# Run the schema file
source /path/to/assignment-portal/database/schema.sql
```

**Option B: Using Command Line Directly**
```bash
mysql -u root -p < database/schema.sql
```

### Step 2: Verify Database Creation

```sql
-- Login to MySQL
mysql -u root -p

-- Switch to database
USE assignment_portal;

-- Show tables
SHOW TABLES;

-- Check sample data
SELECT * FROM users;
SELECT * FROM courses;
SELECT * FROM assignments;
```

Expected tables:
```
+---------------------------+
| Tables_in_assignment_portal |
+---------------------------+
| activity_log              |
| assignments               |
| courses                   |
| enrollments               |
| submissions               |
| users                     |
+---------------------------+
```

### Step 3: Verify Sample Data

```sql
-- Check users (should have 3 default users)
SELECT username, role, email FROM users;

-- Expected output:
-- +-------------+---------+--------------------------------+
-- | username    | role    | email                          |
-- +-------------+---------+--------------------------------+
-- | admin       | ADMIN   | admin@assignment-portal.com    |
-- | john.smith  | TEACHER | john.smith@university.edu      |
-- | alice.brown | STUDENT | alice.brown@student.edu        |
-- +-------------+---------+--------------------------------+
```

## ⚙️ Configuration

### Step 1: Configure Database Connection

Edit `database/db.properties`:

```properties
# Database URL (update if using different host/port)
db.url=jdbc:mysql://localhost:3306/assignment_portal?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC

# Database Credentials (update with your MySQL credentials)
db.username=root
db.password=your_mysql_password

# Driver (no change needed)
db.driver=com.mysql.cj.jdbc.Driver

# Connection Pool Settings (adjust based on load)
db.pool.initialSize=5
db.pool.maxTotal=20
db.pool.maxIdle=10
db.pool.minIdle=5
db.pool.maxWaitMillis=10000
```

### Step 2: Copy Configuration to Runtime Location

```bash
# Copy db.properties to WEB-INF/classes (for runtime)
cp database/db.properties WEB-INF/classes/
```

### Step 3: Configure File Upload Directory

The application stores uploaded files in `/uploads` by default.

**Create Upload Directory:**

```bash
# Create uploads directory in Tomcat
sudo mkdir -p $CATALINA_HOME/webapps/assignment-portal/uploads
sudo chown -R $USER:$USER $CATALINA_HOME/webapps/assignment-portal/uploads
sudo chmod 755 $CATALINA_HOME/webapps/assignment-portal/uploads
```

**Or configure a custom location in `web.xml`:**
```xml
<context-param>
    <param-name>uploadDirectory</param-name>
    <param-value>/path/to/your/uploads</param-value>
</context-param>
```

## 🔨 Compilation

### Option 1: Automated Compilation (Recommended)

```bash
# Make script executable
chmod +x compile.sh

# Run compilation script
./compile.sh
```

The script will:
- ✅ Check for Java and Tomcat
- ✅ Locate required JARs (servlet-api, MySQL connector)
- ✅ Clean old compiled files
- ✅ Compile all Java source files
- ✅ Display compilation summary

### Option 2: Manual Compilation

```bash
# Set classpath
export CLASSPATH="$CATALINA_HOME/lib/servlet-api.jar:WEB-INF/lib/mysql-connector-j-8.1.0.jar"

# Clean old classes
find WEB-INF/classes/com -name "*.class" -delete

# Compile all Java files
javac -d WEB-INF/classes -cp $CLASSPATH \
  WEB-INF/classes/com/assignmentportal/model/*.java \
  WEB-INF/classes/com/assignmentportal/dao/*.java \
  WEB-INF/classes/com/assignmentportal/util/*.java \
  WEB-INF/classes/com/assignmentportal/servlet/*.java
```

**Verify Compilation:**
```bash
# Check for compiled .class files
find WEB-INF/classes/com -name "*.class"

# Should show all compiled classes
```

## 🚀 Deployment

### Option 1: Automated Deployment (Recommended)

```bash
# Make script executable
chmod +x deploy.sh

# Run deployment script
./deploy.sh
```

The script will:
- ✅ Check compilation status
- ✅ Stop Tomcat (if running)
- ✅ Clean old deployment
- ✅ Copy files to Tomcat webapps
- ✅ Set proper permissions
- ✅ Start Tomcat
- ✅ Display access URLs

### Option 2: Manual Deployment

```bash
# Stop Tomcat (if running)
$CATALINA_HOME/bin/shutdown.sh

# Remove old deployment
rm -rf $CATALINA_HOME/webapps/assignment-portal
rm -rf $CATALINA_HOME/webapps/assignment-portal.war

# Create deployment directory
mkdir -p $CATALINA_HOME/webapps/assignment-portal

# Copy all files
cp -r * $CATALINA_HOME/webapps/assignment-portal/

# Start Tomcat
$CATALINA_HOME/bin/startup.sh
```

### Option 3: One-Command Setup (Complete Setup)

For first-time setup, use the automated setup script:

```bash
# Make script executable
chmod +x setup.sh

# Run complete setup
./setup.sh
```

This will perform:
1. Prerequisites check
2. Database creation
3. Compilation
4. Deployment
5. Server startup

## ✅ Verification

### Step 1: Check Tomcat Logs

```bash
# View Tomcat logs
tail -f $CATALINA_HOME/logs/catalina.out

# Look for:
# - "Deploying web application directory" message
# - No exception stack traces
# - "Server startup in [X] milliseconds"
```

### Step 2: Test Application Access

**Open your browser and visit:**
```
http://localhost:8080/assignment-portal/
```

You should see the Assignment Portal landing page.

### Step 3: Test Login

**Click "Login" and try these credentials:**

**Student Login:**
- Username: `alice.brown`
- Password: `student123`

**Teacher Login:**
- Username: `john.smith`
- Password: `teacher123`

**Admin Login:**
- Username: `admin`
- Password: `admin123`

### Step 4: Verify Database Connection

Login as a student and check if:
- ✅ Dashboard loads successfully
- ✅ Courses are displayed
- ✅ Assignments are visible
- ✅ No database errors in logs

## 🔧 Troubleshooting

### Issue 1: Compilation Errors

**Problem:** `javac: command not found`

**Solution:**
```bash
# Verify Java installation
which javac
java -version

# If not found, install JDK (see Step 1)
# Add to PATH if needed
export PATH=$PATH:/path/to/jdk/bin
```

---

**Problem:** `package javax.servlet does not exist`

**Solution:**
```bash
# Verify servlet-api.jar exists
ls $CATALINA_HOME/lib/servlet-api.jar

# Check CLASSPATH includes servlet-api
echo $CLASSPATH
```

---

### Issue 2: Database Connection Errors

**Problem:** `Communications link failure`

**Solution:**
```bash
# Check MySQL is running
sudo systemctl status mysql  # Linux
brew services list | grep mysql  # macOS

# Start MySQL if stopped
sudo systemctl start mysql  # Linux
brew services start mysql  # macOS

# Verify connection
mysql -u root -p -e "SELECT 1"
```

---

**Problem:** `Access denied for user 'root'@'localhost'`

**Solution:**
```bash
# Reset MySQL root password
sudo mysql
ALTER USER 'root'@'localhost' IDENTIFIED BY 'new_password';
FLUSH PRIVILEGES;

# Update db.properties with new password
```

---

### Issue 3: Tomcat Deployment Issues

**Problem:** `404 - Application not found`

**Solution:**
```bash
# Verify deployment
ls -la $CATALINA_HOME/webapps/assignment-portal

# Check Tomcat logs
tail -f $CATALINA_HOME/logs/catalina.out

# Redeploy
./deploy.sh
```

---

**Problem:** Port 8080 already in use

**Solution:**
```bash
# Find process using port 8080
lsof -i :8080  # macOS/Linux
netstat -ano | findstr :8080  # Windows

# Kill the process or change Tomcat port
# Edit $CATALINA_HOME/conf/server.xml
# Change <Connector port="8080" ...> to another port
```

---

### Issue 4: File Upload Errors

**Problem:** `java.io.IOException: The temporary upload location is not valid`

**Solution:**
```bash
# Create temp directory
sudo mkdir -p /tmp/tomcat
sudo chown -R $USER:$USER /tmp/tomcat

# Or create in Tomcat work directory
mkdir -p $CATALINA_HOME/work/Tomcat/localhost/assignment-portal
```

---

### Issue 5: Session/Cookie Issues

**Problem:** Login successful but redirects to login page

**Solution:**
- Clear browser cache and cookies
- Check browser console for errors
- Verify session timeout in web.xml
- Check if cookies are enabled in browser

---

## 📝 Post-Setup Configuration

### 1. Change Default Passwords

**IMPORTANT:** Change default passwords before production use!

```sql
mysql -u root -p assignment_portal

-- Update admin password
UPDATE users SET password = SHA2('new_secure_password', 256) 
WHERE username = 'admin';

-- Update teacher password
UPDATE users SET password = SHA2('new_secure_password', 256) 
WHERE username = 'john.smith';

-- Update student password
UPDATE users SET password = SHA2('new_secure_password', 256) 
WHERE username = 'alice.brown';
```

### 2. Configure Email (Optional)

For email notifications, add SMTP configuration to `db.properties`:

```properties
# Email Configuration (Optional)
email.smtp.host=smtp.gmail.com
email.smtp.port=587
email.smtp.username=your-email@gmail.com
email.smtp.password=your-app-password
email.from=noreply@assignment-portal.com
```

### 3. Enable HTTPS (Production)

For production deployment, enable HTTPS:

1. Obtain SSL certificate
2. Configure Tomcat SSL connector in `server.xml`
3. Redirect HTTP to HTTPS

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed instructions.

## 🎉 Next Steps

After successful setup:

1. **Read Documentation:**
   - [ARCHITECTURE.md](ARCHITECTURE.md) - Understand system design
   - [DATABASE.md](DATABASE.md) - Learn database structure
   - [API.md](API.md) - Explore API endpoints
   - [DEVELOPMENT.md](DEVELOPMENT.md) - Development guidelines

2. **Test Features:**
   - Create new users
   - Add courses
   - Create assignments
   - Upload submissions
   - Grade submissions

3. **Customize:**
   - Modify JSP pages for UI changes
   - Add new features
   - Integrate with external services

## 📞 Support

If you encounter issues not covered here:
- Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- Review Tomcat logs
- Check MySQL error logs
- Open an issue on GitHub

---

**Setup completed successfully! 🎊**

You're now ready to use the Assignment Portal!
