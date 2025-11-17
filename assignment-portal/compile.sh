#!/bin/bash

# Assignment Portal - Compilation Script
# This script compiles all Java files for the Assignment Portal

echo "========================================="
echo "  Assignment Portal - Compilation Script"
echo "========================================="
echo ""

# Set CATALINA_HOME if not already set
if [ -z "$CATALINA_HOME" ]; then
    # Try to find Tomcat using common locations
    if [ -d "/usr/local/tomcat" ]; then
        export CATALINA_HOME="/usr/local/tomcat"
    elif [ -d "/opt/tomcat" ]; then
        export CATALINA_HOME="/opt/tomcat"
    elif [ -d "$HOME/tomcat" ]; then
        export CATALINA_HOME="$HOME/tomcat"
    else
        echo "❌ Error: CATALINA_HOME not set and Tomcat not found in common locations"
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

# Check for servlet-api.jar
SERVLET_API="$CATALINA_HOME/lib/servlet-api.jar"
if [ ! -f "$SERVLET_API" ]; then
    echo "❌ Error: servlet-api.jar not found at $SERVLET_API"
    exit 1
fi

# Check for MySQL connector
MYSQL_JAR=$(find WEB-INF/lib -name "mysql-connector-*.jar" 2>/dev/null | head -n 1)
if [ -z "$MYSQL_JAR" ]; then
    echo "⚠️  Warning: MySQL connector not found in WEB-INF/lib/"
    echo "Please download MySQL Connector/J from:"
    echo "  https://dev.mysql.com/downloads/connector/j/"
    echo "And place it in WEB-INF/lib/"
    echo ""
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
    CLASSPATH="$SERVLET_API"
else
    echo "✓ Found MySQL connector: $MYSQL_JAR"
    CLASSPATH="$SERVLET_API:$MYSQL_JAR"
fi

echo ""
echo "📦 Setting up classpath..."
export CLASSPATH

echo "🧹 Cleaning old compiled files..."
find WEB-INF/classes/com -name "*.class" -type f -delete 2>/dev/null

echo "📝 Compiling Java files..."
echo ""

# Find all Java files
JAVA_FILES=$(find WEB-INF/classes/com -name "*.java" -type f)

if [ -z "$JAVA_FILES" ]; then
    echo "❌ Error: No Java files found to compile"
    exit 1
fi

# Count files
FILE_COUNT=$(echo "$JAVA_FILES" | wc -l | tr -d ' ')
echo "Found $FILE_COUNT Java files to compile"
echo ""

# Compile all files
javac -d WEB-INF/classes -cp "$CLASSPATH" $JAVA_FILES

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Compilation successful!"
    echo ""
    echo "📊 Compilation summary:"
    echo "  - Source files: $FILE_COUNT"
    echo "  - Compiled classes: $(find WEB-INF/classes/com -name "*.class" -type f | wc -l | tr -d ' ')"
    echo ""
    echo "📂 Next steps:"
    echo "  1. Copy db.properties to WEB-INF/classes/ or classpath"
    echo "  2. Deploy to Tomcat: cp -r . $CATALINA_HOME/webapps/assignment-portal/"
    echo "  3. Start Tomcat: $CATALINA_HOME/bin/startup.sh"
    echo "  4. Access: http://localhost:8080/assignment-portal/"
    echo ""
else
    echo ""
    echo "❌ Compilation failed!"
    echo "Please check the error messages above"
    exit 1
fi
