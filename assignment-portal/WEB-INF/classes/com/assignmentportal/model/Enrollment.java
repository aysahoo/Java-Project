package com.assignmentportal.model;

import java.sql.Timestamp;

/**
 * Enrollment Model Class
 * Represents a student's enrollment in a course
 */
public class Enrollment {
    private int enrollmentId;
    private int studentId;
    private String studentName; // For display
    private String studentEmail; // For display
    private int courseId;
    private String courseCode; // For display
    private String courseName; // For display
    private Timestamp enrollmentDate;
    private String status; // ACTIVE, DROPPED, COMPLETED
    
    // Constructors
    public Enrollment() {}
    
    public Enrollment(int studentId, int courseId, String status) {
        this.studentId = studentId;
        this.courseId = courseId;
        this.status = status;
    }
    
    // Getters and Setters
    public int getEnrollmentId() {
        return enrollmentId;
    }
    
    public void setEnrollmentId(int enrollmentId) {
        this.enrollmentId = enrollmentId;
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
    
    public String getStudentEmail() {
        return studentEmail;
    }
    
    public void setStudentEmail(String studentEmail) {
        this.studentEmail = studentEmail;
    }
    
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
    
    public Timestamp getEnrollmentDate() {
        return enrollmentDate;
    }
    
    public void setEnrollmentDate(Timestamp enrollmentDate) {
        this.enrollmentDate = enrollmentDate;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    @Override
    public String toString() {
        return "Enrollment{" +
                "enrollmentId=" + enrollmentId +
                ", studentId=" + studentId +
                ", courseId=" + courseId +
                ", status='" + status + '\'' +
                ", enrollmentDate=" + enrollmentDate +
                '}';
    }
}
