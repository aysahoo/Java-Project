<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.assignmentportal.model.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"ADMIN".equals(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - Assignment Portal</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f093fb;
            min-height: 100vh;
            padding: 20px;
        }
        .container {
            max-width: 1400px;
            margin: 0 auto;
        }
        .header {
            background: white;
            padding: 20px 30px;
            border-radius: 10px;
            margin-bottom: 30px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .header h1 {
            color: #f5576c;
            font-size: 28px;
        }
        .user-info {
            display: flex;
            align-items: center;
            gap: 20px;
        }
        .user-name {
            font-weight: 600;
            color: #333;
        }
        .logout-btn {
            background: #e74c3c;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            font-size: 14px;
        }
        .logout-btn:hover {
            background: #c0392b;
        }
        .dashboard-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .card {
            background: white;
            padding: 25px;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        .card h2 {
            color: #f5576c;
            margin-bottom: 15px;
            font-size: 18px;
        }
        .stat {
            font-size: 36px;
            font-weight: bold;
            color: #2c3e50;
            margin: 10px 0;
        }
        .section {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        .section h2 {
            color: #f5576c;
            margin-bottom: 20px;
            font-size: 24px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th {
            background: #f8f9fa;
            padding: 12px;
            text-align: left;
            font-weight: 600;
            color: #2c3e50;
            border-bottom: 2px solid #dee2e6;
        }
        td {
            padding: 12px;
            border-bottom: 1px solid #dee2e6;
        }
        tr:hover {
            background: #f8f9fa;
        }
        .badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }
        .badge-admin {
            background: #e74c3c;
            color: white;
        }
        .badge-teacher {
            background: #3498db;
            color: white;
        }
        .badge-student {
            background: #27ae60;
            color: white;
        }
        .badge-active {
            background: #27ae60;
            color: white;
        }
        .action-btn {
            background: #3498db;
            color: white;
            padding: 6px 12px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            font-size: 12px;
            margin-right: 5px;
        }
        .action-btn:hover {
            background: #2980b9;
        }
        .action-btn.create {
            background: #27ae60;
        }
        .action-btn.create:hover {
            background: #229954;
        }
        .action-btn.delete {
            background: #e74c3c;
        }
        .action-btn.delete:hover {
            background: #c0392b;
        }
        .alert {
            padding: 15px 20px;
            border-radius: 5px;
            margin-bottom: 20px;
            font-weight: 500;
        }
        .alert-success {
            background: #d4edda;
            color: #155724;
            border-left: 4px solid #28a745;
        }
        .alert-error {
            background: #f8d7da;
            color: #721c24;
            border-left: 4px solid #dc3545;
        }
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            overflow: auto;
            background-color: rgba(0,0,0,0.5);
        }
        .modal-content {
            background-color: white;
            margin: 5% auto;
            padding: 30px;
            border-radius: 10px;
            width: 90%;
            max-width: 600px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
        }
        .modal-header {
            margin-bottom: 20px;
            border-bottom: 2px solid #f5576c;
            padding-bottom: 15px;
        }
        .modal-header h2 {
            color: #f5576c;
            margin: 0;
        }
        .close {
            color: #aaa;
            float: right;
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
        }
        .close:hover,
        .close:focus {
            color: #000;
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #2c3e50;
            font-weight: 600;
        }
        .form-group input,
        .form-group select,
        .form-group textarea {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
        }
        .form-group input:focus,
        .form-group select:focus,
        .form-group textarea:focus {
            outline: none;
            border-color: #f5576c;
        }
        .btn-primary {
            background: #f5576c;
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
        }
        .btn-primary:hover {
            background: #e74c3c;
        }
        .btn-secondary {
            background: #95a5a6;
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
            margin-left: 10px;
        }
        .btn-secondary:hover {
            background: #7f8c8d;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Assignment Portal - Admin Dashboard</h1>
            <div class="user-info">
                <span class="user-name"><%= user.getFullName() %></span>
                <a href="<%= request.getContextPath() %>/logout" class="logout-btn">Logout</a>
            </div>
        </div>

        <%
            String successMsg = (String) session.getAttribute("success");
            String errorMsg = (String) session.getAttribute("error");
            if (successMsg != null) {
                session.removeAttribute("success");
        %>
            <div class="alert alert-success"><%= successMsg %></div>
        <%
            }
            if (errorMsg != null) {
                session.removeAttribute("error");
        %>
            <div class="alert alert-error"><%= errorMsg %></div>
        <%
            }
        %>

        <div class="dashboard-grid">
            <div class="card">
                <h2>Total Users</h2>
                <div class="stat">3</div>
                <p>Registered users</p>
            </div>
            <div class="card">
                <h2>Students</h2>
                <div class="stat">1</div>
                <p>Active students</p>
            </div>
            <div class="card">
                <h2>Teachers</h2>
                <div class="stat">1</div>
                <p>Active teachers</p>
            </div>
            <div class="card">
                <h2>Courses</h2>
                <div class="stat">2</div>
                <p>Active courses</p>
            </div>
            <div class="card">
                <h2>Assignments</h2>
                <div class="stat">3</div>
                <p>Total assignments</p>
            </div>
            <div class="card">
                <h2>Submissions</h2>
                <div class="stat">0</div>
                <p>Total submissions</p>
            </div>
        </div>

        <div class="section">
            <h2>👥 All Users</h2>
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Username</th>
                        <th>Full Name</th>
                        <th>Email</th>
                        <th>Role</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>1</td>
                        <td>admin</td>
                        <td>System Administrator</td>
                        <td>admin@assignment-portal.com</td>
                        <td><span class="badge badge-admin">ADMIN</span></td>
                        <td><span class="badge badge-active">Active</span></td>
                        <td>
                            <button class="action-btn" onclick="editUser(1, 'admin', 'System Administrator', 'admin@assignment-portal.com', 'ADMIN')">Edit</button>
                        </td>
                    </tr>
                    <tr>
                        <td>2</td>
                        <td>john.smith</td>
                        <td>Dr. John Smith</td>
                        <td>john.smith@university.edu</td>
                        <td><span class="badge badge-teacher">TEACHER</span></td>
                        <td><span class="badge badge-active">Active</span></td>
                        <td>
                            <button class="action-btn" onclick="editUser(2, 'john.smith', 'Dr. John Smith', 'john.smith@university.edu', 'TEACHER')">Edit</button>
                            <button class="action-btn delete" onclick="disableUser(2, 'john.smith')">Disable</button>
                        </td>
                    </tr>
                    <tr>
                        <td>3</td>
                        <td>alice.brown</td>
                        <td>Alice Brown</td>
                        <td>alice.brown@student.edu</td>
                        <td><span class="badge badge-student">STUDENT</span></td>
                        <td><span class="badge badge-active">Active</span></td>
                        <td>
                            <button class="action-btn" onclick="editUser(3, 'alice.brown', 'Alice Brown', 'alice.brown@student.edu', 'STUDENT')">Edit</button>
                            <button class="action-btn delete" onclick="disableUser(3, 'alice.brown')">Disable</button>
                        </td>
                    </tr>
                </tbody>
            </table>
            <br>
            <button class="action-btn create" onclick="createNewUser()">Create New User</button>
        </div>

        <div class="section">
            <h2>📚 All Courses</h2>
            <table>
                <thead>
                    <tr>
                        <th>Code</th>
                        <th>Name</th>
                        <th>Teacher</th>
                        <th>Assignments</th>
                        <th>Enrollments</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>CS101</td>
                        <td>Introduction to Programming</td>
                        <td>Dr. John Smith</td>
                        <td>2</td>
                        <td>1</td>
                        <td><span class="badge badge-active">Active</span></td>
                        <td>
                            <button class="action-btn" onclick="viewCourse('CS101')">View</button>
                            <button class="action-btn" onclick="editCourse('CS101', 'Introduction to Programming', 'Dr. John Smith')">Edit</button>
                        </td>
                    </tr>
                    <tr>
                        <td>CS201</td>
                        <td>Data Structures and Algorithms</td>
                        <td>Dr. John Smith</td>
                        <td>1</td>
                        <td>1</td>
                        <td><span class="badge badge-active">Active</span></td>
                        <td>
                            <button class="action-btn" onclick="viewCourse('CS201')">View</button>
                            <button class="action-btn" onclick="editCourse('CS201', 'Data Structures and Algorithms', 'Dr. John Smith')">Edit</button>
                        </td>
                    </tr>
                </tbody>
            </table>
            <br>
            <button class="action-btn create" onclick="createNewCourse()">Create New Course</button>
        </div>

        <div class="section">
            <h2>📊 System Analytics</h2>
            <table>
                <thead>
                    <tr>
                        <th>Metric</th>
                        <th>Value</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>Total Enrollments</td>
                        <td>2</td>
                    </tr>
                    <tr>
                        <td>Total Submissions</td>
                        <td>0</td>
                    </tr>
                    <tr>
                        <td>Graded Submissions</td>
                        <td>0</td>
                    </tr>
                    <tr>
                        <td>Average System Usage</td>
                        <td>Low (3 users)</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>

    <!-- User Modal -->
    <div id="userModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <span class="close" onclick="closeUserModal()">&times;</span>
                <h2 id="userModalTitle">Create New User</h2>
            </div>
            <form id="userForm" onsubmit="saveUser(event)">
                <input type="hidden" id="userId" name="userId">
                <div class="form-group">
                    <label for="username">Username *</label>
                    <input type="text" id="username" name="username" required>
                </div>
                <div class="form-group">
                    <label for="fullName">Full Name *</label>
                    <input type="text" id="fullName" name="fullName" required>
                </div>
                <div class="form-group">
                    <label for="email">Email *</label>
                    <input type="email" id="email" name="email" required>
                </div>
                <div class="form-group">
                    <label for="password">Password *</label>
                    <input type="password" id="password" name="password" required>
                </div>
                <div class="form-group">
                    <label for="role">Role *</label>
                    <select id="role" name="role" required>
                        <option value="">Select Role</option>
                        <option value="STUDENT">Student</option>
                        <option value="TEACHER">Teacher</option>
                        <option value="ADMIN">Admin</option>
                    </select>
                </div>
                <div>
                    <button type="submit" class="btn-primary">Save User</button>
                    <button type="button" class="btn-secondary" onclick="closeUserModal()">Cancel</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Course Modal -->
    <div id="courseModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <span class="close" onclick="closeCourseModal()">&times;</span>
                <h2 id="courseModalTitle">Create New Course</h2>
            </div>
            <form id="courseForm" onsubmit="saveCourse(event)">
                <input type="hidden" id="courseId" name="courseId">
                <div class="form-group">
                    <label for="courseCode">Course Code *</label>
                    <input type="text" id="courseCode" name="courseCode" required>
                </div>
                <div class="form-group">
                    <label for="courseName">Course Name *</label>
                    <input type="text" id="courseName" name="courseName" required>
                </div>
                <div class="form-group">
                    <label for="description">Description</label>
                    <textarea id="description" name="description" rows="4"></textarea>
                </div>
                <div class="form-group">
                    <label for="teacherId">Teacher *</label>
                    <select id="teacherId" name="teacherId" required>
                        <option value="">Select Teacher</option>
                        <option value="2">Dr. John Smith</option>
                    </select>
                </div>
                <div>
                    <button type="submit" class="btn-primary">Save Course</button>
                    <button type="button" class="btn-secondary" onclick="closeCourseModal()">Cancel</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        // User Modal Functions
        function createNewUser() {
            document.getElementById('userModalTitle').textContent = 'Create New User';
            document.getElementById('userForm').reset();
            document.getElementById('userId').value = '';
            document.getElementById('userModal').style.display = 'block';
        }

        function editUser(id, username, fullName, email, role) {
            document.getElementById('userModalTitle').textContent = 'Edit User';
            document.getElementById('userId').value = id;
            document.getElementById('username').value = username;
            document.getElementById('fullName').value = fullName;
            document.getElementById('email').value = email;
            document.getElementById('role').value = role;
            document.getElementById('password').required = false;
            document.getElementById('userModal').style.display = 'block';
        }

        function closeUserModal() {
            document.getElementById('userModal').style.display = 'none';
            document.getElementById('password').required = true;
        }

        function saveUser(event) {
            event.preventDefault();
            const formData = new FormData(event.target);
            const userId = formData.get('userId');
            
            // TODO: Implement actual API call to save user
            alert('User save functionality will be implemented with backend API.\n\nData to save:\n' +
                  'Username: ' + formData.get('username') + '\n' +
                  'Full Name: ' + formData.get('fullName') + '\n' +
                  'Email: ' + formData.get('email') + '\n' +
                  'Role: ' + formData.get('role'));
            
            closeUserModal();
            // After successful save, reload page
            // window.location.reload();
        }

        function disableUser(userId, username) {
            if (confirm('Are you sure you want to disable user "' + username + '"?')) {
                // TODO: Implement actual API call to disable user
                alert('User disable functionality will be implemented with backend API.\n\nUser ID: ' + userId);
                
                // After successful disable, reload page
                // window.location.reload();
            }
        }

        // Course Modal Functions
        function createNewCourse() {
            document.getElementById('courseModalTitle').textContent = 'Create New Course';
            document.getElementById('courseForm').reset();
            document.getElementById('courseId').value = '';
            document.getElementById('courseModal').style.display = 'block';
        }

        function editCourse(code, name, teacher) {
            document.getElementById('courseModalTitle').textContent = 'Edit Course';
            document.getElementById('courseId').value = code;
            document.getElementById('courseCode').value = code;
            document.getElementById('courseName').value = name;
            document.getElementById('courseCode').readOnly = true;
            document.getElementById('courseModal').style.display = 'block';
        }

        function closeCourseModal() {
            document.getElementById('courseModal').style.display = 'none';
            document.getElementById('courseCode').readOnly = false;
        }

        function saveCourse(event) {
            event.preventDefault();
            const formData = new FormData(event.target);
            
            // TODO: Implement actual API call to save course
            alert('Course save functionality will be implemented with backend API.\n\nData to save:\n' +
                  'Course Code: ' + formData.get('courseCode') + '\n' +
                  'Course Name: ' + formData.get('courseName') + '\n' +
                  'Description: ' + formData.get('description') + '\n' +
                  'Teacher ID: ' + formData.get('teacherId'));
            
            closeCourseModal();
            // After successful save, reload page
            // window.location.reload();
        }

        function viewCourse(courseCode) {
            // TODO: Implement course details view
            alert('Course details view will be implemented.\n\nCourse Code: ' + courseCode);
            // Could redirect to a course details page
            // window.location.href = '<%= request.getContextPath() %>/admin/course/' + courseCode;
        }

        // Close modals when clicking outside
        window.onclick = function(event) {
            const userModal = document.getElementById('userModal');
            const courseModal = document.getElementById('courseModal');
            if (event.target == userModal) {
                closeUserModal();
            }
            if (event.target == courseModal) {
                closeCourseModal();
            }
        }
    </script>
</body>
</html>
