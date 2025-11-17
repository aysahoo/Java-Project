package com.assignmentportal.dao;

import com.assignmentportal.model.Submission;
import com.assignmentportal.util.DatabaseConnectionPool;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SubmissionDAO {
    private DatabaseConnectionPool connectionPool;
    
    public SubmissionDAO() {
        this.connectionPool = DatabaseConnectionPool.getInstance();
    }
    
    public int createSubmission(Submission submission) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = connectionPool.getConnection();
            String sql = "INSERT INTO submissions (assignment_id, student_id, file_path, " +
                        "original_filename, file_size_kb, is_late, status) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            pstmt.setInt(1, submission.getAssignmentId());
            pstmt.setInt(2, submission.getStudentId());
            pstmt.setString(3, submission.getFilePath());
            pstmt.setString(4, submission.getOriginalFilename());
            pstmt.setInt(5, submission.getFileSizeKb());
            pstmt.setBoolean(6, submission.isLate());
            pstmt.setString(7, submission.getStatus());
            
            int rowsAffected = pstmt.executeUpdate();
            if (rowsAffected > 0) {
                rs = pstmt.getGeneratedKeys();
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
            return -1;
        } finally {
            closeResources(rs, pstmt, conn);
        }
    }
    
    public List<Submission> getSubmissionsByAssignment(int assignmentId) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<Submission> submissions = new ArrayList<>();
        
        try {
            conn = connectionPool.getConnection();
            String sql = "SELECT s.*, u.full_name as student_name, u.email as student_email, " +
                        "a.title as assignment_title, a.max_marks, " +
                        "g.full_name as graded_by_name " +
                        "FROM submissions s " +
                        "JOIN users u ON s.student_id = u.user_id " +
                        "JOIN assignments a ON s.assignment_id = a.assignment_id " +
                        "LEFT JOIN users g ON s.graded_by = g.user_id " +
                        "WHERE s.assignment_id = ? " +
                        "ORDER BY s.submission_date DESC";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, assignmentId);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                submissions.add(extractSubmissionFromResultSet(rs));
            }
            return submissions;
        } finally {
            closeResources(rs, pstmt, conn);
        }
    }
    
    public List<Submission> getSubmissionsByStudent(int studentId) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<Submission> submissions = new ArrayList<>();
        
        try {
            conn = connectionPool.getConnection();
            String sql = "SELECT s.*, a.title as assignment_title, a.max_marks, " +
                        "c.course_name, c.course_code " +
                        "FROM submissions s " +
                        "JOIN assignments a ON s.assignment_id = a.assignment_id " +
                        "JOIN courses c ON a.course_id = c.course_id " +
                        "WHERE s.student_id = ? " +
                        "ORDER BY s.submission_date DESC";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, studentId);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                submissions.add(extractSubmissionFromResultSet(rs));
            }
            return submissions;
        } finally {
            closeResources(rs, pstmt, conn);
        }
    }
    
    public Submission getSubmissionById(int submissionId) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = connectionPool.getConnection();
            String sql = "SELECT s.*, u.full_name as student_name, " +
                        "a.title as assignment_title, a.max_marks " +
                        "FROM submissions s " +
                        "JOIN users u ON s.student_id = u.user_id " +
                        "JOIN assignments a ON s.assignment_id = a.assignment_id " +
                        "WHERE s.submission_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, submissionId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return extractSubmissionFromResultSet(rs);
            }
            return null;
        } finally {
            closeResources(rs, pstmt, conn);
        }
    }
    
    public boolean gradeSubmission(int submissionId, int marks, String feedback, int gradedBy) 
            throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = connectionPool.getConnection();
            String sql = "UPDATE submissions SET marks_obtained = ?, feedback = ?, " +
                        "graded_by = ?, graded_at = CURRENT_TIMESTAMP, status = 'GRADED' " +
                        "WHERE submission_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, marks);
            pstmt.setString(2, feedback);
            pstmt.setInt(3, gradedBy);
            pstmt.setInt(4, submissionId);
            
            return pstmt.executeUpdate() > 0;
        } finally {
            closeResources(null, pstmt, conn);
        }
    }
    
    public Submission getStudentSubmissionForAssignment(int studentId, int assignmentId) 
            throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = connectionPool.getConnection();
            String sql = "SELECT s.*, a.title as assignment_title, a.max_marks " +
                        "FROM submissions s " +
                        "JOIN assignments a ON s.assignment_id = a.assignment_id " +
                        "WHERE s.student_id = ? AND s.assignment_id = ? " +
                        "ORDER BY s.submission_date DESC LIMIT 1";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, studentId);
            pstmt.setInt(2, assignmentId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return extractSubmissionFromResultSet(rs);
            }
            return null;
        } finally {
            closeResources(rs, pstmt, conn);
        }
    }
    
    private Submission extractSubmissionFromResultSet(ResultSet rs) throws SQLException {
        Submission submission = new Submission();
        submission.setSubmissionId(rs.getInt("submission_id"));
        submission.setAssignmentId(rs.getInt("assignment_id"));
        submission.setStudentId(rs.getInt("student_id"));
        submission.setFilePath(rs.getString("file_path"));
        submission.setOriginalFilename(rs.getString("original_filename"));
        submission.setFileSizeKb(rs.getInt("file_size_kb"));
        submission.setSubmissionDate(rs.getTimestamp("submission_date"));
        submission.setStatus(rs.getString("status"));
        submission.setLate(rs.getBoolean("is_late"));
        
        Integer marks = (Integer) rs.getObject("marks_obtained");
        submission.setMarksObtained(marks);
        submission.setFeedback(rs.getString("feedback"));
        
        if (rs.getMetaData().getColumnCount() > 10) {
            submission.setAssignmentTitle(rs.getString("assignment_title"));
            submission.setMaxMarks(rs.getInt("max_marks"));
            
            try {
                submission.setStudentName(rs.getString("student_name"));
            } catch (SQLException e) { }
            
            try {
                submission.setCourseName(rs.getString("course_name"));
                submission.setCourseCode(rs.getString("course_code"));
            } catch (SQLException e) { }
        }
        
        return submission;
    }
    
    private void closeResources(ResultSet rs, Statement stmt, Connection conn) {
        try {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) connectionPool.releaseConnection(conn);
        } catch (SQLException e) {
            System.err.println("Error closing resources: " + e.getMessage());
        }
    }
}
