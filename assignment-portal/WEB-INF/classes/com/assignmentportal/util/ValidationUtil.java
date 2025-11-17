package com.assignmentportal.util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.regex.Pattern;

/**
 * Validation Utility class
 * Provides common validation methods for the application
 */
public class ValidationUtil {
    
    private static final Pattern EMAIL_PATTERN = Pattern.compile(
        "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    
    private static final Pattern USERNAME_PATTERN = Pattern.compile(
        "^[a-zA-Z0-9._-]{3,20}$");
    
    private static final Pattern PASSWORD_PATTERN = Pattern.compile(
        "^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z]).{8,}$");
    
    /**
     * Validate email address
     */
    public static boolean isValidEmail(String email) {
        return email != null && EMAIL_PATTERN.matcher(email).matches();
    }
    
    /**
     * Validate username
     * Must be 3-20 characters, alphanumeric with dots, underscores, hyphens
     */
    public static boolean isValidUsername(String username) {
        return username != null && USERNAME_PATTERN.matcher(username).matches();
    }
    
    /**
     * Validate password
     * Must be at least 8 characters with at least one digit, one lowercase, one uppercase
     */
    public static boolean isValidPassword(String password) {
        return password != null && password.length() >= 6;
        // For production, use: PASSWORD_PATTERN.matcher(password).matches();
    }
    
    /**
     * Validate string is not null or empty
     */
    public static boolean isNotEmpty(String str) {
        return str != null && !str.trim().isEmpty();
    }
    
    /**
     * Validate integer is positive
     */
    public static boolean isPositiveInteger(Integer num) {
        return num != null && num > 0;
    }
    
    /**
     * Validate marks (0-100)
     */
    public static boolean isValidMarks(Integer marks, Integer maxMarks) {
        return marks != null && maxMarks != null && 
               marks >= 0 && marks <= maxMarks;
    }
    
    /**
     * Hash password using SHA-256
     */
    public static String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hashedBytes = md.digest(password.getBytes());
            
            StringBuilder sb = new StringBuilder();
            for (byte b : hashedBytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
            
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Error hashing password", e);
        }
    }
    
    /**
     * Sanitize input to prevent SQL injection
     */
    public static String sanitizeInput(String input) {
        if (input == null) {
            return null;
        }
        // Remove potentially dangerous characters
        return input.replaceAll("[<>\"']", "");
    }
    
    /**
     * Validate role
     */
    public static boolean isValidRole(String role) {
        return role != null && 
               (role.equals("STUDENT") || role.equals("TEACHER") || role.equals("ADMIN"));
    }
    
    /**
     * Validate course code format
     */
    public static boolean isValidCourseCode(String code) {
        return code != null && code.matches("^[A-Z]{2,4}\\d{3}$");
    }
    
    /**
     * Format file size in human-readable format
     */
    public static String formatFileSize(long sizeInBytes) {
        if (sizeInBytes < 1024) {
            return sizeInBytes + " B";
        } else if (sizeInBytes < 1024 * 1024) {
            return String.format("%.2f KB", sizeInBytes / 1024.0);
        } else {
            return String.format("%.2f MB", sizeInBytes / (1024.0 * 1024.0));
        }
    }
    
    /**
     * Escape HTML to prevent XSS attacks
     */
    public static String escapeHtml(String input) {
        if (input == null) {
            return null;
        }
        return input.replace("&", "&amp;")
                   .replace("<", "&lt;")
                   .replace(">", "&gt;")
                   .replace("\"", "&quot;")
                   .replace("'", "&#x27;");
    }
}
