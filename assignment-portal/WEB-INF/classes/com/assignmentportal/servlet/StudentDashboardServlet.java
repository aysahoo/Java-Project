package com.assignmentportal.servlet;

import com.assignmentportal.dao.SubmissionDAO;
import com.assignmentportal.model.User;
import com.assignmentportal.model.Submission;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

public class StudentDashboardServlet extends HttpServlet {
    private SubmissionDAO submissionDAO;
    
    @Override
    public void init() throws ServletException {
        submissionDAO = new SubmissionDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        
        System.out.println("StudentDashboardServlet - Session: " + session);
        if (session != null) {
            System.out.println("StudentDashboardServlet - User in session: " + session.getAttribute("user"));
            System.out.println("StudentDashboardServlet - UserId: " + session.getAttribute("userId"));
            System.out.println("StudentDashboardServlet - Role: " + session.getAttribute("role"));
        }
        
        if (session == null || session.getAttribute("user") == null) {
            System.out.println("StudentDashboardServlet - No session or user, redirecting to login");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        User user = (User) session.getAttribute("user");
        if (!"STUDENT".equals(user.getRole())) {
            System.out.println("StudentDashboardServlet - Not a student, redirecting to login");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        // Fetch student's submissions
        try {
            int studentId = user.getUserId();
            List<Submission> submissions = submissionDAO.getSubmissionsByStudent(studentId);
            request.setAttribute("submissions", submissions);
            System.out.println("StudentDashboardServlet - Found " + submissions.size() + " submissions for student " + studentId);
        } catch (SQLException e) {
            e.printStackTrace();
            System.err.println("Error fetching submissions: " + e.getMessage());
        }
        
        System.out.println("StudentDashboardServlet - Forwarding to student dashboard");
        request.getRequestDispatcher("/jsp/student-dashboard.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
