package com.assignmentportal.model;

import java.sql.Timestamp;

/**
 * Assignment Model Class
 * Represents an assignment in a course
 */
public class Assignment {
    private int assignmentId;
    private int courseId;
    private String courseName; // For display
    private String courseCode; // For display
    private String title;
    private String description;
    private int maxMarks;
    private Timestamp dueDate;
    private String filePath;
    private String allowedFileTypes;
    private int maxFileSizeMb;
    private int createdBy;
    private String createdByName; // For display
    private boolean isActive;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    // Additional fields for display
    private int totalSubmissions;
    private int gradedSubmissions;
    
    // Constructors
    public Assignment() {}
    
    public Assignment(int courseId, String title, String description, 
                     int maxMarks, Timestamp dueDate, int createdBy) {
        this.courseId = courseId;
        this.title = title;
        this.description = description;
        this.maxMarks = maxMarks;
        this.dueDate = dueDate;
        this.createdBy = createdBy;
        this.isActive = true;
        this.allowedFileTypes = "pdf,docx,zip";
        this.maxFileSizeMb = 10;
    }
    
    // Getters and Setters
    public int getAssignmentId() {
        return assignmentId;
    }
    
    public void setAssignmentId(int assignmentId) {
        this.assignmentId = assignmentId;
    }
    
    public int getCourseId() {
        return courseId;
    }
    
    public void setCourseId(int courseId) {
        this.courseId = courseId;
    }
    
    public String getCourseName() {
        return courseName;
    }
    
    public void setCourseName(String courseName) {
        this.courseName = courseName;
    }
    
    public String getCourseCode() {
        return courseCode;
    }
    
    public void setCourseCode(String courseCode) {
        this.courseCode = courseCode;
    }
    
    public String getTitle() {
        return title;
    }
    
    public void setTitle(String title) {
        this.title = title;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public int getMaxMarks() {
        return maxMarks;
    }
    
    public void setMaxMarks(int maxMarks) {
        this.maxMarks = maxMarks;
    }
    
    public Timestamp getDueDate() {
        return dueDate;
    }
    
    public void setDueDate(Timestamp dueDate) {
        this.dueDate = dueDate;
    }
    
    public String getFilePath() {
        return filePath;
    }
    
    public void setFilePath(String filePath) {
        this.filePath = filePath;
    }
    
    public String getAllowedFileTypes() {
        return allowedFileTypes;
    }
    
    public void setAllowedFileTypes(String allowedFileTypes) {
        this.allowedFileTypes = allowedFileTypes;
    }
    
    public int getMaxFileSizeMb() {
        return maxFileSizeMb;
    }
    
    public void setMaxFileSizeMb(int maxFileSizeMb) {
        this.maxFileSizeMb = maxFileSizeMb;
    }
    
    public int getCreatedBy() {
        return createdBy;
    }
    
    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
    }
    
    public String getCreatedByName() {
        return createdByName;
    }
    
    public void setCreatedByName(String createdByName) {
        this.createdByName = createdByName;
    }
    
    public boolean isActive() {
        return isActive;
    }
    
    public void setActive(boolean active) {
        isActive = active;
    }
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    
    public Timestamp getUpdatedAt() {
        return updatedAt;
    }
    
    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }
    
    public int getTotalSubmissions() {
        return totalSubmissions;
    }
    
    public void setTotalSubmissions(int totalSubmissions) {
        this.totalSubmissions = totalSubmissions;
    }
    
    public int getGradedSubmissions() {
        return gradedSubmissions;
    }
    
    public void setGradedSubmissions(int gradedSubmissions) {
        this.gradedSubmissions = gradedSubmissions;
    }
    
    public boolean isOverdue() {
        return dueDate != null && dueDate.before(new Timestamp(System.currentTimeMillis()));
    }
    
    @Override
    public String toString() {
        return "Assignment{" +
                "assignmentId=" + assignmentId +
                ", courseId=" + courseId +
                ", title='" + title + '\'' +
                ", maxMarks=" + maxMarks +
                ", dueDate=" + dueDate +
                ", isActive=" + isActive +
                '}';
    }
}
