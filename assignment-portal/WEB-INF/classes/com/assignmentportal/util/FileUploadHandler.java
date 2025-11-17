package com.assignmentportal.util;

import javax.servlet.http.Part;
import java.io.*;
import java.nio.file.*;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

/**
 * File Upload Handler with multithreading support
 * Handles file uploads with validation and concurrent processing
 */
public class FileUploadHandler {
    private static final long MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB in bytes
    private static final List<String> ALLOWED_EXTENSIONS = 
        Arrays.asList("pdf", "docx", "doc", "zip", "rar", "txt", "java");
    
    private static final ExecutorService executorService = 
        Executors.newFixedThreadPool(5); // Thread pool for concurrent uploads
    
    private String uploadDirectory;
    
    public FileUploadHandler(String uploadDirectory) {
        this.uploadDirectory = uploadDirectory;
        createUploadDirectory();
    }
    
    /**
     * Create upload directory if it doesn't exist
     */
    private void createUploadDirectory() {
        try {
            Path uploadPath = Paths.get(uploadDirectory);
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
                System.out.println("Upload directory created: " + uploadDirectory);
            }
        } catch (IOException e) {
            System.err.println("Error creating upload directory: " + e.getMessage());
            throw new RuntimeException("Failed to create upload directory", e);
        }
    }
    
    /**
     * Validate file before upload
     */
    public ValidationResult validateFile(Part filePart) {
        if (filePart == null) {
            return new ValidationResult(false, "No file provided");
        }
        
        String fileName = getFileName(filePart);
        if (fileName == null || fileName.isEmpty()) {
            return new ValidationResult(false, "Invalid file name");
        }
        
        // Check file size
        long fileSize = filePart.getSize();
        if (fileSize > MAX_FILE_SIZE) {
            return new ValidationResult(false, 
                String.format("File size exceeds maximum allowed size of %d MB", 
                    MAX_FILE_SIZE / (1024 * 1024)));
        }
        
        if (fileSize == 0) {
            return new ValidationResult(false, "File is empty");
        }
        
        // Check file extension
        String extension = getFileExtension(fileName);
        if (!ALLOWED_EXTENSIONS.contains(extension.toLowerCase())) {
            return new ValidationResult(false, 
                "File type not allowed. Allowed types: " + ALLOWED_EXTENSIONS.toString());
        }
        
        return new ValidationResult(true, "File is valid");
    }
    
    /**
     * Upload file synchronously
     */
    public UploadResult uploadFile(Part filePart, String subfolder) {
        ValidationResult validation = validateFile(filePart);
        if (!validation.isValid()) {
            return new UploadResult(false, null, null, 0, validation.getMessage());
        }
        
        String originalFileName = getFileName(filePart);
        String uniqueFileName = generateUniqueFileName(originalFileName);
        String targetPath = subfolder != null ? 
            uploadDirectory + File.separator + subfolder : uploadDirectory;
        
        try {
            // Create subfolder if specified
            Path subfolderPath = Paths.get(targetPath);
            if (!Files.exists(subfolderPath)) {
                Files.createDirectories(subfolderPath);
            }
            
            // Save file
            String fullPath = targetPath + File.separator + uniqueFileName;
            try (InputStream input = filePart.getInputStream()) {
                Files.copy(input, Paths.get(fullPath), 
                    StandardCopyOption.REPLACE_EXISTING);
            }
            
            long fileSize = filePart.getSize();
            
            System.out.println("File uploaded successfully: " + uniqueFileName);
            return new UploadResult(true, uniqueFileName, fullPath, 
                fileSize, "File uploaded successfully");
            
        } catch (IOException e) {
            System.err.println("Error uploading file: " + e.getMessage());
            return new UploadResult(false, null, null, 0, 
                "Error uploading file: " + e.getMessage());
        }
    }
    
    /**
     * Upload file asynchronously using thread pool
     */
    public Future<UploadResult> uploadFileAsync(Part filePart, String subfolder) {
        return executorService.submit(() -> uploadFile(filePart, subfolder));
    }
    
    /**
     * Delete a file
     */
    public boolean deleteFile(String filePath) {
        try {
            Path path = Paths.get(filePath);
            if (Files.exists(path)) {
                Files.delete(path);
                System.out.println("File deleted: " + filePath);
                return true;
            }
            return false;
        } catch (IOException e) {
            System.err.println("Error deleting file: " + e.getMessage());
            return false;
        }
    }
    
    /**
     * Get file from uploads directory
     */
    public File getFile(String fileName, String subfolder) {
        String filePath = subfolder != null ? 
            uploadDirectory + File.separator + subfolder + File.separator + fileName :
            uploadDirectory + File.separator + fileName;
        
        File file = new File(filePath);
        return file.exists() ? file : null;
    }
    
    /**
     * Extract filename from Part header
     */
    private String getFileName(Part part) {
        String contentDisposition = part.getHeader("content-disposition");
        if (contentDisposition != null) {
            for (String token : contentDisposition.split(";")) {
                if (token.trim().startsWith("filename")) {
                    return token.substring(token.indexOf('=') + 1)
                        .trim().replace("\"", "");
                }
            }
        }
        return null;
    }
    
    /**
     * Get file extension
     */
    private String getFileExtension(String fileName) {
        int lastDotIndex = fileName.lastIndexOf('.');
        if (lastDotIndex > 0 && lastDotIndex < fileName.length() - 1) {
            return fileName.substring(lastDotIndex + 1);
        }
        return "";
    }
    
    /**
     * Generate unique filename to avoid conflicts
     */
    private String generateUniqueFileName(String originalFileName) {
        String extension = getFileExtension(originalFileName);
        String nameWithoutExt = originalFileName.substring(0, 
            originalFileName.lastIndexOf('.'));
        
        // Clean filename
        nameWithoutExt = nameWithoutExt.replaceAll("[^a-zA-Z0-9-_]", "_");
        
        // Add UUID for uniqueness
        String uuid = UUID.randomUUID().toString().substring(0, 8);
        return nameWithoutExt + "_" + uuid + "." + extension;
    }
    
    /**
     * Shutdown executor service
     */
    public static void shutdown() {
        executorService.shutdown();
    }
    
    /**
     * Validation Result class
     */
    public static class ValidationResult {
        private boolean valid;
        private String message;
        
        public ValidationResult(boolean valid, String message) {
            this.valid = valid;
            this.message = message;
        }
        
        public boolean isValid() { return valid; }
        public String getMessage() { return message; }
    }
    
    /**
     * Upload Result class
     */
    public static class UploadResult {
        private boolean success;
        private String fileName;
        private String filePath;
        private long fileSize;
        private String message;
        
        public UploadResult(boolean success, String fileName, String filePath, 
                          long fileSize, String message) {
            this.success = success;
            this.fileName = fileName;
            this.filePath = filePath;
            this.fileSize = fileSize;
            this.message = message;
        }
        
        public boolean isSuccess() { return success; }
        public String getFileName() { return fileName; }
        public String getFilePath() { return filePath; }
        public long getFileSize() { return fileSize; }
        public String getMessage() { return message; }
    }
}
