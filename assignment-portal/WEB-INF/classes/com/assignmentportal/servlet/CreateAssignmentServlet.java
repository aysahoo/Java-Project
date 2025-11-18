package com.assignmentportal.servlet;

import com.assignmentportal.dao.AssignmentDAO;
import com.assignmentportal.dao.CourseDAO;
import com.assignmentportal.model.Assignment;
import com.assignmentportal.model.Course;
import com.assignmentportal.model.User;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

public class CreateAssignmentServlet extends HttpServlet {
    
    private AssignmentDAO assignmentDAO;
    private CourseDAO courseDAO;
    
    @Override
    public void init() throws ServletException {
        assignmentDAO = new AssignmentDAO();
        courseDAO = new CourseDAO();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        User user = (User) session.getAttribute("user");
        if (!"TEACHER".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        try {
            // Get form parameters
            String courseCode = request.getParameter("courseCode");
            String title = request.getParameter("title");
            String description = request.getParameter("description");
            String dueDateStr = request.getParameter("dueDate");
            int maxMarks = Integer.parseInt(request.getParameter("maxMarks"));
            
            // Find course by code
            int courseId = getCourseIdByCode(courseCode, user.getUserId());
            
            if (courseId == -1) {
                session.setAttribute("error", "Course not found or you don't have permission to create assignments for this course.");
                response.sendRedirect(request.getContextPath() + "/teacher/dashboard");
                return;
            }
            
            // Parse due date
            Timestamp dueDate = parseDateTime(dueDateStr);
            
            // Create assignment object
            Assignment assignment = new Assignment();
            assignment.setCourseId(courseId);
            assignment.setTitle(title);
            assignment.setDescription(description);
            assignment.setMaxMarks(maxMarks);
            assignment.setDueDate(dueDate);
            assignment.setCreatedBy(user.getUserId());
            
            // Save to database
            boolean created = assignmentDAO.createAssignment(assignment);
            
            if (created) {
                session.setAttribute("success", "Assignment created successfully!");
            } else {
                session.setAttribute("error", "Failed to create assignment. Please try again.");
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            session.setAttribute("error", "Database error: " + e.getMessage());
        } catch (NumberFormatException e) {
            session.setAttribute("error", "Invalid marks value. Please enter a valid number.");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "Error creating assignment: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/teacher/dashboard");
    }
    
    private int getCourseIdByCode(String courseCode, int teacherId) throws SQLException {
        // Get courses by teacher and find the matching course code
        List<Course> courses = courseDAO.getCoursesByTeacher(teacherId);
        for (Course course : courses) {
            if (course.getCourseCode().equals(courseCode)) {
                return course.getCourseId();
            }
        }
        return -1;
    }
    
    private Timestamp parseDateTime(String dateTimeStr) throws ParseException {
        // Input format from HTML5 datetime-local: "2025-11-30T23:59"
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
        Date date = sdf.parse(dateTimeStr);
        return new Timestamp(date.getTime());
    }
}
