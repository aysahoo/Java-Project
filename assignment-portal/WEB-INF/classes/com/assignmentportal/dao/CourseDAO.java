package com.assignmentportal.dao;

import com.assignmentportal.model.Course;
import com.assignmentportal.util.DatabaseConnectionPool;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CourseDAO {
    private DatabaseConnectionPool connectionPool;
    
    public CourseDAO() {
        this.connectionPool = DatabaseConnectionPool.getInstance();
    }
    
    public boolean createCourse(Course course) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = connectionPool.getConnection();
            String sql = "INSERT INTO courses (course_code, course_name, description, teacher_id) " +
                        "VALUES (?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, course.getCourseCode());
            pstmt.setString(2, course.getCourseName());
            pstmt.setString(3, course.getDescription());
            pstmt.setInt(4, course.getTeacherId());
            
            return pstmt.executeUpdate() > 0;
        } finally {
            closeResources(null, pstmt, conn);
        }
    }
    
    public List<Course> getAllCourses() throws SQLException {
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        List<Course> courses = new ArrayList<>();
        
        try {
            conn = connectionPool.getConnection();
            String sql = "SELECT c.*, u.full_name as teacher_name " +
                        "FROM courses c " +
                        "JOIN users u ON c.teacher_id = u.user_id " +
                        "WHERE c.is_active = TRUE " +
                        "ORDER BY c.course_code";
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            
            while (rs.next()) {
                courses.add(extractCourseFromResultSet(rs));
            }
            return courses;
        } finally {
            closeResources(rs, stmt, conn);
        }
    }
    
    public List<Course> getCoursesByTeacher(int teacherId) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<Course> courses = new ArrayList<>();
        
        try {
            conn = connectionPool.getConnection();
            String sql = "SELECT c.*, u.full_name as teacher_name " +
                        "FROM courses c " +
                        "JOIN users u ON c.teacher_id = u.user_id " +
                        "WHERE c.teacher_id = ? AND c.is_active = TRUE " +
                        "ORDER BY c.course_code";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, teacherId);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                courses.add(extractCourseFromResultSet(rs));
            }
            return courses;
        } finally {
            closeResources(rs, pstmt, conn);
        }
    }
    
    public List<Course> getCoursesByStudent(int studentId) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<Course> courses = new ArrayList<>();
        
        try {
            conn = connectionPool.getConnection();
            String sql = "SELECT c.*, u.full_name as teacher_name " +
                        "FROM courses c " +
                        "JOIN users u ON c.teacher_id = u.user_id " +
                        "JOIN enrollments e ON c.course_id = e.course_id " +
                        "WHERE e.student_id = ? AND e.status = 'ACTIVE' AND c.is_active = TRUE " +
                        "ORDER BY c.course_code";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, studentId);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                courses.add(extractCourseFromResultSet(rs));
            }
            return courses;
        } finally {
            closeResources(rs, pstmt, conn);
        }
    }
    
    public Course getCourseById(int courseId) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = connectionPool.getConnection();
            String sql = "SELECT c.*, u.full_name as teacher_name " +
                        "FROM courses c " +
                        "JOIN users u ON c.teacher_id = u.user_id " +
                        "WHERE c.course_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, courseId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return extractCourseFromResultSet(rs);
            }
            return null;
        } finally {
            closeResources(rs, pstmt, conn);
        }
    }
    
    public boolean updateCourse(Course course) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = connectionPool.getConnection();
            String sql = "UPDATE courses SET course_code = ?, course_name = ?, " +
                        "description = ?, teacher_id = ? WHERE course_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, course.getCourseCode());
            pstmt.setString(2, course.getCourseName());
            pstmt.setString(3, course.getDescription());
            pstmt.setInt(4, course.getTeacherId());
            pstmt.setInt(5, course.getCourseId());
            
            return pstmt.executeUpdate() > 0;
        } finally {
            closeResources(null, pstmt, conn);
        }
    }
    
    public boolean deleteCourse(int courseId) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = connectionPool.getConnection();
            String sql = "UPDATE courses SET is_active = FALSE WHERE course_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, courseId);
            
            return pstmt.executeUpdate() > 0;
        } finally {
            closeResources(null, pstmt, conn);
        }
    }
    
    private Course extractCourseFromResultSet(ResultSet rs) throws SQLException {
        Course course = new Course();
        course.setCourseId(rs.getInt("course_id"));
        course.setCourseCode(rs.getString("course_code"));
        course.setCourseName(rs.getString("course_name"));
        course.setDescription(rs.getString("description"));
        course.setTeacherId(rs.getInt("teacher_id"));
        course.setActive(rs.getBoolean("is_active"));
        course.setCreatedAt(rs.getTimestamp("created_at"));
        
        try {
            course.setTeacherName(rs.getString("teacher_name"));
        } catch (SQLException e) { }
        
        return course;
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
