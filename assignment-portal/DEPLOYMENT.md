# Deployment Guide - Assignment Portal

Complete guide for deploying the Assignment Portal to production environments.

## 📋 Table of Contents
- [Pre-Deployment Checklist](#pre-deployment-checklist)
- [Production Environment Setup](#production-environment-setup)
- [Deployment Methods](#deployment-methods)
- [HTTPS Configuration](#https-configuration)
- [Performance Optimization](#performance-optimization)
- [Monitoring & Logging](#monitoring--logging)
- [Backup Strategy](#backup-strategy)
- [Maintenance](#maintenance)
- [Rollback Procedures](#rollback-procedures)

## ✅ Pre-Deployment Checklist

### Security Checklist

- [ ] Change all default passwords
- [ ] Enable HTTPS/SSL
- [ ] Configure secure session cookies
- [ ] Set proper file permissions
- [ ] Disable directory listing
- [ ] Remove debug/test code
- [ ] Enable security headers
- [ ] Configure firewall rules
- [ ] Set up database user with minimal privileges
- [ ] Review and update `web.xml` security constraints

### Configuration Checklist

- [ ] Update database connection settings
- [ ] Configure production URLs
- [ ] Set appropriate session timeout
- [ ] Configure file upload paths
- [ ] Set up email notifications (if applicable)
- [ ] Configure logging levels
- [ ] Set proper timezone
- [ ] Configure connection pool size for production load

### Code Checklist

- [ ] All code compiled without errors
- [ ] Remove console.log/System.out.println statements
- [ ] Update version numbers
- [ ] Minimize and compress static assets
- [ ] Test all critical flows
- [ ] Verify database migrations

## 🖥️ Production Environment Setup

### Server Requirements

**Minimum Specifications:**
- **CPU:** 2 cores
- **RAM:** 4 GB
- **Storage:** 50 GB SSD
- **OS:** Ubuntu 20.04 LTS or CentOS 8
- **Java:** OpenJDK 11 or higher
- **Database:** MySQL 8.0 or PostgreSQL 12
- **Web Server:** Apache Tomcat 9.0

**Recommended Specifications:**
- **CPU:** 4+ cores
- **RAM:** 8+ GB
- **Storage:** 100+ GB SSD
- **Load Balancer:** Nginx or Apache HTTP Server

### 1. Server Preparation

#### Ubuntu/Debian

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Java
sudo apt install openjdk-11-jdk -y

# Verify installation
java -version

# Install MySQL
sudo apt install mysql-server -y
sudo mysql_secure_installation

# Create application user
sudo useradd -m -d /opt/assignmentportal -s /bin/bash assignmentportal
sudo passwd assignmentportal
```

#### CentOS/RHEL

```bash
# Update system
sudo yum update -y

# Install Java
sudo yum install java-11-openjdk java-11-openjdk-devel -y

# Install MySQL
sudo yum install mysql-server -y
sudo systemctl start mysqld
sudo systemctl enable mysqld
sudo mysql_secure_installation
```

### 2. Install Apache Tomcat

```bash
# Download Tomcat
cd /opt
sudo wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.80/bin/apache-tomcat-9.0.80.tar.gz

# Extract
sudo tar xzvf apache-tomcat-9.0.80.tar.gz
sudo mv apache-tomcat-9.0.80 tomcat9

# Set ownership
sudo chown -R assignmentportal:assignmentportal /opt/tomcat9

# Create systemd service
sudo nano /etc/systemd/system/tomcat.service
```

**Tomcat Service File:**
```ini
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking

Environment=JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
Environment=CATALINA_PID=/opt/tomcat9/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat9
Environment=CATALINA_BASE=/opt/tomcat9
Environment='CATALINA_OPTS=-Xms512M -Xmx2048M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

ExecStart=/opt/tomcat9/bin/startup.sh
ExecStop=/opt/tomcat9/bin/shutdown.sh

User=assignmentportal
Group=assignmentportal
UMask=0007
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
```

```bash
# Reload systemd
sudo systemctl daemon-reload

# Start Tomcat
sudo systemctl start tomcat
sudo systemctl enable tomcat

# Check status
sudo systemctl status tomcat
```

### 3. Configure Firewall

```bash
# UFW (Ubuntu)
sudo ufw allow 8080/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 3306/tcp  # MySQL (restrict to localhost in production)
sudo ufw enable

# Firewalld (CentOS)
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --reload
```

### 4. Setup Production Database

```bash
# Login to MySQL
sudo mysql -u root -p
```

```sql
-- Create production database
CREATE DATABASE assignment_portal CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create application user
CREATE USER 'app_user'@'localhost' IDENTIFIED BY 'strong_password_here';

-- Grant privileges
GRANT SELECT, INSERT, UPDATE, DELETE ON assignment_portal.* TO 'app_user'@'localhost';
FLUSH PRIVILEGES;

-- Exit
EXIT;
```

```bash
# Import schema
mysql -u app_user -p assignment_portal < /path/to/schema.sql

# Verify
mysql -u app_user -p assignment_portal -e "SHOW TABLES;"
```

### 5. Configure Application

**Update Database Configuration:**

```bash
# Edit production config
sudo nano /opt/assignmentportal/WEB-INF/classes/db.properties
```

```properties
# Production Database Configuration
db.url=jdbc:mysql://localhost:3306/assignment_portal?useSSL=true&requireSSL=true&serverTimezone=UTC
db.username=app_user
db.password=strong_password_here
db.driver=com.mysql.cj.jdbc.Driver

# Production Connection Pool
db.pool.initialSize=10
db.pool.maxTotal=50
db.pool.maxIdle=20
db.pool.minIdle=10
db.pool.maxWaitMillis=30000

# Production File Upload
upload.directory=/var/assignmentportal/uploads
upload.maxFileSize=10485760

# Session Configuration
session.timeout=30
```

**Create Upload Directory:**

```bash
# Create directories
sudo mkdir -p /var/assignmentportal/uploads
sudo chown -R assignmentportal:assignmentportal /var/assignmentportal
sudo chmod 755 /var/assignmentportal/uploads
```

## 🚀 Deployment Methods

### Method 1: Manual Deployment

**Step 1: Prepare Application**

```bash
# On development machine
cd /path/to/assignment-portal

# Compile
./compile.sh

# Create WAR file (optional)
jar -cvf assignment-portal.war *

# Or create zip
zip -r assignment-portal.zip * -x "*.git*" "*.class" "*.log"
```

**Step 2: Transfer to Server**

```bash
# Using SCP
scp assignment-portal.zip user@server-ip:/tmp/

# Or using rsync
rsync -avz --exclude '.git' /path/to/assignment-portal/ \
  user@server-ip:/opt/assignmentportal/
```

**Step 3: Deploy on Server**

```bash
# SSH to server
ssh user@server-ip

# Extract (if using zip)
cd /opt
sudo unzip /tmp/assignment-portal.zip -d /opt/assignmentportal/

# Set permissions
sudo chown -R assignmentportal:assignmentportal /opt/assignmentportal

# Copy to Tomcat webapps
sudo cp -r /opt/assignmentportal /opt/tomcat9/webapps/assignment-portal

# Restart Tomcat
sudo systemctl restart tomcat

# Check logs
tail -f /opt/tomcat9/logs/catalina.out
```

### Method 2: WAR File Deployment

```bash
# Copy WAR file
sudo cp assignment-portal.war /opt/tomcat9/webapps/

# Tomcat will auto-deploy
# Check deployment
ls -la /opt/tomcat9/webapps/

# Monitor logs
tail -f /opt/tomcat9/logs/catalina.out
```

### Method 3: Automated Deployment with Script

**Create deployment script:**

```bash
#!/bin/bash
# deploy-production.sh

set -e  # Exit on error

echo "🚀 Starting production deployment..."

# Configuration
APP_NAME="assignment-portal"
TOMCAT_HOME="/opt/tomcat9"
DEPLOY_USER="assignmentportal"
BACKUP_DIR="/opt/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Create backup
echo "📦 Creating backup..."
sudo -u $DEPLOY_USER mkdir -p $BACKUP_DIR
sudo -u $DEPLOY_USER cp -r $TOMCAT_HOME/webapps/$APP_NAME \
  $BACKUP_DIR/${APP_NAME}_${TIMESTAMP}

# Stop Tomcat
echo "⏸️  Stopping Tomcat..."
sudo systemctl stop tomcat

# Remove old deployment
echo "🗑️  Removing old deployment..."
sudo rm -rf $TOMCAT_HOME/webapps/$APP_NAME
sudo rm -rf $TOMCAT_HOME/webapps/${APP_NAME}.war

# Copy new version
echo "📂 Copying new version..."
sudo cp /tmp/$APP_NAME.war $TOMCAT_HOME/webapps/
sudo chown $DEPLOY_USER:$DEPLOY_USER $TOMCAT_HOME/webapps/${APP_NAME}.war

# Start Tomcat
echo "▶️  Starting Tomcat..."
sudo systemctl start tomcat

# Wait for deployment
echo "⏳ Waiting for deployment..."
sleep 30

# Check if deployed
if [ -d "$TOMCAT_HOME/webapps/$APP_NAME" ]; then
    echo "✅ Deployment successful!"
    
    # Test application
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
      http://localhost:8080/$APP_NAME/)
    
    if [ $HTTP_CODE -eq 200 ] || [ $HTTP_CODE -eq 302 ]; then
        echo "✅ Application is responding (HTTP $HTTP_CODE)"
    else
        echo "⚠️  Warning: Application returned HTTP $HTTP_CODE"
    fi
else
    echo "❌ Deployment failed!"
    echo "🔄 Rolling back..."
    sudo systemctl stop tomcat
    sudo cp -r $BACKUP_DIR/${APP_NAME}_${TIMESTAMP} \
      $TOMCAT_HOME/webapps/$APP_NAME
    sudo systemctl start tomcat
    exit 1
fi

# Clean old backups (keep last 5)
echo "🧹 Cleaning old backups..."
cd $BACKUP_DIR
ls -t | tail -n +6 | xargs -r rm -rf

echo "🎉 Deployment complete!"
```

```bash
# Make executable
chmod +x deploy-production.sh

# Run deployment
sudo ./deploy-production.sh
```

## 🔒 HTTPS Configuration

### Option 1: Using Let's Encrypt (Free SSL)

**Install Certbot:**

```bash
# Ubuntu/Debian
sudo apt install certbot python3-certbot-nginx -y

# CentOS/RHEL
sudo yum install certbot python3-certbot-nginx -y
```

**Obtain Certificate:**

```bash
# Get certificate
sudo certbot certonly --standalone -d yourdomain.com -d www.yourdomain.com

# Certificates saved to:
# /etc/letsencrypt/live/yourdomain.com/fullchain.pem
# /etc/letsencrypt/live/yourdomain.com/privkey.pem
```

**Configure Tomcat SSL:**

```bash
# Edit server.xml
sudo nano /opt/tomcat9/conf/server.xml
```

```xml
<!-- Add SSL connector -->
<Connector port="8443" protocol="org.apache.coyote.http11.Http11NioProtocol"
           maxThreads="150" SSLEnabled="true">
    <SSLHostConfig>
        <Certificate certificateFile="/etc/letsencrypt/live/yourdomain.com/fullchain.pem"
                     certificateKeyFile="/etc/letsencrypt/live/yourdomain.com/privkey.pem"
                     type="RSA" />
    </SSLHostConfig>
</Connector>

<!-- Redirect HTTP to HTTPS -->
<Connector port="8080" protocol="HTTP/1.1"
           connectionTimeout="20000"
           redirectPort="8443" />
```

**Auto-renewal:**

```bash
# Test renewal
sudo certbot renew --dry-run

# Add cron job for auto-renewal
sudo crontab -e

# Add this line:
0 0 1 * * /usr/bin/certbot renew --quiet && systemctl restart tomcat
```

### Option 2: Using Nginx as Reverse Proxy (Recommended)

**Install Nginx:**

```bash
sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
```

**Configure Nginx:**

```bash
sudo nano /etc/nginx/sites-available/assignment-portal
```

```nginx
upstream tomcat {
    server 127.0.0.1:8080;
}

server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name yourdomain.com www.yourdomain.com;

    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Logging
    access_log /var/log/nginx/assignment-portal-access.log;
    error_log /var/log/nginx/assignment-portal-error.log;

    # File Upload Size
    client_max_body_size 10M;

    location / {
        proxy_pass http://tomcat/assignment-portal/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket support (if needed)
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    # Static files caching
    location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
        proxy_pass http://tomcat;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
```

```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/assignment-portal \
  /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx
```

## ⚡ Performance Optimization

### 1. Tomcat Tuning

**Edit catalina.sh or setenv.sh:**

```bash
sudo nano /opt/tomcat9/bin/setenv.sh
```

```bash
#!/bin/bash

# Memory Settings
export CATALINA_OPTS="$CATALINA_OPTS -Xms1024M"
export CATALINA_OPTS="$CATALINA_OPTS -Xmx2048M"
export CATALINA_OPTS="$CATALINA_OPTS -XX:MetaspaceSize=256M"
export CATALINA_OPTS="$CATALINA_OPTS -XX:MaxMetaspaceSize=512M"

# GC Settings
export CATALINA_OPTS="$CATALINA_OPTS -XX:+UseG1GC"
export CATALINA_OPTS="$CATALINA_OPTS -XX:+UseStringDeduplication"

# Performance Settings
export CATALINA_OPTS="$CATALINA_OPTS -server"
export CATALINA_OPTS="$CATALINA_OPTS -Djava.awt.headless=true"

# Logging
export CATALINA_OPTS="$CATALINA_OPTS -Djava.util.logging.config.file=/opt/tomcat9/conf/logging.properties"
```

### 2. Database Optimization

```sql
-- Create indexes for frequently queried columns
CREATE INDEX idx_submissions_student_date 
ON submissions(student_id, submission_date);

CREATE INDEX idx_assignments_course_due 
ON assignments(course_id, due_date);

-- Optimize tables
OPTIMIZE TABLE users, courses, assignments, submissions, enrollments;

-- Analyze tables for query optimization
ANALYZE TABLE users, courses, assignments, submissions, enrollments;
```

**MySQL Configuration:**

```bash
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
```

```ini
[mysqld]
# Buffer pool size (70-80% of RAM for dedicated DB server)
innodb_buffer_pool_size = 2G

# Connection settings
max_connections = 200
max_connect_errors = 100

# Query cache (for MySQL 5.7, removed in 8.0)
query_cache_size = 0
query_cache_type = 0

# Logging
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow-query.log
long_query_time = 2
```

### 3. Connection Pool Optimization

Update `db.properties`:

```properties
# Increase pool size for production
db.pool.initialSize=20
db.pool.maxTotal=100
db.pool.maxIdle=50
db.pool.minIdle=20
db.pool.maxWaitMillis=30000

# Connection validation
db.pool.testOnBorrow=true
db.pool.testWhileIdle=true
db.pool.validationQuery=SELECT 1
```

## 📊 Monitoring & Logging

### 1. Application Monitoring

**Install monitoring script:**

```bash
sudo nano /usr/local/bin/monitor-app.sh
```

```bash
#!/bin/bash

APP_URL="http://localhost:8080/assignment-portal/"
EMAIL="admin@yourdomain.com"

# Check if application is responding
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" $APP_URL)

if [ $HTTP_CODE -ne 200 ] && [ $HTTP_CODE -ne 302 ]; then
    echo "Application is down! HTTP Code: $HTTP_CODE" | \
      mail -s "ALERT: Assignment Portal Down" $EMAIL
    
    # Restart Tomcat
    sudo systemctl restart tomcat
fi
```

```bash
# Make executable
sudo chmod +x /usr/local/bin/monitor-app.sh

# Add to crontab (check every 5 minutes)
sudo crontab -e
*/5 * * * * /usr/local/bin/monitor-app.sh
```

### 2. Log Management

**Configure log rotation:**

```bash
sudo nano /etc/logrotate.d/tomcat
```

```
/opt/tomcat9/logs/catalina.out {
    daily
    rotate 30
    compress
    missingok
    notifempty
    copytruncate
}

/opt/tomcat9/logs/*.log {
    daily
    rotate 14
    compress
    missingok
    notifempty
    copytruncate
}
```

## 💾 Backup Strategy

### 1. Automated Database Backup

```bash
sudo nano /usr/local/bin/backup-db.sh
```

```bash
#!/bin/bash

# Configuration
DB_NAME="assignment_portal"
DB_USER="app_user"
DB_PASS="password"
BACKUP_DIR="/var/backups/mysql"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=30

# Create backup directory
mkdir -p $BACKUP_DIR

# Perform backup
mysqldump -u $DB_USER -p$DB_PASS \
  --single-transaction \
  --routines \
  --triggers \
  $DB_NAME | gzip > $BACKUP_DIR/${DB_NAME}_${DATE}.sql.gz

# Remove old backups
find $BACKUP_DIR -name "*.sql.gz" -mtime +$RETENTION_DAYS -delete

echo "Backup completed: ${DB_NAME}_${DATE}.sql.gz"
```

```bash
# Make executable
sudo chmod +x /usr/local/bin/backup-db.sh

# Schedule daily backup at 2 AM
sudo crontab -e
0 2 * * * /usr/local/bin/backup-db.sh
```

### 2. File Backup

```bash
#!/bin/bash
# backup-files.sh

UPLOAD_DIR="/var/assignmentportal/uploads"
BACKUP_DIR="/var/backups/uploads"
DATE=$(date +%Y%m%d)

# Create backup
tar -czf $BACKUP_DIR/uploads_${DATE}.tar.gz $UPLOAD_DIR

# Remove backups older than 30 days
find $BACKUP_DIR -name "uploads_*.tar.gz" -mtime +30 -delete
```

## 🔄 Rollback Procedures

### Quick Rollback

```bash
#!/bin/bash
# rollback.sh

BACKUP_DIR="/opt/backups"
TOMCAT_HOME="/opt/tomcat9"
APP_NAME="assignment-portal"

# Stop Tomcat
sudo systemctl stop tomcat

# Get latest backup
LATEST_BACKUP=$(ls -t $BACKUP_DIR | head -1)

# Remove current deployment
sudo rm -rf $TOMCAT_HOME/webapps/$APP_NAME

# Restore backup
sudo cp -r $BACKUP_DIR/$LATEST_BACKUP \
  $TOMCAT_HOME/webapps/$APP_NAME

# Start Tomcat
sudo systemctl start tomcat

echo "Rolled back to: $LATEST_BACKUP"
```

---

**Production deployment complete! 🚀**
