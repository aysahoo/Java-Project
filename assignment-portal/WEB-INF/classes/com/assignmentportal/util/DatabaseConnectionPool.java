package com.assignmentportal.util;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.TimeUnit;

/**
 * Database Connection Pool using Multithreading
 * Thread-safe connection pool implementation with blocking queue
 */
public class DatabaseConnectionPool {
    private static DatabaseConnectionPool instance;
    private BlockingQueue<Connection> connectionPool;
    private BlockingQueue<Connection> usedConnections;
    
    private String url;
    private String username;
    private String password;
    private String driver;
    private int initialPoolSize;
    private int maxPoolSize;
    private long maxWaitTime;
    
    private DatabaseConnectionPool() {
        loadConfiguration();
        initializePool();
    }
    
    /**
     * Singleton pattern with thread-safe lazy initialization
     */
    public static synchronized DatabaseConnectionPool getInstance() {
        if (instance == null) {
            instance = new DatabaseConnectionPool();
        }
        return instance;
    }
    
    /**
     * Load database configuration from properties file
     */
    private void loadConfiguration() {
        Properties props = new Properties();
        try (InputStream input = getClass().getClassLoader()
                .getResourceAsStream("db.properties")) {
            if (input == null) {
                System.out.println("Unable to find db.properties");
                setDefaultConfiguration();
                return;
            }
            props.load(input);
            
            this.url = props.getProperty("db.url");
            this.username = props.getProperty("db.username");
            this.password = props.getProperty("db.password");
            this.driver = props.getProperty("db.driver");
            this.initialPoolSize = Integer.parseInt(
                props.getProperty("db.pool.initialSize", "5"));
            this.maxPoolSize = Integer.parseInt(
                props.getProperty("db.pool.maxTotal", "20"));
            this.maxWaitTime = Long.parseLong(
                props.getProperty("db.pool.maxWaitMillis", "10000"));
            
        } catch (IOException ex) {
            System.err.println("Error loading database configuration: " + ex.getMessage());
            setDefaultConfiguration();
        }
    }
    
    /**
     * Set default configuration if properties file is not found
     */
    private void setDefaultConfiguration() {
        this.url = "jdbc:mysql://localhost:3306/assignment_portal";
        this.username = "root";
        this.password = "root";
        this.driver = "com.mysql.cj.jdbc.Driver";
        this.initialPoolSize = 5;
        this.maxPoolSize = 20;
        this.maxWaitTime = 10000;
    }
    
    /**
     * Initialize connection pool with initial connections
     */
    private void initializePool() {
        try {
            Class.forName(driver);
            connectionPool = new ArrayBlockingQueue<>(maxPoolSize);
            usedConnections = new ArrayBlockingQueue<>(maxPoolSize);
            
            // Create initial connections
            for (int i = 0; i < initialPoolSize; i++) {
                connectionPool.add(createConnection());
            }
            
            System.out.println("Database connection pool initialized with " 
                + initialPoolSize + " connections");
            
        } catch (ClassNotFoundException e) {
            System.err.println("Database driver not found: " + e.getMessage());
            throw new RuntimeException("Failed to load database driver", e);
        }
    }
    
    /**
     * Create a new database connection
     */
    private Connection createConnection() {
        try {
            // Set login timeout
            DriverManager.setLoginTimeout(30);
            
            // Use Properties for better PostgreSQL connection handling
            Properties props = new Properties();
            props.setProperty("user", username);
            props.setProperty("password", password);
            props.setProperty("sslmode", "require");
            
            Connection conn = DriverManager.getConnection(url, props);
            System.out.println("New database connection created");
            return conn;
        } catch (SQLException e) {
            System.err.println("Error creating connection: " + e.getMessage());
            System.err.println("SQL State: " + e.getSQLState());
            System.err.println("Error Code: " + e.getErrorCode());
            e.printStackTrace();
            throw new RuntimeException("Failed to create database connection", e);
        }
    }
    
    /**
     * Get a connection from the pool (Thread-safe)
     * Blocks if no connection is available until timeout
     */
    public Connection getConnection() throws SQLException {
        try {
            Connection connection = connectionPool.poll(maxWaitTime, TimeUnit.MILLISECONDS);
            
            if (connection == null) {
                // If pool is not at max capacity, create new connection
                if (usedConnections.size() < maxPoolSize) {
                    connection = createConnection();
                } else {
                    throw new SQLException("Connection pool timeout - no available connections");
                }
            }
            
            // Verify connection is valid
            if (connection != null && connection.isClosed()) {
                connection = createConnection();
            }
            
            usedConnections.add(connection);
            System.out.println("Connection obtained from pool. Available: " 
                + connectionPool.size() + ", Used: " + usedConnections.size());
            
            return connection;
            
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new SQLException("Interrupted while waiting for connection", e);
        }
    }
    
    /**
     * Release a connection back to the pool (Thread-safe)
     */
    public boolean releaseConnection(Connection connection) {
        if (connection == null) {
            return false;
        }
        
        try {
            if (usedConnections.remove(connection)) {
                connectionPool.add(connection);
                System.out.println("Connection released back to pool. Available: " 
                    + connectionPool.size() + ", Used: " + usedConnections.size());
                return true;
            }
            return false;
        } catch (Exception e) {
            System.err.println("Error releasing connection: " + e.getMessage());
            return false;
        }
    }
    
    /**
     * Get current pool size
     */
    public int getPoolSize() {
        return connectionPool.size() + usedConnections.size();
    }
    
    /**
     * Get available connections count
     */
    public int getAvailableConnections() {
        return connectionPool.size();
    }
    
    /**
     * Get used connections count
     */
    public int getUsedConnections() {
        return usedConnections.size();
    }
    
    /**
     * Shutdown the connection pool
     */
    public void shutdown() {
        try {
            // Close all connections in pool
            for (Connection conn : connectionPool) {
                if (conn != null && !conn.isClosed()) {
                    conn.close();
                }
            }
            
            // Close all used connections
            for (Connection conn : usedConnections) {
                if (conn != null && !conn.isClosed()) {
                    conn.close();
                }
            }
            
            connectionPool.clear();
            usedConnections.clear();
            
            System.out.println("Database connection pool shutdown successfully");
            
        } catch (SQLException e) {
            System.err.println("Error shutting down connection pool: " + e.getMessage());
        }
    }
}
