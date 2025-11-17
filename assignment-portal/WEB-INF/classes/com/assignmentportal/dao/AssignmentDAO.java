package com.assignmentportal.dao;

import com.assignmentportal.model.Assignment;
import com.assignmentportal.util.DatabaseConnectionPool;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AssignmentDAO {
    private DatabaseConnectionPool connectionPool;
    
    public AssignmentDAO() {
        this.connectionPool = DatabaseConnectionPool.getInstance();
    }
    
    public boolean createAssignment(Assignment assignment) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = connectionPool.getConnection();
            String sql = "INSERT INTO assignments (course_id, title, description, max_marks, " +
                        "due_date, created_by) VALUES (?, ?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, assignment.getCourseId());
            pstmt.setString(2, assignment.getTitle());
            pstmt.setString(3, assignment.getDescription());
            pstmt.setInt(4, assignment.getMaxMarks());
            pstmt.setTimestamp(5, assignment.getDueDate());
            pstmt.setInt(6, assignment.getCreatedBy());
            
            return pstmt.executeUpdate() > 0;
        } finally {
            closeResources(null, pstmt, conn);
        }
    }
    
    public List<Assignment> getAssignmentsByCourse(int courseId) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<Assignment> assignments = new ArrayList<>();
        
        try {
            conn = connectionPool.getConnection();
            String sql = "SELECT a.*, c.course_name, c.course_code, u.full_name as created_by_name " +
                        "FROM assignments a " +
                        "JOIN courses c ON a.course_id = c.course_id " +
                        "JOIN users u ON a.created_by = u.user_id " +
                        "WHERE a.course_id = ? AND a.is_active = TRUE " +
                        "ORDER BY a.due_date DESC";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, courseId);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                assignments.add(extractAssignmentFromResultSet(rs));
            }
            return assignments;
        } finally {
            closeResources(rs, pstmt, conn);
        }
    }
    
    public List<Assignment> getAssignmentsByStudent(int studentId) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<Assignment> assignments = new ArrayList<>();
        
        try {
            conn = connectionPool.getConnection();
            String sql = "SELECT a.*, c.course_name, c.course_code, u.full_name as created_by_name, " +
                        "s.submission_id, s.status as submission_status " +
                        "FROM assignments a " +
                        "JOIN courses c ON a.course_id = c.course_id " +
                        "JOIN enrollments e ON c.course_id = e.course_id " +
                        "JOIN users u ON a.created_by = u.user_id " +
                        "LEFT JOIN submissions s ON a.assignment_id = s.assignment_id AND s.student_id = ? " +
                        "WHERE e.student_id = ? AND e.status = 'ACTIVE' AND a.is_active = TRUE " +
                        "ORDER BY a.due_date ASC";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, studentId);
            pstmt.setInt(2, studentId);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                assignments.add(extractAssignmentFromResultSet(rs));
            }
            return assignments;
        } finally {
            closeResources(rs, pstmt, conn);
        }
    }
    
    public Assignment getAssignmentById(int assignmentId) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = connectionPool.getConnection();
            String sql = "SELECT a.*, c.course_name, c.course_code, u.full_name as created_by_name " +
                        "FROM assignments a " +
                        "JOIN courses c ON a.course_id = c.course_id " +
                        "JOIN users u ON a.created_by = u.user_id " +
                        "WHERE a.assignment_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, assignmentId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return extractAssignmentFromResultSet(rs);
            }
            return null;
        } finally {
            closeResources(rs, pstmt, conn);
        }
    }
    
    public boolean updateAssignment(Assignment assignment) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = connectionPool.getConnection();
            String sql = "UPDATE assignments SET title = ?, description = ?, " +
                        "max_marks = ?, due_date = ? WHERE assignment_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, assignment.getTitle());
            pstmt.setString(2, assignment.getDescription());
            pstmt.setInt(3, assignment.getMaxMarks());
            pstmt.setTimestamp(4, assignment.getDueDate());
            pstmt.setInt(5, assignment.getAssignmentId());
            
            return pstmt.executeUpdate() > 0;
        } finally {
            closeResources(null, pstmt, conn);
        }
    }
    
    public boolean deleteAssignment(int assignmentId) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = connectionPool.getConnection();
            String sql = "UPDATE assignments SET is_active = FALSE WHERE assignment_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, assignmentId);
            
            return pstmt.executeUpdate() > 0;
        } finally {
            closeResources(null, pstmt, conn);
        }
    }
    
    private Assignment extractAssignmentFromResultSet(ResultSet rs) throws SQLException {
        Assignment assignment = new Assignment();
        assignment.setAssignmentId(rs.getInt("assignment_id"));
        assignment.setCourseId(rs.getInt("course_id"));
        assignment.setTitle(rs.getString("title"));
        assignment.setDescription(rs.getString("description"));
        assignment.setMaxMarks(rs.getInt("max_marks"));
        assignment.setDueDate(rs.getTimestamp("due_date"));
        assignment.setFilePath(rs.getString("file_path"));
        assignment.setCreatedBy(rs.getInt("created_by"));
        assignment.setActive(rs.getBoolean("is_active"));
        assignment.setCreatedAt(rs.getTimestamp("created_at"));
        
        if (rs.getMetaData().getColumnCount() > 10) {
            assignment.setCourseName(rs.getString("course_name"));
            assignment.setCourseCode(rs.getString("course_code"));
            assignment.setCreatedByName(rs.getString("created_by_name"));
        }
        
        return assignment;
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
