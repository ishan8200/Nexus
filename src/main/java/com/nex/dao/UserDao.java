package com.nex.dao;

import com.nex.config.DBConfig;
import com.nex.model.User;
import org.mindrot.jbcrypt.BCrypt; // Standard BCrypt library
import java.sql.*;

/**
 * UserDao handles all database operations for the User model.
 * It includes methods for user registration and validation.
 */
public class UserDao {
    
    /**
     * Registers a new user into the database.
     * Uses BCrypt to hash the password before saving for security.
     */
    public boolean registerUser(User user) {
        String query = "INSERT INTO users (username, password, email, role, dateAdded) VALUES (?, ?, ?, ?, NOW())";
        // Hashing the password with a salt
        String hashedPassword = BCrypt.hashpw(user.getPassword(), BCrypt.gensalt());
        
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {
            
            pstmt.setString(1, user.getUsername());
            pstmt.setString(2, hashedPassword); // Store the hashed password
            pstmt.setString(3, user.getEmail());
            pstmt.setString(4, user.getRole());
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error during registration: " + e.getMessage());
            return false;
        }
    }

    /**
     * Validates a user's credentials against the database.
     * Fetches the user by username and compares the provided password with the stored hash.
     */
    public User validateUser(String username, String password) {
        String query = "SELECT id, username, password FROM users WHERE username = ?";
        
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {
            
            pstmt.setString(1, username);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                String storedHash = rs.getString("password");
                // Use BCrypt to check if the password matches the hash
                if (BCrypt.checkpw(password, storedHash)) {
                    User user = new User();
                    user.setId(rs.getInt("id"));
                    user.setUsername(rs.getString("username"));
                    user.setEmail(rs.getString("email"));
                    //user.setRole(rs.getString("role"));
                    return user;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error during validation: " + e.getMessage());
        }
        return null; // Return null if user not found or password incorrect
    }
}
