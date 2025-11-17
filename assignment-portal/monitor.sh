#!/bin/bash

# Assignment Portal - Monitoring Dashboard
# Real-time monitoring for all components

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                                                                ║"
echo "║         🎓 Assignment Portal - Monitoring Dashboard           ║"
echo "║                                                                ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check PostgreSQL Status (Neon)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "� PostgreSQL Database Status (Neon)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Test connection to Neon
if PGPASSWORD='npg_8Wts4DNhpeRY' psql -h ep-floral-bush-a1ft2sv2-pooler.ap-southeast-1.aws.neon.tech -U neondb_owner -d neondb -c "SELECT 1" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ PostgreSQL (Neon) is accessible${NC}"
    
    # Database statistics
    echo ""
    echo "Database Statistics:"
    PGPASSWORD='npg_8Wts4DNhpeRY' psql -h ep-floral-bush-a1ft2sv2-pooler.ap-southeast-1.aws.neon.tech -U neondb_owner -d neondb -c "
        SELECT 'Users' as table_name, COUNT(*) as count FROM users
        UNION ALL
        SELECT 'Courses', COUNT(*) FROM courses
        UNION ALL
        SELECT 'Assignments', COUNT(*) FROM assignments
        UNION ALL
        SELECT 'Submissions', COUNT(*) FROM submissions
        UNION ALL
        SELECT 'Enrollments', COUNT(*) FROM enrollments;
    " 2>/dev/null || echo "Could not fetch database stats"
else
    echo -e "${RED}✗ PostgreSQL (Neon) is not accessible${NC}"
    echo "Check your internet connection and credentials"
fi

echo ""

# Check Tomcat Status
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🐱 Tomcat Server Status"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if lsof -i :8080 > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Tomcat is running on port 8080${NC}"
    
    # Get process info
    TOMCAT_PID=$(lsof -ti :8080)
    echo "Process ID: $TOMCAT_PID"
    
    # Memory usage
    echo ""
    echo "Memory Usage:"
    ps -p $TOMCAT_PID -o pid,vsz,rss,%mem,command 2>/dev/null | head -2
else
    echo -e "${RED}✗ Tomcat is not running${NC}"
    echo "Start with: /opt/homebrew/opt/tomcat@9/libexec/bin/startup.sh"
fi

echo ""

# Check Application Deployment
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Application Deployment"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

WEBAPPS_DIR="/opt/homebrew/opt/tomcat@9/libexec/webapps/assignment-portal"
if [ -d "$WEBAPPS_DIR" ]; then
    echo -e "${GREEN}✓ Application deployed${NC}"
    echo "Location: $WEBAPPS_DIR"
    
    # Count deployed files
    CLASS_COUNT=$(find "$WEBAPPS_DIR/WEB-INF/classes" -name "*.class" 2>/dev/null | wc -l | tr -d ' ')
    echo "Compiled classes: $CLASS_COUNT"
    
    # Check uploads directory
    UPLOAD_DIR="$WEBAPPS_DIR/uploads"
    if [ -d "$UPLOAD_DIR" ]; then
        UPLOAD_COUNT=$(find "$UPLOAD_DIR" -type f 2>/dev/null | wc -l | tr -d ' ')
        echo "Uploaded files: $UPLOAD_COUNT"
    fi
else
    echo -e "${RED}✗ Application not deployed${NC}"
fi

echo ""

# Access URLs
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔗 Access URLs"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${BLUE}Application:${NC}"
echo "  http://localhost:8080/assignment-portal/"
echo ""
echo -e "${BLUE}Tomcat Manager:${NC}"
echo "  http://localhost:8080/manager/html"
echo ""
echo -e "${BLUE}Server Status:${NC}"
echo "  http://localhost:8080/manager/status"

echo ""

# Log Files
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Log Files"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Catalina log:    /opt/homebrew/opt/tomcat@9/libexec/logs/catalina.out"
echo "Localhost log:   /opt/homebrew/opt/tomcat@9/libexec/logs/localhost.$(date +%Y-%m-%d).log"
echo "Database:        Neon PostgreSQL (Cloud)"

echo ""

# Quick Actions
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚡ Quick Actions"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "View live logs:     tail -f /opt/homebrew/opt/tomcat@9/libexec/logs/catalina.out"
echo "Access Database:    PGPASSWORD='npg_8Wts4DNhpeRY' psql -h ep-floral-bush-a1ft2sv2-pooler.ap-southeast-1.aws.neon.tech -U neondb_owner -d neondb"
echo "Restart Tomcat:     ./monitor.sh restart-tomcat"
echo "View all users:     ./monitor.sh show-users"
echo "View submissions:   ./monitor.sh show-submissions"

echo ""

# Handle arguments
if [ "$1" == "restart-tomcat" ]; then
    echo "🔄 Restarting Tomcat..."
    /opt/homebrew/opt/tomcat@9/libexec/bin/shutdown.sh
    sleep 2
    /opt/homebrew/opt/tomcat@9/libexec/bin/startup.sh
    echo "✓ Tomcat restarted"
    
elif [ "$1" == "show-users" ]; then
    echo "👥 All Users:"
    PGPASSWORD='npg_8Wts4DNhpeRY' psql -h ep-floral-bush-a1ft2sv2-pooler.ap-southeast-1.aws.neon.tech -U neondb_owner -d neondb -c "
        SELECT user_id, username, full_name, role, 
               CASE WHEN is_active THEN 'Active' ELSE 'Inactive' END as status,
               TO_CHAR(created_at, 'YYYY-MM-DD HH24:MI') as created
        FROM users
        ORDER BY role, username;
    "
    
elif [ "$1" == "show-submissions" ]; then
    echo "📝 Recent Submissions:"
    PGPASSWORD='npg_8Wts4DNhpeRY' psql -h ep-floral-bush-a1ft2sv2-pooler.ap-southeast-1.aws.neon.tech -U neondb_owner -d neondb -c "
        SELECT 
            s.submission_id,
            u.full_name as student,
            a.title as assignment,
            s.original_filename,
            s.status,
            TO_CHAR(s.submission_date, 'YYYY-MM-DD HH24:MI') as submitted
        FROM submissions s
        JOIN users u ON s.student_id = u.user_id
        JOIN assignments a ON s.assignment_id = a.assignment_id
        ORDER BY s.submission_date DESC
        LIMIT 10;
    "
    
elif [ "$1" == "live-logs" ]; then
    echo "📊 Watching Tomcat logs (Press Ctrl+C to exit)..."
    tail -f /opt/homebrew/opt/tomcat@9/libexec/logs/catalina.out
    
elif [ "$1" == "open" ]; then
    echo "🌐 Opening application in browser..."
    open http://localhost:8080/assignment-portal/
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Run './monitor.sh help' for more commands"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
