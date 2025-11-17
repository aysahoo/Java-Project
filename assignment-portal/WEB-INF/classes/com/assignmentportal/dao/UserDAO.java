package com.assignmentportal.dao;

import com.assignmentportal.model.User;
import com.assignmentportal.util.DatabaseConnectionPool;
import com.assignmentportal.util.ValidationUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * User Data Access Object
 * Handles all database operations for User entity
 */
public class UserDAO {
    private DatabaseConnectionPool connectionPool;
    
    public UserDAO() {
        this.connectionPool = DatabaseConnectionPool.getInstance();
    }
    
    /**
     * Authenticate user login
     */
    public User authenticate(String username, String password) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = connectionPool.getConnection();
            String sql = "SELECT * FROM users WHERE username = ? AND password = md5(?) AND is_active = TRUE";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, username);
            pstmt.setString(2, password);
            
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return extractUserFromResultSet(rs);
            }
            return null;
            
        } finally {
            closeResources(rs, pstmt, conn);
        }
    }
    
    /**
     * Create a new user
     */
    public boolean createUser(User user) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = connectionPool.getConnection();
            String sql = "INSERT INTO users (username, password, email, full_name, role, is_active) " +
                        "VALUES (?, md5(?), ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, user.getUsername());
            pstmt.setString(2, user.getPassword());
            pstmt.setString(3, user.getEmail());
            pstmt.setString(4, user.getFullName());
            pstmt.setString(5, user.getRole());
            pstmt.setBoolean(6, user.isActive());
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
            
        } finally {
            closeResources(null, pstmt, conn);
        }
    }
    
    /**
     * Get user by ID
     */
    public User getUserById(int userId) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = connectionPool.getConnection();
            String sql = "SELECT * FROM users WHERE user_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return extractUserFromResultSet(rs);
            }
            return null;
            
        } finally {
            closeResources(rs, pstmt, conn);
        }
    }
    
    /**
     * Get user by username
     */
    public User getUserByUsername(String username) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = connectionPool.getConnection();
            String sql = "SELECT * FROM users WHERE username = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, username);
            
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return extractUserFromResultSet(rs);
            }
            return null;
            
        } finally {
            closeResources(rs, pstmt, conn);
        }
    }
    
    /**
     * Get all users by role
     */
    public List<User> getUsersByRole(String role) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<User> users = new ArrayList<>();
        
        try {
            conn = connectionPool.getConnection();
            String sql = "SELECT * FROM users WHERE role = ? ORDER BY full_name";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, role);
            
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                users.add(extractUserFromResultSet(rs));
            }
            return users;
            
        } finally {
            closeResources(rs, pstmt, conn);
        }
    }
    
    /**
     * Get all users
     */
    public List<User> getAllUsers() throws SQLException {
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        List<User> users = new ArrayList<>();
        
        try {
            conn = connectionPool.getConnection();
            String sql = "SELECT * FROM users ORDER BY created_at DESC";
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            
            while (rs.next()) {
                users.add(extractUserFromResultSet(rs));
            }
            return users;
            
        } finally {
            closeResources(rs, stmt, conn);
        }
    }
    
    /**
     * Update user
     */
    public boolean updateUser(User user) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = connectionPool.getConnection();
            String sql = "UPDATE users SET email = ?, full_name = ?, role = ?, " +
                        "is_active = ? WHERE user_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, user.getEmail());
            pstmt.setString(2, user.getFullName());
            pstmt.setString(3, user.getRole());
            pstmt.setBoolean(4, user.isActive());
            pstmt.setInt(5, user.getUserId());
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
            
        } finally {
            closeResources(null, pstmt, conn);
        }
    }
    
    /**
     * Update user password
     */
    public boolean updatePassword(int userId, String newPassword) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = connectionPool.getConnection();
            String sql = "UPDATE users SET password = md5(?) WHERE user_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, newPassword);
            pstmt.setInt(2, userId);
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
            
        } finally {
            closeResources(null, pstmt, conn);
        }
    }
    
    /**
     * Activate/Deactivate user
     */
    public boolean toggleUserStatus(int userId, boolean isActive) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = connectionPool.getConnection();
            String sql = "UPDATE users SET is_active = ? WHERE user_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setBoolean(1, isActive);
            pstmt.setInt(2, userId);
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
            
        } finally {
            closeResources(null, pstmt, conn);
        }
    }
    
    /**
     * Delete user
     */
    public boolean deleteUser(int userId) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = connectionPool.getConnection();
            String sql = "DELETE FROM users WHERE user_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
            
        } finally {
            closeResources(null, pstmt, conn);
        }
    }
    
    /**
     * Check if username exists
     */
    public boolean usernameExists(String username) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = connectionPool.getConnection();
            String sql = "SELECT COUNT(*) FROM users WHERE username = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, username);
            
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            return false;
            
        } finally {
            closeResources(rs, pstmt, conn);
        }
    }
    
    /**
     * Check if email exists
     */
    public boolean emailExists(String email) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = connectionPool.getConnection();
            String sql = "SELECT COUNT(*) FROM users WHERE email = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, email);
            
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            return false;
            
        } finally {
            closeResources(rs, pstmt, conn);
        }
    }
    
    /**
     * Extract User object from ResultSet
     */
    private User extractUserFromResultSet(ResultSet rs) throws SQLException {
        User user = new User();
        user.setUserId(rs.getInt("user_id"));
        user.setUsername(rs.getString("username"));
        user.setEmail(rs.getString("email"));
        user.setFullName(rs.getString("full_name"));
        user.setRole(rs.getString("role"));
        user.setActive(rs.getBoolean("is_active"));
        user.setCreatedAt(rs.getTimestamp("created_at"));
        user.setUpdatedAt(rs.getTimestamp("updated_at"));
        return user;
    }
    
    /**
     * Close database resources
     */
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
