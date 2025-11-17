package com.assignmentportal.model;

import java.sql.Timestamp;

/**
 * Submission Model Class
 * Represents a student's assignment submission
 */
public class Submission {
    private int submissionId;
    private int assignmentId;
    private String assignmentTitle; // For display
    private int studentId;
    private String studentName; // For display
    private String filePath;
    private String originalFilename;
    private int fileSizeKb;
    private Timestamp submissionDate;
    private Integer marksObtained;
    private String feedback;
    private Integer gradedBy;
    private String gradedByName; // For display
    private Timestamp gradedAt;
    private String status; // SUBMITTED, GRADED, LATE, RESUBMITTED
    private boolean isLate;
    
    // Additional fields for display
    private int maxMarks;
    private String courseCode;
    private String courseName;
    
    // Constructors
    public Submission() {}
    
    public Submission(int assignmentId, int studentId, String filePath, 
                     String originalFilename, int fileSizeKb, boolean isLate) {
        this.assignmentId = assignmentId;
        this.studentId = studentId;
        this.filePath = filePath;
        this.originalFilename = originalFilename;
        this.fileSizeKb = fileSizeKb;
        this.isLate = isLate;
        this.status = isLate ? "LATE" : "SUBMITTED";
    }
    
    // Getters and Setters
    public int getSubmissionId() {
        return submissionId;
    }
    
    public void setSubmissionId(int submissionId) {
        this.submissionId = submissionId;
    }
    
    public int getAssignmentId() {
        return assignmentId;
    }
    
    public void setAssignmentId(int assignmentId) {
        this.assignmentId = assignmentId;
    }
    
    public String getAssignmentTitle() {
        return assignmentTitle;
    }
    
    public void setAssignmentTitle(String assignmentTitle) {
        this.assignmentTitle = assignmentTitle;
    }
    
    public int getStudentId() {
        return studentId;
    }
    
    public void setStudentId(int studentId) {
        this.studentId = studentId;
    }
    
    public String getStudentName() {
        return studentName;
    }
    
    public void setStudentName(String studentName) {
        this.studentName = studentName;
    }
    
    public String getFilePath() {
        return filePath;
    }
    
    public void setFilePath(String filePath) {
        this.filePath = filePath;
    }
    
    public String getOriginalFilename() {
        return originalFilename;
    }
    
    public void setOriginalFilename(String originalFilename) {
        this.originalFilename = originalFilename;
    }
    
    public int getFileSizeKb() {
        return fileSizeKb;
    }
    
    public void setFileSizeKb(int fileSizeKb) {
        this.fileSizeKb = fileSizeKb;
    }
    
    public Timestamp getSubmissionDate() {
        return submissionDate;
    }
    
    public void setSubmissionDate(Timestamp submissionDate) {
        this.submissionDate = submissionDate;
    }
    
    public Integer getMarksObtained() {
        return marksObtained;
    }
    
    public void setMarksObtained(Integer marksObtained) {
        this.marksObtained = marksObtained;
    }
    
    public String getFeedback() {
        return feedback;
    }
    
    public void setFeedback(String feedback) {
        this.feedback = feedback;
    }
    
    public Integer getGradedBy() {
        return gradedBy;
    }
    
    public void setGradedBy(Integer gradedBy) {
        this.gradedBy = gradedBy;
    }
    
    public String getGradedByName() {
        return gradedByName;
    }
    
    public void setGradedByName(String gradedByName) {
        this.gradedByName = gradedByName;
    }
    
    public Timestamp getGradedAt() {
        return gradedAt;
    }
    
    public void setGradedAt(Timestamp gradedAt) {
        this.gradedAt = gradedAt;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public boolean isLate() {
        return isLate;
    }
    
    public void setLate(boolean late) {
        isLate = late;
    }
    
    public int getMaxMarks() {
        return maxMarks;
    }
    
    public void setMaxMarks(int maxMarks) {
        this.maxMarks = maxMarks;
    }
    
    public String getCourseCode() {
        return courseCode;
    }
    
    public void setCourseCode(String courseCode) {
        this.courseCode = courseCode;
    }
    
    public String getCourseName() {
        return courseName;
    }
    
    public void setCourseName(String courseName) {
        this.courseName = courseName;
    }
    
    public boolean isGraded() {
        return "GRADED".equals(status);
    }
    
    @Override
    public String toString() {
        return "Submission{" +
                "submissionId=" + submissionId +
                ", assignmentId=" + assignmentId +
                ", studentId=" + studentId +
                ", originalFilename='" + originalFilename + '\'' +
                ", status='" + status + '\'' +
                ", marksObtained=" + marksObtained +
                ", isLate=" + isLate +
                '}';
    }
}
