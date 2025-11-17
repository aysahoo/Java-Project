#!/bin/bash

# Assignment Portal - Deployment Script
# This script deploys the application to Tomcat

echo "========================================="
echo "  Assignment Portal - Deployment Script"
echo "========================================="
echo ""

# Set CATALINA_HOME if not already set
if [ -z "$CATALINA_HOME" ]; then
    if [ -d "/usr/local/tomcat" ]; then
        export CATALINA_HOME="/usr/local/tomcat"
    elif [ -d "/opt/tomcat" ]; then
        export CATALINA_HOME="/opt/tomcat"
    elif [ -d "$HOME/tomcat" ]; then
        export CATALINA_HOME="$HOME/tomcat"
    else
        echo "❌ Error: CATALINA_HOME not set"
        echo "Please set CATALINA_HOME environment variable:"
        echo "  export CATALINA_HOME=/path/to/tomcat"
        exit 1
    fi
fi

echo "✓ Using Tomcat: $CATALINA_HOME"

# Check if Tomcat exists
if [ ! -d "$CATALINA_HOME" ]; then
    echo "❌ Error: Tomcat directory not found at $CATALINA_HOME"
    exit 1
fi

# Application name
APP_NAME="assignment-portal"
DEPLOY_DIR="$CATALINA_HOME/webapps/$APP_NAME"

echo ""
echo "📦 Preparing deployment..."

# Check if compiled
if [ ! -d "WEB-INF/classes/com" ]; then
    echo "⚠️  Warning: No compiled classes found"
    read -p "Compile now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ./compile.sh
        if [ $? -ne 0 ]; then
            echo "❌ Compilation failed"
            exit 1
        fi
    else
        exit 1
    fi
fi

# Check if app already deployed
if [ -d "$DEPLOY_DIR" ]; then
    echo "⚠️  Application already exists at $DEPLOY_DIR"
    read -p "Remove and redeploy? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🗑️  Removing old deployment..."
        rm -rf "$DEPLOY_DIR"
    else
        exit 1
    fi
fi

# Create deployment directory
echo "📁 Creating deployment directory..."
mkdir -p "$DEPLOY_DIR"

# Copy files
echo "📋 Copying application files..."
cp -r WEB-INF "$DEPLOY_DIR/"
cp -r jsp "$DEPLOY_DIR/" 2>/dev/null || true
cp -r css "$DEPLOY_DIR/" 2>/dev/null || true
cp -r js "$DEPLOY_DIR/" 2>/dev/null || true
cp index.html "$DEPLOY_DIR/" 2>/dev/null || true

# Create uploads directory
echo "📁 Creating uploads directory..."
mkdir -p "$DEPLOY_DIR/uploads"
chmod 755 "$DEPLOY_DIR/uploads"

# Copy database properties to classpath
echo "📝 Copying configuration files..."
if [ -f "database/db.properties" ]; then
    cp database/db.properties "$DEPLOY_DIR/WEB-INF/classes/"
fi

echo ""
echo "✅ Deployment successful!"
echo ""
echo "📊 Deployment summary:"
echo "  - Application: $APP_NAME"
echo "  - Location: $DEPLOY_DIR"
echo ""
echo "🚀 Next steps:"
echo "  1. Import database: mysql -u root -p < database/schema.sql"
echo "  2. Update db.properties with your credentials"
echo "  3. Start Tomcat: $CATALINA_HOME/bin/startup.sh"
echo "  4. Access: http://localhost:8080/$APP_NAME/"
echo ""
echo "📝 Default credentials:"
echo "  Admin: admin / admin123"
echo "  Teacher: john.smith / teacher123"
echo "  Student: alice.brown / student123"
echo ""
