# 🎯 Quick Test Guide - Assignment Submission

## ✅ All Fixes Applied and Deployed

### 🔧 What Was Fixed:
1. ✅ File upload extensions (added .java and .txt support)
2. ✅ Upload directory auto-creation
3. ✅ Error message display on all dashboards
4. ✅ Proper session-based error handling
5. ✅ File validation (empty files, wrong types)
6. ✅ Redirect URLs fixed
7. ✅ Logging added for debugging
8. ✅ Grading functionality fixed

### 🚀 Application Status:
- **URL:** http://localhost:8080/assignment-portal/
- **Tomcat:** Running ✓
- **Database:** PostgreSQL (Neon) ✓
- **Deployment:** Latest code deployed ✓

### 👥 Test Credentials:

**Student Account:**
- Username: `alice.brown`
- Password: `student123`

**Teacher Account:**
- Username: `john.smith`
- Password: `teacher123`

**Admin Account:**
- Username: `admin`
- Password: `admin123`

## 📝 Test Scenarios:

### Scenario 1: Successful Submission ✅
1. Login as student (`alice.brown` / `student123`)
2. Click "Submit Assignment" on any pending assignment
3. Select a valid file (.pdf, .docx, .txt, .java, .zip)
4. Click "Submit Assignment"
5. **Expected:** Green success message appears: "✓ Assignment submitted successfully!"

### Scenario 2: Invalid File Type ❌
1. Login as student
2. Click "Submit Assignment"
3. Try to select a .exe or .png file
4. **Expected:** File picker should not allow it, or error message if submitted

### Scenario 3: No File Selected ❌
1. Login as student
2. Click "Submit Assignment"
3. Click submit without selecting a file
4. **Expected:** Red error message: "✗ Please select a file to upload"

### Scenario 4: Already Submitted ⚠️
1. Login as student
2. Try to submit the same assignment twice
3. **Expected:** Red error message: "✗ You have already submitted this assignment"

### Scenario 5: Large File ❌
1. Login as student
2. Try to upload a file larger than 10MB
3. **Expected:** Red error message: "✗ File size exceeds maximum allowed size of 10 MB"

### Scenario 6: Teacher Grading ✅
1. Login as teacher (`john.smith` / `teacher123`)
2. View submissions (once a student has submitted)
3. Enter marks and feedback
4. Click "Grade"
5. **Expected:** Green success message: "✓ Submission graded successfully!"

## 🐛 Troubleshooting:

### If submission fails:
1. Check browser console (F12) for JavaScript errors
2. Check Tomcat logs: `tail -f $CATALINA_HOME/logs/catalina.out`
3. Verify database connection in `db.properties`
4. Check uploads directory exists: `ls -la $CATALINA_HOME/webapps/assignment-portal/uploads/`

### Common Issues:

**"Assignment ID is required"**
- The assignment ID wasn't passed correctly
- Check that the modal form is setting the hidden input

**"Database error"**
- Database connection failed
- Verify PostgreSQL credentials in `WEB-INF/classes/db.properties`
- Check network connectivity to Neon database

**"File type not allowed"**
- Trying to upload unsupported file type
- Supported: .pdf, .docx, .doc, .zip, .rar, .txt, .java

**"No file provided"**
- File wasn't selected or form encoding is wrong
- Verify form has `enctype="multipart/form-data"`

## 📊 Check Logs:

```bash
# View Tomcat logs
tail -f $CATALINA_HOME/logs/catalina.out

# Check for submission logs
grep -i "submission" $CATALINA_HOME/logs/catalina.out

# Check for errors
grep -i "error\|exception" $CATALINA_HOME/logs/catalina.out
```

## 🔍 Verify Upload Directory:

```bash
# Check upload directory structure
ls -la $CATALINA_HOME/webapps/assignment-portal/uploads/

# Check assignment submissions
ls -la $CATALINA_HOME/webapps/assignment-portal/uploads/assignments/
```

## 📁 File Locations:

- **Application:** `/opt/homebrew/opt/tomcat@9/libexec/webapps/assignment-portal/`
- **Uploads:** `/opt/homebrew/opt/tomcat@9/libexec/webapps/assignment-portal/uploads/`
- **Database Config:** `/opt/homebrew/opt/tomcat@9/libexec/webapps/assignment-portal/WEB-INF/classes/db.properties`
- **Logs:** `/opt/homebrew/opt/tomcat@9/libexec/logs/`

## ✨ New Features Added:

1. **Better Error Messages** - Clear, user-friendly error messages
2. **File Type Validation** - Prevents uploading wrong file types
3. **Auto Directory Creation** - Upload directory created automatically
4. **Enhanced Logging** - Better debugging capabilities
5. **Visual Alerts** - Color-coded success/error messages
6. **Session-based Messages** - Messages persist across redirects

## 🎓 Testing Checklist:

- [ ] Login works for all roles
- [ ] Student can view pending assignments
- [ ] Student can submit assignments
- [ ] Success message appears after submission
- [ ] Error message appears for invalid files
- [ ] Error message appears for missing files
- [ ] Teacher can view submissions
- [ ] Teacher can grade submissions
- [ ] Grading success message appears
- [ ] File is actually saved in uploads directory
- [ ] Database records submission correctly

---

**Last Updated:** November 17, 2025
**Status:** ✅ Ready for Testing
**Tomcat:** Running on port 8080
