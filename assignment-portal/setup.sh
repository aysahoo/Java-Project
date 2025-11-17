#!/bin/bash

# Assignment Portal - Complete Setup Script
# This script performs complete setup: database, compilation, and deployment

echo "========================================="
echo "  Assignment Portal - Complete Setup"
echo "========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Step 1: Check prerequisites
echo "📋 Checking prerequisites..."
echo ""

# Check Java
if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
    print_success "Java found: $JAVA_VERSION"
else
    print_error "Java not found. Please install Java 8 or higher"
    exit 1
fi

# Check javac
if command -v javac &> /dev/null; then
    print_success "Java compiler found"
else
    print_error "Java compiler not found. Please install JDK"
    exit 1
fi

# Check MySQL
if command -v mysql &> /dev/null; then
    print_success "MySQL client found"
else
    print_warning "MySQL client not found. Database setup will be skipped"
fi

# Check Tomcat
if [ -z "$CATALINA_HOME" ]; then
    print_warning "CATALINA_HOME not set. Will search for Tomcat..."
    if [ -d "/usr/local/tomcat" ]; then
        export CATALINA_HOME="/usr/local/tomcat"
        print_success "Found Tomcat at $CATALINA_HOME"
    elif [ -d "/opt/tomcat" ]; then
        export CATALINA_HOME="/opt/tomcat"
        print_success "Found Tomcat at $CATALINA_HOME"
    else
        print_error "Tomcat not found. Please install Tomcat and set CATALINA_HOME"
        exit 1
    fi
else
    print_success "Tomcat found at $CATALINA_HOME"
fi

echo ""

# Step 2: Database setup
echo "📦 Step 1: Database Setup"
echo ""

if command -v mysql &> /dev/null; then
    read -p "Do you want to set up the database? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Enter MySQL root password:"
        read -s MYSQL_PASSWORD
        
        echo "Setting up database..."
        mysql -u root -p"$MYSQL_PASSWORD" < database/schema.sql
        
        if [ $? -eq 0 ]; then
            print_success "Database created successfully"
            
            # Update db.properties
            echo ""
            echo "Updating database configuration..."
            read -p "MySQL username (default: root): " DB_USER
            DB_USER=${DB_USER:-root}
            
            read -p "MySQL password: " -s DB_PASS
            echo ""
            
            # Update db.properties file
            sed -i.bak "s/db.username=.*/db.username=$DB_USER/" database/db.properties
            sed -i.bak "s/db.password=.*/db.password=$DB_PASS/" database/db.properties
            
            print_success "Database configuration updated"
        else
            print_error "Database setup failed"
            exit 1
        fi
    else
        print_warning "Skipping database setup"
    fi
else
    print_warning "Skipping database setup (MySQL not found)"
fi

echo ""

# Step 3: Compilation
echo "🔨 Step 2: Compilation"
echo ""

chmod +x compile.sh
./compile.sh

if [ $? -ne 0 ]; then
    print_error "Compilation failed"
    exit 1
fi

echo ""

# Step 4: Deployment
echo "🚀 Step 3: Deployment"
echo ""

chmod +x deploy.sh
./deploy.sh

if [ $? -ne 0 ]; then
    print_error "Deployment failed"
    exit 1
fi

echo ""

# Step 5: Start Tomcat
echo "🎯 Step 4: Start Tomcat"
echo ""

read -p "Do you want to start Tomcat now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Starting Tomcat..."
    $CATALINA_HOME/bin/startup.sh
    
    if [ $? -eq 0 ]; then
        print_success "Tomcat started successfully"
        echo ""
        echo "========================================="
        echo "  🎉 Setup Complete!"
        echo "========================================="
        echo ""
        echo "Access your application at:"
        echo "  http://localhost:8080/assignment-portal/"
        echo ""
        echo "Default credentials:"
        echo "  Admin:   admin / admin123"
        echo "  Teacher: john.smith / teacher123"
        echo "  Student: alice.brown / student123"
        echo ""
    else
        print_error "Failed to start Tomcat"
    fi
else
    echo ""
    echo "========================================="
    echo "  Setup Complete!"
    echo "========================================="
    echo ""
    echo "To start the application:"
    echo "  $CATALINA_HOME/bin/startup.sh"
    echo ""
    echo "Then access:"
    echo "  http://localhost:8080/assignment-portal/"
    echo ""
fi
