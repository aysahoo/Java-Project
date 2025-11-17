package com.assignmentportal.servlet;

import com.assignmentportal.dao.AssignmentDAO;
import com.assignmentportal.dao.SubmissionDAO;
import com.assignmentportal.model.Assignment;
import com.assignmentportal.model.Submission;
import com.assignmentportal.util.FileUploadHandler;

import javax.servlet.*;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.sql.Timestamp;

@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 10,       // 10MB
    maxRequestSize = 1024 * 1024 * 15     // 15MB
)
public class SubmitAssignmentServlet extends HttpServlet {
    private SubmissionDAO submissionDAO;
    private AssignmentDAO assignmentDAO;
    private FileUploadHandler fileHandler;
    
    @Override
    public void init() throws ServletException {
        submissionDAO = new SubmissionDAO();
        assignmentDAO = new AssignmentDAO();
        
        // Get upload directory from context - use absolute path
        String uploadPath = getServletContext().getRealPath("/");
        if (uploadPath == null) {
            uploadPath = System.getProperty("user.home") + "/assignment-uploads";
        } else {
            uploadPath = uploadPath + "uploads";
        }
        
        // Ensure directory exists
        java.io.File uploadDir = new java.io.File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
            System.out.println("Created upload directory: " + uploadPath);
        }
        
        fileHandler = new FileUploadHandler(uploadPath);
        System.out.println("SubmitAssignmentServlet initialized with upload path: " + uploadPath);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        int studentId = (Integer) session.getAttribute("userId");
        String assignmentIdStr = request.getParameter("assignmentId");
        
        System.out.println("Submission request - Student ID: " + studentId + ", Assignment ID: " + assignmentIdStr);
        
        if (assignmentIdStr == null || assignmentIdStr.isEmpty()) {
            session.setAttribute("error", "Assignment ID is required");
            response.sendRedirect(request.getContextPath() + "/student/dashboard");
            return;
        }
        
        int assignmentId;
        try {
            assignmentId = Integer.parseInt(assignmentIdStr);
        } catch (NumberFormatException e) {
            session.setAttribute("error", "Invalid assignment ID");
            response.sendRedirect(request.getContextPath() + "/student/dashboard");
            return;
        }
        
        try {
            // Get assignment details
            Assignment assignment = assignmentDAO.getAssignmentById(assignmentId);
            if (assignment == null) {
                session.setAttribute("error", "Assignment not found");
                response.sendRedirect(request.getContextPath() + "/student/dashboard");
                return;
            }
            
            // Check if already submitted
            Submission existing = submissionDAO.getStudentSubmissionForAssignment(
                studentId, assignmentId);
            if (existing != null) {
                session.setAttribute("error", "You have already submitted this assignment");
                response.sendRedirect(request.getContextPath() + "/student/dashboard");
                return;
            }
            
            // Get uploaded file
            Part filePart = request.getPart("file");
            
            if (filePart == null || filePart.getSize() == 0) {
                session.setAttribute("error", "Please select a file to upload");
                response.sendRedirect(request.getContextPath() + "/student/dashboard");
                return;
            }
            
            System.out.println("File part received - Size: " + filePart.getSize() + ", Name: " + filePart.getSubmittedFileName());
            
            // Validate file
            FileUploadHandler.ValidationResult validation = fileHandler.validateFile(filePart);
            if (!validation.isValid()) {
                session.setAttribute("error", validation.getMessage());
                response.sendRedirect(request.getContextPath() + "/student/dashboard");
                return;
            }
            
            // Upload file
            String subfolder = "assignments/" + assignmentId;
            FileUploadHandler.UploadResult uploadResult = 
                fileHandler.uploadFile(filePart, subfolder);
            
            if (!uploadResult.isSuccess()) {
                session.setAttribute("error", uploadResult.getMessage());
                response.sendRedirect(request.getContextPath() + "/student/dashboard");
                return;
            }
            
            System.out.println("File uploaded successfully: " + uploadResult.getFilePath());
            
            // Check if late
            boolean isLate = assignment.getDueDate().before(new Timestamp(System.currentTimeMillis()));
            
            // Create submission
            Submission submission = new Submission();
            submission.setAssignmentId(assignmentId);
            submission.setStudentId(studentId);
            submission.setFilePath(uploadResult.getFilePath());
            submission.setOriginalFilename(filePart.getSubmittedFileName());
            submission.setFileSizeKb((int) (uploadResult.getFileSize() / 1024));
            submission.setLate(isLate);
            submission.setStatus(isLate ? "LATE" : "SUBMITTED");
            
            int submissionId = submissionDAO.createSubmission(submission);
            
            if (submissionId > 0) {
                session.setAttribute("success", "Assignment submitted successfully!");
                System.out.println("Submission created with ID: " + submissionId);
            } else {
                session.setAttribute("error", "Failed to submit assignment");
            }
            
            response.sendRedirect(request.getContextPath() + "/student/dashboard");
            
        } catch (SQLException e) {
            e.printStackTrace();
            session.setAttribute("error", "Database error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/student/dashboard");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "Error submitting assignment: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/student/dashboard");
        }
    }
}
