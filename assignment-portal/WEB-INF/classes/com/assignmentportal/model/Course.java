package com.assignmentportal.model;

import java.sql.Timestamp;

/**
 * Course Model Class
 * Represents a course in the system
 */
public class Course {
    private int courseId;
    private String courseCode;
    private String courseName;
    private String description;
    private int teacherId;
    private String teacherName; // For display purposes
    private boolean isActive;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    // Constructors
    public Course() {}
    
    public Course(String courseCode, String courseName, String description, int teacherId) {
        this.courseCode = courseCode;
        this.courseName = courseName;
        this.description = description;
        this.teacherId = teacherId;
        this.isActive = true;
    }
    
    // Getters and Setters
    public int getCourseId() {
        return courseId;
    }
    
    public void setCourseId(int courseId) {
        this.courseId = courseId;
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
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public int getTeacherId() {
        return teacherId;
    }
    
    public void setTeacherId(int teacherId) {
        this.teacherId = teacherId;
    }
    
    public String getTeacherName() {
        return teacherName;
    }
    
    public void setTeacherName(String teacherName) {
        this.teacherName = teacherName;
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
    
    @Override
    public String toString() {
        return "Course{" +
                "courseId=" + courseId +
                ", courseCode='" + courseCode + '\'' +
                ", courseName='" + courseName + '\'' +
                ", teacherId=" + teacherId +
                ", isActive=" + isActive +
                '}';
    }
}
