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
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
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
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>⚙️ Assignment Portal - Admin Dashboard</h1>
            <div class="user-info">
                <span class="user-name">👤 <%= user.getFullName() %></span>
                <a href="<%= request.getContextPath() %>/logout" class="logout-btn">Logout</a>
            </div>
        </div>

        <%
            String successMsg = (String) session.getAttribute("success");
            String errorMsg = (String) session.getAttribute("error");
            if (successMsg != null) {
                session.removeAttribute("success");
        %>
            <div class="alert alert-success">✓ <%= successMsg %></div>
        <%
            }
            if (errorMsg != null) {
                session.removeAttribute("error");
        %>
            <div class="alert alert-error">✗ <%= errorMsg %></div>
        <%
            }
        %>

        <div class="dashboard-grid">
            <div class="card">
                <h2>👥 Total Users</h2>
                <div class="stat">3</div>
                <p>Registered users</p>
            </div>
            <div class="card">
                <h2>👨‍🎓 Students</h2>
                <div class="stat">1</div>
                <p>Active students</p>
            </div>
            <div class="card">
                <h2>👨‍🏫 Teachers</h2>
                <div class="stat">1</div>
                <p>Active teachers</p>
            </div>
            <div class="card">
                <h2>📚 Courses</h2>
                <div class="stat">2</div>
                <p>Active courses</p>
            </div>
            <div class="card">
                <h2>📝 Assignments</h2>
                <div class="stat">3</div>
                <p>Total assignments</p>
            </div>
            <div class="card">
                <h2>📥 Submissions</h2>
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
                            <a href="#" class="action-btn">Edit</a>
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
                            <a href="#" class="action-btn">Edit</a>
                            <a href="#" class="action-btn delete">Disable</a>
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
                            <a href="#" class="action-btn">Edit</a>
                            <a href="#" class="action-btn delete">Disable</a>
                        </td>
                    </tr>
                </tbody>
            </table>
            <br>
            <a href="#" class="action-btn create">Create New User</a>
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
                            <a href="#" class="action-btn">View</a>
                            <a href="#" class="action-btn">Edit</a>
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
                            <a href="#" class="action-btn">View</a>
                            <a href="#" class="action-btn">Edit</a>
                        </td>
                    </tr>
                </tbody>
            </table>
            <br>
            <a href="#" class="action-btn create">Create New Course</a>
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
</body>
</html>
