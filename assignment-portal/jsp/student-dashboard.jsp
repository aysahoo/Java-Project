<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.assignmentportal.model.User" %>
<%@ page import="com.assignmentportal.model.Submission" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"STUDENT".equals(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    List<Submission> submissions = (List<Submission>) request.getAttribute("submissions");
    if (submissions == null) {
        submissions = new ArrayList<>();
    }
    
    // Count submitted assignments
    int submittedCount = submissions.size();
    
    // Calculate average grade
    double totalMarks = 0;
    int gradedCount = 0;
    for (Submission sub : submissions) {
        if ("GRADED".equals(sub.getStatus()) && sub.getMarksObtained() != null) {
            totalMarks += sub.getMarksObtained();
            gradedCount++;
        }
    }
    double avgGrade = gradedCount > 0 ? totalMarks / gradedCount : 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Dashboard - Assignment Portal</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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
            color: #667eea;
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
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
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
            color: #667eea;
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
            color: #667eea;
            margin-bottom: 20px;
            font-size: 24px;
        }
        .assignment-list {
            list-style: none;
        }
        .assignment-item {
            padding: 15px;
            border-left: 4px solid #667eea;
            background: #f8f9fa;
            margin-bottom: 15px;
            border-radius: 5px;
        }
        .assignment-title {
            font-weight: 600;
            color: #2c3e50;
            font-size: 18px;
            margin-bottom: 5px;
        }
        .assignment-meta {
            color: #7f8c8d;
            font-size: 14px;
            margin-bottom: 10px;
        }
        .submit-btn {
            background: #27ae60;
            color: white;
            padding: 8px 16px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            font-size: 14px;
            margin-top: 10px;
        }
        .submit-btn:hover {
            background: #229954;
        }
        .empty-state {
            text-align: center;
            padding: 40px;
            color: #7f8c8d;
        }
        .badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            margin-left: 10px;
        }
        .badge-pending {
            background: #f39c12;
            color: white;
        }
        .badge-submitted {
            background: #27ae60;
            color: white;
        }
        
        /* Modal Styles */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
            overflow: auto;
        }
        .modal-content {
            background-color: white;
            margin: 5% auto;
            border-radius: 10px;
            width: 90%;
            max-width: 600px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.3);
        }
        .modal-header {
            padding: 20px 30px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 10px 10px 0 0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .modal-header h2 {
            margin: 0;
            color: white;
        }
        .close {
            color: white;
            font-size: 32px;
            font-weight: bold;
            cursor: pointer;
            line-height: 20px;
        }
        .close:hover {
            opacity: 0.7;
        }
        .modal-body {
            padding: 30px;
        }
        .modal-body h3 {
            color: #667eea;
            margin-bottom: 20px;
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #333;
            font-weight: 600;
        }
        .form-group input[type="file"] {
            width: 100%;
            padding: 10px;
            border: 2px dashed #667eea;
            border-radius: 5px;
            background: #f8f9ff;
            cursor: pointer;
        }
        .form-group textarea {
            width: 100%;
            padding: 10px;
            border: 2px solid #ddd;
            border-radius: 5px;
            font-family: inherit;
            resize: vertical;
        }
        .help-text {
            font-size: 12px;
            color: #7f8c8d;
            margin-top: 5px;
        }
        .modal-footer {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin-top: 20px;
        }
        .btn-cancel {
            padding: 10px 20px;
            background: #95a5a6;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 14px;
        }
        .btn-cancel:hover {
            background: #7f8c8d;
        }
        .btn-submit {
            padding: 10px 20px;
            background: #27ae60;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 14px;
        }
        .btn-submit:hover {
            background: #229954;
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
            <h1>🎓 Assignment Portal - Student Dashboard</h1>
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
                <h2>📚 Enrolled Courses</h2>
                <div class="stat">2</div>
                <p>Active courses</p>
            </div>
            <div class="card">
                <h2>📝 Assignments</h2>
                <div class="stat">3</div>
                <p>Total assignments</p>
            </div>
            <div class="card">
                <h2>✅ Submissions</h2>
                <div class="stat"><%= submittedCount %></div>
                <p>Submitted assignments</p>
            </div>
            <div class="card">
                <h2>📊 Average Grade</h2>
                <div class="stat"><%= gradedCount > 0 ? String.format("%.1f", avgGrade) : "--" %></div>
                <p><%= gradedCount > 0 ? gradedCount + " graded" : "Not graded yet" %></p>
            </div>
        </div>

        <div class="section">
            <h2>📋 My Courses</h2>
            <ul class="assignment-list">
                <li class="assignment-item">
                    <div class="assignment-title">CS101 - Introduction to Programming</div>
                    <div class="assignment-meta">Instructor: Dr. John Smith</div>
                    <div class="assignment-meta">2 assignments available</div>
                </li>
                <li class="assignment-item">
                    <div class="assignment-title">CS201 - Data Structures and Algorithms</div>
                    <div class="assignment-meta">Instructor: Dr. John Smith</div>
                    <div class="assignment-meta">1 assignment available</div>
                </li>
            </ul>
        </div>

        <% if (!submissions.isEmpty()) { %>
        <div class="section">
            <h2>📥 My Submissions (<%= submissions.size() %>)</h2>
            <ul class="assignment-list">
                <% for (Submission sub : submissions) { %>
                <li class="assignment-item">
                    <div class="assignment-title">
                        <%= sub.getAssignmentTitle() != null ? sub.getAssignmentTitle() : "Assignment #" + sub.getAssignmentId() %>
                        <% if ("GRADED".equals(sub.getStatus())) { %>
                            <span class="badge badge-submitted">Graded</span>
                        <% } else if ("LATE".equals(sub.getStatus())) { %>
                            <span class="badge badge-pending">Late Submission</span>
                        <% } else { %>
                            <span class="badge badge-pending">Submitted</span>
                        <% } %>
                    </div>
                    <% if (sub.getCourseName() != null) { %>
                        <div class="assignment-meta">Course: <%= sub.getCourseName() %></div>
                    <% } %>
                    <div class="assignment-meta">📅 Submitted: <%= sub.getSubmissionDate() %></div>
                    <div class="assignment-meta">📎 File: <%= sub.getOriginalFilename() %> (<%= sub.getFileSizeKb() %> KB)</div>
                    
                    <% if ("GRADED".equals(sub.getStatus())) { %>
                        <div class="assignment-meta" style="margin-top:10px; padding:10px; background:#e8f5e9; border-left:4px solid #4caf50; border-radius:5px;">
                            <strong style="color:#2e7d32;">📊 Grade: <%= sub.getMarksObtained() %> / <%= sub.getMaxMarks() %></strong>
                            <% 
                                double percentage = (sub.getMarksObtained() * 100.0) / sub.getMaxMarks();
                                String grade = percentage >= 90 ? "A+" : percentage >= 80 ? "A" : percentage >= 70 ? "B" : percentage >= 60 ? "C" : percentage >= 50 ? "D" : "F";
                            %>
                            <span style="margin-left:10px; color:#2e7d32;">(<%=String.format("%.1f", percentage)%>% - Grade: <%= grade %>)</span>
                            <% if (sub.getFeedback() != null && !sub.getFeedback().isEmpty()) { %>
                                <div style="margin-top:8px; color:#555;">
                                    <strong>💬 Feedback:</strong> <%= sub.getFeedback() %>
                                </div>
                            <% } %>
                            <% if (sub.getGradedAt() != null) { %>
                                <div style="margin-top:5px; font-size:12px; color:#666;">
                                    Graded on: <%= sub.getGradedAt() %>
                                </div>
                            <% } %>
                        </div>
                    <% } else { %>
                        <div class="assignment-meta" style="margin-top:10px; padding:10px; background:#fff3e0; border-left:4px solid #ff9800; border-radius:5px;">
                            <strong style="color:#e65100;">⏳ Pending Grading</strong>
                            <p style="margin:5px 0 0 0; font-size:13px; color:#666;">Your assignment is awaiting teacher's review</p>
                        </div>
                    <% } %>
                </li>
                <% } %>
            </ul>
        </div>
        <% } %>
        
        <div class="section">
            <h2>📝 Pending Assignments</h2>
            <ul class="assignment-list">
                <li class="assignment-item">
                    <div class="assignment-title">
                        Assignment 1: Hello World
                        <span class="badge badge-pending">Pending</span>
                    </div>
                    <div class="assignment-meta">Course: CS101 - Introduction to Programming</div>
                    <div class="assignment-meta">📅 Due: November 30, 2025 at 11:59 PM</div>
                    <div class="assignment-meta">📊 Max Marks: 100</div>
                    <button onclick="openSubmitModal(1, 'Assignment 1: Hello World')" class="submit-btn">Submit Assignment</button>
                </li>
                <li class="assignment-item">
                    <div class="assignment-title">
                        Assignment 2: Calculator
                        <span class="badge badge-pending">Pending</span>
                    </div>
                    <div class="assignment-meta">Course: CS101 - Introduction to Programming</div>
                    <div class="assignment-meta">📅 Due: December 15, 2025 at 11:59 PM</div>
                    <div class="assignment-meta">📊 Max Marks: 100</div>
                    <button onclick="openSubmitModal(2, 'Assignment 2: Calculator')" class="submit-btn">Submit Assignment</button>
                </li>
                <li class="assignment-item">
                    <div class="assignment-title">
                        Assignment 1: Linked Lists
                        <span class="badge badge-pending">Pending</span>
                    </div>
                    <div class="assignment-meta">Course: CS201 - Data Structures and Algorithms</div>
                    <div class="assignment-meta">📅 Due: December 1, 2025 at 11:59 PM</div>
                    <div class="assignment-meta">📊 Max Marks: 100</div>
                    <button onclick="openSubmitModal(3, 'Assignment 1: Linked Lists')" class="submit-btn">Submit Assignment</button>
                </li>
            </ul>
        </div>
        
        <!-- Submit Assignment Modal -->
        <div id="submitModal" class="modal">
            <div class="modal-content">
                <div class="modal-header">
                    <h2>📤 Submit Assignment</h2>
                    <span class="close" onclick="closeSubmitModal()">&times;</span>
                </div>
                <div class="modal-body">
                    <h3 id="assignmentTitle"></h3>
                    <form id="submitForm" action="<%= request.getContextPath() %>/student/submit" method="post" enctype="multipart/form-data">
                        <input type="hidden" id="assignmentId" name="assignmentId" value="">
                        
                        <div class="form-group">
                            <label for="file">📎 Select File to Upload:</label>
                            <input type="file" id="file" name="file" required accept=".pdf,.doc,.docx,.txt,.java,.zip">
                            <p class="help-text">Accepted formats: PDF, DOC, DOCX, TXT, JAVA, ZIP (Max 10MB)</p>
                        </div>
                        
                        <div class="form-group">
                            <label for="comments">💬 Comments (Optional):</label>
                            <textarea id="comments" name="comments" rows="4" placeholder="Add any comments about your submission..."></textarea>
                        </div>
                        
                        <div class="modal-footer">
                            <button type="button" class="btn-cancel" onclick="closeSubmitModal()">Cancel</button>
                            <button type="submit" class="btn-submit">Submit Assignment</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
    
    <script>
        function openSubmitModal(assignmentId, assignmentTitle) {
            document.getElementById('assignmentId').value = assignmentId;
            document.getElementById('assignmentTitle').textContent = assignmentTitle;
            document.getElementById('submitModal').style.display = 'block';
        }
        
        function closeSubmitModal() {
            document.getElementById('submitModal').style.display = 'none';
            document.getElementById('submitForm').reset();
        }
        
        // Close modal when clicking outside of it
        window.onclick = function(event) {
            const modal = document.getElementById('submitModal');
            if (event.target == modal) {
                closeSubmitModal();
            }
        }
    </script>
</body>
</html>
