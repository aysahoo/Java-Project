<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.assignmentportal.model.User" %>
<%@ page import="com.assignmentportal.model.Submission" %>
<%@ page import="com.assignmentportal.model.Assignment" %>
<%@ page import="com.assignmentportal.model.Course" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"TEACHER".equals(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    List<Submission> submissions = (List<Submission>) request.getAttribute("submissions");
    List<Assignment> assignments = (List<Assignment>) request.getAttribute("assignments");
    List<Course> courses = (List<Course>) request.getAttribute("courses");
    
    int submissionCount = (submissions != null) ? submissions.size() : 0;
    int assignmentCount = (assignments != null) ? assignments.size() : 0;
    int courseCount = (courses != null) ? courses.size() : 0;
    
    int pendingCount = 0;
    if (submissions != null) {
        for (Submission sub : submissions) {
            if ("SUBMITTED".equals(sub.getStatus()) || "LATE".equals(sub.getStatus())) {
                pendingCount++;
            }
        }
    }
    
    SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy 'at' hh:mm a");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Teacher Dashboard - Assignment Portal</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #11998e;
            min-height: 100vh;
            padding: 20px;
        }
        .container {
            max-width: 1200px;
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
            color: #11998e;
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
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
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
            color: #11998e;
            margin-bottom: 15px;
            font-size: 20px;
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
            color: #11998e;
            margin-bottom: 20px;
            font-size: 24px;
        }
        .course-list, .assignment-list {
            list-style: none;
        }
        .list-item {
            padding: 15px;
            border-left: 4px solid #11998e;
            background: #f8f9fa;
            margin-bottom: 15px;
            border-radius: 5px;
        }
        .item-title {
            font-weight: 600;
            color: #2c3e50;
            font-size: 18px;
            margin-bottom: 5px;
        }
        .item-meta {
            color: #7f8c8d;
            font-size: 14px;
            margin-bottom: 5px;
        }
        .action-btn {
            background: #3498db;
            color: white;
            padding: 8px 16px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            font-size: 14px;
            margin-top: 10px;
            margin-right: 10px;
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
        .badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            margin-left: 10px;
        }
        .badge-active {
            background: #27ae60;
            color: white;
        }
        .badge-pending {
            background: #f39c12;
            color: white;
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
            margin: 3% auto;
            padding: 30px;
            border-radius: 10px;
            width: 90%;
            max-width: 700px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
        }
        .modal-header {
            margin-bottom: 20px;
            border-bottom: 2px solid #11998e;
            padding-bottom: 15px;
        }
        .modal-header h2 {
            color: #11998e;
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
            border-color: #11998e;
        }
        .btn-primary {
            background: #11998e;
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
        }
        .btn-primary:hover {
            background: #0e7d72;
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
            <h1>Assignment Portal - Teacher Dashboard</h1>
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
                <h2>My Courses</h2>
                <div class="stat"><%= courseCount %></div>
                <p>Active courses</p>
            </div>
            <div class="card">
                <h2>Assignments</h2>
                <div class="stat"><%= assignmentCount %></div>
                <p>Total assignments</p>
            </div>
            <div class="card">
                <h2>Students</h2>
                <div class="stat">1</div>
                <p>Enrolled students</p>
            </div>
            <div class="card">
                <h2>⏳ Pending Grading</h2>
                <div class="stat"><%= pendingCount %></div>
                <p>Submissions to grade</p>
            </div>
        </div>

        <% if (submissions != null && !submissions.isEmpty()) { %>
        <div class="section">
            <h2>📥 Recent Submissions (<%= submissions.size() %>)</h2>
            <ul class="assignment-list">
                <% for (Submission sub : submissions) { %>
                <li class="list-item">
                    <div class="item-title">
                        <%= sub.getAssignmentTitle() != null ? sub.getAssignmentTitle() : "Assignment #" + sub.getAssignmentId() %>
                        <% if ("GRADED".equals(sub.getStatus())) { %>
                            <span class="badge badge-active">Graded</span>
                        <% } else if ("LATE".equals(sub.getStatus())) { %>
                            <span class="badge badge-pending">Late</span>
                        <% } else { %>
                            <span class="badge badge-pending">Pending</span>
                        <% } %>
                    </div>
                    <div class="item-meta">Student: <%= sub.getStudentName() != null ? sub.getStudentName() : "Student #" + sub.getStudentId() %></div>
                    <div class="item-meta">Submitted: <%= sub.getSubmissionDate() %></div>
                    <div class="item-meta">File: <%= sub.getOriginalFilename() %> (<%= sub.getFileSizeKb() %> KB)</div>
                    <% if ("GRADED".equals(sub.getStatus())) { %>
                        <div class="item-meta">Marks: <%= sub.getMarksObtained() %> / <%= sub.getMaxMarks() %></div>
                    <% } %>
                    <% if (!"GRADED".equals(sub.getStatus())) { %>
                        <button onclick="openGradeModal(<%= sub.getSubmissionId() %>, '<%= sub.getAssignmentTitle() %>', '<%= sub.getStudentName() %>', <%= sub.getMaxMarks() %>)" class="action-btn">Grade Now</button>
                    <% } else { %>
                        <button onclick="alert('Already graded: <%= sub.getMarksObtained() %>/<%= sub.getMaxMarks() %>')" class="action-btn">View Grade</button>
                    <% } %>
                </li>
                <% } %>
            </ul>
        </div>
        <% } else { %>
        <div class="section">
            <h2>📥 Submissions</h2>
            <p style="text-align:center; padding:40px; color:#7f8c8d;">No submissions yet. Students haven't submitted any assignments.</p>
        </div>
        <% } %>

        <div class="section">
            <h2>📚 My Courses</h2>
            <% if (courses != null && !courses.isEmpty()) { %>
            <ul class="course-list">
                <% for (Course course : courses) { 
                    int courseAssignmentCount = 0;
                    if (assignments != null) {
                        for (Assignment a : assignments) {
                            if (a.getCourseId() == course.getCourseId()) {
                                courseAssignmentCount++;
                            }
                        }
                    }
                %>
                <li class="list-item">
                    <div class="item-title">
                        <%= course.getCourseCode() %> - <%= course.getCourseName() %>
                        <span class="badge badge-active">Active</span>
                    </div>
                    <div class="item-meta"><%= courseAssignmentCount %> assignment<%= courseAssignmentCount != 1 ? "s" : "" %> created</div>
                    <div class="item-meta"><%= course.getDescription() != null ? course.getDescription() : "No description" %></div>
                    <button class="action-btn" onclick="viewCourse('<%= course.getCourseCode() %>')">View Course</button>
                    <button class="action-btn create" onclick="createAssignment('<%= course.getCourseCode() %>')">Create Assignment</button>
                </li>
                <% } %>
            </ul>
            <% } else { %>
            <p style="text-align:center; padding:40px; color:#7f8c8d;">No courses assigned to you yet.</p>
            <% } %>
        </div>

        <div class="section">
            <h2>Recent Assignments</h2>
            <% if (assignments != null && !assignments.isEmpty()) { %>
            <ul class="assignment-list">
                <% for (Assignment assignment : assignments) {
                    int submCount = 0;
                    if (submissions != null) {
                        for (Submission s : submissions) {
                            if (s.getAssignmentId() == assignment.getAssignmentId()) {
                                submCount++;
                            }
                        }
                    }
                %>
                <li class="list-item">
                    <div class="item-title"><%= assignment.getTitle() %></div>
                    <div class="item-meta">Course: <%= assignment.getCourseCode() %> - <%= assignment.getCourseName() %></div>
                    <div class="item-meta">📅 Due: <%= sdf.format(assignment.getDueDate()) %></div>
                    <div class="item-meta">📊 Max Marks: <%= assignment.getMaxMarks() %> | 📥 Submissions: <%= submCount %></div>
                    <button class="action-btn" onclick="viewSubmissions(<%= assignment.getAssignmentId() %>)">View Submissions</button>
                    <button class="action-btn" onclick="editAssignment(<%= assignment.getAssignmentId() %>, '<%= assignment.getCourseCode() %>')">Edit Assignment</button>
                </li>
                <% } %>
            </ul>
            <% } else { %>
            <p style="text-align:center; padding:40px; color:#7f8c8d;">No assignments created yet. Create an assignment to get started!</p>
            <% } %>
        </div>

        <!-- Grade Submission Modal -->
        <div id="gradeModal" class="modal" style="display:none; position:fixed; z-index:1000; left:0; top:0; width:100%; height:100%; background:rgba(0,0,0,0.5);">
            <div style="background:white; margin:5% auto; border-radius:10px; width:90%; max-width:600px; box-shadow:0 4px 20px rgba(0,0,0,0.3);">
                <div style="padding:20px 30px; background:#11998e; color:white; border-radius:10px 10px 0 0; display:flex; justify-content:space-between; align-items:center;">
                    <h2 style="margin:0; color:white;">Grade Submission</h2>
                    <span onclick="closeGradeModal()" style="color:white; font-size:32px; font-weight:bold; cursor:pointer; line-height:20px;">&times;</span>
                </div>
                <div style="padding:30px;">
                    <h3 id="gradeTitle" style="color:#11998e; margin-bottom:20px;"></h3>
                    <form action="<%= request.getContextPath() %>/teacher/grade" method="post">
                        <input type="hidden" id="submissionId" name="submissionId" value="">
                        
                        <div style="margin-bottom:20px;">
                            <label style="display:block; margin-bottom:8px; color:#333; font-weight:600;">Marks Obtained:</label>
                            <input type="number" id="marks" name="marks" min="0" max="100" required style="width:100%; padding:10px; border:2px solid #ddd; border-radius:5px;">
                            <p id="maxMarksText" style="font-size:12px; color:#7f8c8d; margin-top:5px;"></p>
                        </div>
                        
                        <div style="margin-bottom:20px;">
                            <label style="display:block; margin-bottom:8px; color:#333; font-weight:600;">Feedback:</label>
                            <textarea name="feedback" rows="4" style="width:100%; padding:10px; border:2px solid #ddd; border-radius:5px; font-family:inherit; resize:vertical;" placeholder="Enter feedback for the student..."></textarea>
                        </div>
                        
                        <div style="display:flex; justify-content:flex-end; gap:10px; margin-top:20px;">
                            <button type="button" onclick="closeGradeModal()" style="padding:10px 20px; background:#95a5a6; color:white; border:none; border-radius:5px; cursor:pointer; font-size:14px;">Cancel</button>
                            <button type="submit" style="padding:10px 20px; background:#27ae60; color:white; border:none; border-radius:5px; cursor:pointer; font-size:14px;">Submit Grade</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <!-- Create Assignment Modal -->
        <div id="assignmentModal" class="modal">
            <div class="modal-content">
                <div class="modal-header">
                    <span class="close" onclick="closeAssignmentModal()">&times;</span>
                    <h2 id="assignmentModalTitle">Create Assignment</h2>
                </div>
                <form id="assignmentForm" action="<%= request.getContextPath() %>/teacher/create-assignment" method="post">
                    <input type="hidden" id="assignmentId" name="assignmentId">
                    <input type="hidden" id="assignmentCourse" name="courseCode">
                    
                    <div class="form-group">
                        <label for="assignmentTitle">Assignment Title *</label>
                        <input type="text" id="assignmentTitle" name="title" required placeholder="e.g., Assignment 1: Variables and Data Types">
                    </div>
                    
                    <div class="form-group">
                        <label for="assignmentDescription">Description *</label>
                        <textarea id="assignmentDescription" name="description" rows="5" required placeholder="Enter assignment description, requirements, and instructions..."></textarea>
                    </div>
                    
                    <div class="form-group">
                        <label for="dueDate">Due Date *</label>
                        <input type="datetime-local" id="dueDate" name="dueDate" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="maxMarks">Maximum Marks *</label>
                        <input type="number" id="maxMarks" name="maxMarks" min="1" max="1000" value="100" required>
                    </div>
                    
                    <div>
                        <button type="submit" class="btn-primary">Create Assignment</button>
                        <button type="button" class="btn-secondary" onclick="closeAssignmentModal()">Cancel</button>
                    </div>
                </form>
            </div>
        </div>

        <script>
            // Grade Modal Functions
            function openGradeModal(submissionId, assignmentTitle, studentName, maxMarks) {
                document.getElementById('submissionId').value = submissionId;
                document.getElementById('gradeTitle').textContent = assignmentTitle + ' - ' + studentName;
                document.getElementById('marks').max = maxMarks;
                document.getElementById('maxMarksText').textContent = 'Maximum marks: ' + maxMarks;
                document.getElementById('gradeModal').style.display = 'block';
            }
            
            function closeGradeModal() {
                document.getElementById('gradeModal').style.display = 'none';
            }
            
            // Assignment Modal Functions
            function createAssignment(courseCode) {
                document.getElementById('assignmentModalTitle').textContent = 'Create Assignment for ' + courseCode;
                document.getElementById('assignmentForm').reset();
                document.getElementById('assignmentId').value = '';
                document.getElementById('assignmentCourse').value = courseCode;
                document.getElementById('assignmentModal').style.display = 'block';
            }
            
            function editAssignment(assignmentId, courseCode) {
                document.getElementById('assignmentModalTitle').textContent = 'Edit Assignment';
                document.getElementById('assignmentId').value = assignmentId;
                document.getElementById('assignmentCourse').value = courseCode;
                // TODO: Load existing assignment data
                document.getElementById('assignmentModal').style.display = 'block';
            }
            
            function closeAssignmentModal() {
                document.getElementById('assignmentModal').style.display = 'none';
            }
            
            function viewCourse(courseCode) {
                // TODO: Implement course details view
                alert('Course details view will be implemented.\n\nCourse Code: ' + courseCode);
            }
            
            function viewSubmissions(assignmentId) {
                // TODO: Implement submissions view
                alert('Submissions view will be implemented.\n\nAssignment ID: ' + assignmentId);
            }
            
            // Close modals when clicking outside
            window.onclick = function(event) {
                const gradeModal = document.getElementById('gradeModal');
                const assignmentModal = document.getElementById('assignmentModal');
                
                if (event.target == gradeModal) {
                    closeGradeModal();
                }
                if (event.target == assignmentModal) {
                    closeAssignmentModal();
                }
            }
        </script>
    </div>
</body>
</html>
