package com.assignmentportal.servlet;

import com.assignmentportal.dao.SubmissionDAO;
import com.assignmentportal.model.User;
import com.assignmentportal.model.Submission;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

public class TeacherDashboardServlet extends HttpServlet {
    private SubmissionDAO submissionDAO;
    
    @Override
    public void init() throws ServletException {
        submissionDAO = new SubmissionDAO();
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
        
        // Fetch all submissions for teacher's courses
        try {
            // For now, fetch all submissions (assignment_id 1, 2, 3)
            List<Submission> allSubmissions = new java.util.ArrayList<>();
            for (int assignmentId = 1; assignmentId <= 3; assignmentId++) {
                List<Submission> submissions = submissionDAO.getSubmissionsByAssignment(assignmentId);
                allSubmissions.addAll(submissions);
            }
            
            request.setAttribute("submissions", allSubmissions);
            System.out.println("TeacherDashboardServlet - Found " + allSubmissions.size() + " submissions");
            
        } catch (SQLException e) {
            e.printStackTrace();
            System.err.println("Error fetching submissions: " + e.getMessage());
        }
        
        request.getRequestDispatcher("/jsp/teacher-dashboard.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
