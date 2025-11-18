package com.assignmentportal.servlet;

import com.assignmentportal.dao.SubmissionDAO;
import com.assignmentportal.dao.AssignmentDAO;
import com.assignmentportal.dao.CourseDAO;
import com.assignmentportal.model.User;
import com.assignmentportal.model.Submission;
import com.assignmentportal.model.Assignment;
import com.assignmentportal.model.Course;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

public class TeacherDashboardServlet extends HttpServlet {
    private SubmissionDAO submissionDAO;
    private AssignmentDAO assignmentDAO;
    private CourseDAO courseDAO;
    
    @Override
    public void init() throws ServletException {
        submissionDAO = new SubmissionDAO();
        assignmentDAO = new AssignmentDAO();
        courseDAO = new CourseDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        
        System.out.println("TeacherDashboardServlet - Session: " + session);
        if (session != null) {
            System.out.println("TeacherDashboardServlet - User in session: " + session.getAttribute("user"));
        }
        
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
            // Fetch teacher's courses
            List<Course> courses = courseDAO.getCoursesByTeacher(user.getUserId());
            request.setAttribute("courses", courses);
            System.out.println("TeacherDashboardServlet - Found " + courses.size() + " courses");
            
            // Fetch all assignments for teacher's courses
            List<Assignment> allAssignments = new java.util.ArrayList<>();
            for (Course course : courses) {
                List<Assignment> assignments = assignmentDAO.getAssignmentsByCourse(course.getCourseId());
                allAssignments.addAll(assignments);
            }
            request.setAttribute("assignments", allAssignments);
            System.out.println("TeacherDashboardServlet - Found " + allAssignments.size() + " assignments");
            
            // Fetch all submissions for teacher's courses
            List<Submission> allSubmissions = new java.util.ArrayList<>();
            for (Assignment assignment : allAssignments) {
                List<Submission> submissions = submissionDAO.getSubmissionsByAssignment(assignment.getAssignmentId());
                allSubmissions.addAll(submissions);
            }
            
            request.setAttribute("submissions", allSubmissions);
            System.out.println("TeacherDashboardServlet - Found " + allSubmissions.size() + " submissions");
            
        } catch (SQLException e) {
            e.printStackTrace();
            System.err.println("Error fetching data: " + e.getMessage());
        }
        
        request.getRequestDispatcher("/jsp/teacher-dashboard.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
