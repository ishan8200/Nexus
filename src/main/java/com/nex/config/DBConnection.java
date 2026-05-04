package com.nex.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * DBConnection provides the central database connectivity for the application.
 * It uses the MySQL JDBC driver to connect to the 'nexus' database.
 */
public class DBConnection {
    // Database URL, credentials and driver configuration
    private static final String DB_NAME = "nexus";
    private static final String URL = "jdbc:mysql://localhost:3306/" + DB_NAME + "?useSSL=false&serverTimezone=UTC";
    private static final String USERNAME = "root";
    private static final String PASSWORD = "";

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("MySQL JDBC Driver registered successfully!");
        } catch (ClassNotFoundException e) {
            System.err.println("MySQL JDBC Driver not found!");
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        try {
            Connection conn = DriverManager.getConnection(URL, USERNAME, PASSWORD);
            System.out.println("Database connection established successfully!");
            return conn;
        } catch (SQLException e) {
            System.err.println("Failed to connect to database!");
            e.printStackTrace();
            throw e;
        }
    }
    
    // Test connection method
    public static void testConnection() {
        try (Connection conn = getConnection()) {
            System.out.println("Connection test successful!");
        } catch (SQLException e) {
            System.err.println("Connection test failed!");
            e.printStackTrace();
        }
    }
}