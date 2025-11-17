package com.assignmentportal.servlet;

import com.assignmentportal.dao.SubmissionDAO;
import com.assignmentportal.model.Submission;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;

public class GradeSubmissionServlet extends HttpServlet {
    private SubmissionDAO submissionDAO;
    
    @Override
    public void init() throws ServletException {
        submissionDAO = new SubmissionDAO();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || !"TEACHER".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        int teacherId = (Integer) session.getAttribute("userId");
        
        String submissionIdStr = request.getParameter("submissionId");
        String marksStr = request.getParameter("marks");
        String feedback = request.getParameter("feedback");
        
        System.out.println("Grading request - Submission ID: " + submissionIdStr + ", Marks: " + marksStr);
        
        if (submissionIdStr == null || marksStr == null) {
            session.setAttribute("error", "Submission ID and marks are required");
            response.sendRedirect(request.getContextPath() + "/teacher/dashboard");
            return;
        }
        
        try {
            int submissionId = Integer.parseInt(submissionIdStr);
            int marks = Integer.parseInt(marksStr);
            
            // Get submission to validate marks
            Submission submission = submissionDAO.getSubmissionById(submissionId);
            if (submission == null) {
                session.setAttribute("error", "Submission not found");
                response.sendRedirect(request.getContextPath() + "/teacher/dashboard");
                return;
            }
            
            if (marks < 0 || marks > submission.getMaxMarks()) {
                session.setAttribute("error", 
                    "Marks must be between 0 and " + submission.getMaxMarks());
                response.sendRedirect(request.getContextPath() + "/teacher/dashboard");
                return;
            }
            
            // Grade the submission
            boolean success = submissionDAO.gradeSubmission(
                submissionId, marks, feedback, teacherId);
            
            if (success) {
                session.setAttribute("success", "Submission graded successfully!");
                System.out.println("Submission graded successfully: " + submissionId);
            } else {
                session.setAttribute("error", "Failed to grade submission");
            }
            
            response.sendRedirect(request.getContextPath() + "/teacher/dashboard");
            
        } catch (NumberFormatException e) {
            session.setAttribute("error", "Invalid marks value");
            response.sendRedirect(request.getContextPath() + "/teacher/dashboard");
        } catch (SQLException e) {
            e.printStackTrace();
            session.setAttribute("error", "Database error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/teacher/dashboard");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "Error grading submission: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/teacher/dashboard");
        }
    }
}
