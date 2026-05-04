package com.nex.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * DBConnection provides the central database connectivity for the application.
 * It uses the MySQL JDBC driver to connect to the 'auth_db' database.
 */
public class DBConnection {
    // Database URL, credentials and driver configuration
    private static final String DB_NAME = "nexus";
    private static final String URL = "jdbc:mysql://localhost:3306/" + DB_NAME;
    private static final String USERNAME = "root";  // XAMPP default username
    private static final String PASSWORD = "";      // XAMPP default password is empty

    static {
        try {
            // Registering the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    /**
     * Establishes and returns a database connection.
     */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USERNAME, PASSWORD);
    }
}
