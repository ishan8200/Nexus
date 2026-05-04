package com.nex.dao;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.mindrot.jbcrypt.BCrypt;
import com.nex.config.DBConnection;
import com.nex.model.User;

/**
 * UserDAO handles all database operations for the User model.
 * Includes methods for authentication, user management, and worker statistics.
 */

public class UserDAO {
    
    // ==================== USER REGISTRATION & AUTHENTICATION ====================
    
    public boolean registerUser(User user) {
        String sql = "INSERT INTO users (username, email, password, full_name, phone, role, status) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, user.getUsername());
            pstmt.setString(2, user.getEmail());
            // Hash password using BCrypt
            pstmt.setString(3, BCrypt.hashpw(user.getPassword(), BCrypt.gensalt()));
            pstmt.setString(4, user.getFullName());
            pstmt.setString(5, user.getPhone());
            pstmt.setString(6, user.getRole());
            pstmt.setString(7, user.getStatus() != null ? user.getStatus() : "pending");
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Validate user credentials for login using EMAIL
     */
    public User loginUser(String email, String password) {
        String sql = "SELECT * FROM users WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, email);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                // Use BCrypt to verify password
                if (BCrypt.checkpw(password, rs.getString("password"))) {
                    return extractUserFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    public boolean isUsernameExists(String username) {
        String sql = "SELECT id FROM users WHERE username = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, username);
            ResultSet rs = pstmt.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean isEmailExists(String email) {
        String sql = "SELECT id FROM users WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, email);
            ResultSet rs = pstmt.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public void updateLastLogin(int userId) {
        String sql = "UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    
    
 
    
    // ==================== USER MANAGEMENT ====================
    
    public User getUserById(int id) {
        String sql = "SELECT * FROM users WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return extractUserFromResultSet(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    public List<User> getAllWorkers() {
        List<User> workers = new ArrayList<>();
        String sql = "SELECT * FROM users WHERE role = 'worker' ORDER BY created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                workers.add(extractUserFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return workers;
    }
    
    public List<Map<String, Object>> getAllWorkersWithStats() {
        List<Map<String, Object>> workers = new ArrayList<>();
        String sql = "SELECT u.*, COUNT(DISTINCT t.id) as tasks_completed_count " +
                     "FROM users u " +
                     "LEFT JOIN tasks t ON t.assigned_to = u.id AND t.status = 'completed' " +
                     "WHERE u.role = 'worker' " +
                     "GROUP BY u.id ORDER BY u.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> worker = new HashMap<>();
                worker.put("id", rs.getInt("id"));
                worker.put("username", rs.getString("username"));
                worker.put("email", rs.getString("email"));
                worker.put("full_name", rs.getString("full_name"));
                worker.put("phone", rs.getString("phone"));
                worker.put("role", rs.getString("role"));
                worker.put("status", rs.getString("status"));
                worker.put("skills", rs.getString("skills"));
                worker.put("rating", rs.getDouble("rating"));
                worker.put("total_earned", rs.getDouble("total_earned"));
                worker.put("tasks_completed", rs.getInt("tasks_completed_count"));
                worker.put("created_at", rs.getTimestamp("created_at"));
                workers.add(worker);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return workers;
    }
    
    public int getActiveWorkerCount() {
        String sql = "SELECT COUNT(*) FROM users WHERE role = 'worker' AND status = 'approved'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    public int getPendingWorkerCount() {
        String sql = "SELECT COUNT(*) FROM users WHERE role = 'worker' AND status = 'pending'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    public List<Map<String, Object>> getPendingWorkersList() {
        List<Map<String, Object>> workers = new ArrayList<>();
        String sql = "SELECT id, full_name, email, phone, skills, created_at FROM users WHERE role = 'worker' AND status = 'pending' ORDER BY created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> worker = new HashMap<>();
                worker.put("id", rs.getInt("id"));
                worker.put("full_name", rs.getString("full_name"));
                worker.put("email", rs.getString("email"));
                worker.put("phone", rs.getString("phone"));
                worker.put("skills", rs.getString("skills"));
                worker.put("created_at", rs.getTimestamp("created_at"));
                workers.add(worker);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return workers;
    }
    
    public boolean updateWorkerStatus(int userId, String status) {
        String sql = "UPDATE users SET status = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, status);
            pstmt.setInt(2, userId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean updateUserProfile(User user) {
        String sql = "UPDATE users SET full_name = ?, phone = ?, skills = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, user.getFullName());
            pstmt.setString(2, user.getPhone());
            pstmt.setString(3, user.getSkills());
            pstmt.setInt(4, user.getId());
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean changePassword(int userId, String newPassword) {
        String sql = "UPDATE users SET password = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            // Hash new password using BCrypt
            pstmt.setString(1, BCrypt.hashpw(newPassword, BCrypt.gensalt()));
            pstmt.setInt(2, userId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // ==================== WORKER STATISTICS ====================
    
    public Map<String, Object> getWorkerStats(int workerId) {
        Map<String, Object> stats = new HashMap<>();
        String sql = "{CALL GetWorkerStats(?)}";
        try (Connection conn = DBConnection.getConnection();
             CallableStatement cstmt = conn.prepareCall(sql)) {
            cstmt.setInt(1, workerId);
            ResultSet rs = cstmt.executeQuery();
            if (rs.next()) {
                stats.put("total_earned", rs.getDouble("total_earned"));
                stats.put("tasks_completed", rs.getInt("tasks_completed"));
                stats.put("avg_rating", rs.getDouble("avg_rating"));
                stats.put("pending_payment", rs.getDouble("pending_payment"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return stats;
    }
    
    public List<Map<String, Object>> getWorkerEarnings(int workerId) {
        List<Map<String, Object>> earnings = new ArrayList<>();
        String sql = "{CALL GetWorkerEarnings(?)}";
        try (Connection conn = DBConnection.getConnection();
             CallableStatement cstmt = conn.prepareCall(sql)) {
            cstmt.setInt(1, workerId);
            ResultSet rs = cstmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> earning = new HashMap<>();
                earning.put("month", rs.getString("month"));
                earning.put("task_count", rs.getInt("task_count"));
                earning.put("total_amount", rs.getDouble("total_amount"));
                earnings.add(earning);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return earnings;
    }
    
    public List<Map<String, Object>> getMyTasks(int workerId) {
        List<Map<String, Object>> tasks = new ArrayList<>();
        String sql = "SELECT t.*, ts.status as submission_status " +
                     "FROM tasks t " +
                     "LEFT JOIN task_submissions ts ON ts.task_id = t.id AND ts.worker_id = ? " +
                     "WHERE t.assigned_to = ? OR (t.status = 'open' AND ts.id IS NULL) " +
                     "ORDER BY t.deadline ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, workerId);
            pstmt.setInt(2, workerId);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> task = new HashMap<>();
                task.put("id", rs.getInt("id"));
                task.put("title", rs.getString("title"));
                task.put("description", rs.getString("description"));
                task.put("wage", rs.getDouble("wage"));
                task.put("wage_type", rs.getString("wage_type"));
                task.put("deadline", rs.getDate("deadline"));
                task.put("priority", rs.getString("priority"));
                task.put("status", rs.getString("status"));
                task.put("submission_status", rs.getString("submission_status"));
                tasks.add(task);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return tasks;
    }
    
    // ==================== HELPER METHODS ====================
    
    private User extractUserFromResultSet(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("id"));
        user.setUsername(rs.getString("username"));
        user.setEmail(rs.getString("email"));
        user.setPassword(rs.getString("password"));
        user.setFullName(rs.getString("full_name"));
        user.setPhone(rs.getString("phone"));
        user.setRole(rs.getString("role"));
        user.setStatus(rs.getString("status"));
        user.setProfilePic(rs.getString("profile_pic"));
        user.setSkills(rs.getString("skills"));
        user.setRating(rs.getDouble("rating"));
        user.setTotalEarned(rs.getDouble("total_earned"));
        user.setTasksCompleted(rs.getInt("tasks_completed"));
        user.setCreatedAt(rs.getTimestamp("created_at"));
        user.setLastLogin(rs.getTimestamp("last_login"));
        return user;
    }
}