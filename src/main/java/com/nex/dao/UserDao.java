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
                    User user = extractUserFromResultSet(rs);
                    // Populate skillList
                    com.nex.dao.SkillDAO skillDAO = new com.nex.dao.SkillDAO();
                    user.setSkillList(skillDAO.getWorkerSkills(user.getId()));
                    return user;
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
                User user = extractUserFromResultSet(rs);
                // Populate skillList using SkillDAO
                com.nex.dao.SkillDAO skillDAO = new com.nex.dao.SkillDAO();
                user.setSkillList(skillDAO.getWorkerSkills(id));
                return user;
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
    
    public List<User> getAllWorkersWithStats() {
        List<User> workers = new ArrayList<>();
        String sql = "SELECT u.*, v.assigned_tasks, v.submissions_made, v.avg_rating " +
                     "FROM users u " +
                     "JOIN worker_performance_view v ON u.id = v.worker_id " +
                     "WHERE u.role = 'worker' " +
                     "ORDER BY u.full_name ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            com.nex.dao.SkillDAO skillDAO = new com.nex.dao.SkillDAO();
            while (rs.next()) {
                User worker = extractUserFromResultSet(rs);
                worker.setAssignedTasks(rs.getInt("assigned_tasks"));
                worker.setSubmissionsMade(rs.getInt("submissions_made"));
                worker.setAvgRating(rs.getDouble("avg_rating"));
                // Populate skillList
                worker.setSkillList(skillDAO.getWorkerSkills(worker.getId()));
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
    
    public List<User> getPendingWorkersList() {
        List<User> workers = new ArrayList<>();
        String sql = "SELECT * FROM users WHERE role = 'worker' AND status = 'pending' ORDER BY created_at DESC";
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
    
    public boolean deleteUser(int userId) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Delete from wages where worker_id = ?
            String deleteWagesSql = "DELETE FROM wages WHERE worker_id = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(deleteWagesSql)) {
                pstmt.setInt(1, userId);
                pstmt.executeUpdate();
            }

            // 2. Delete from task_submissions where worker_id = ?
            String deleteSubmissionsSql = "DELETE FROM task_submissions WHERE worker_id = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(deleteSubmissionsSql)) {
                pstmt.setInt(1, userId);
                pstmt.executeUpdate();
            }

            // 3. Delete from payment_history where worker_id = ?
            String deletePaymentHistorySql = "DELETE FROM payment_history WHERE worker_id = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(deletePaymentHistorySql)) {
                pstmt.setInt(1, userId);
                pstmt.executeUpdate();
            }

            // 4. Finally delete the user
            String deleteUserSql = "DELETE FROM users WHERE id = ?";
            int rowsDeleted = 0;
            try (PreparedStatement pstmt = conn.prepareStatement(deleteUserSql)) {
                pstmt.setInt(1, userId);
                rowsDeleted = pstmt.executeUpdate();
            }

            conn.commit();
            return rowsDeleted > 0;
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
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
        String sql = "SELECT " +
                     "(SELECT COALESCE(SUM(amount), 0) FROM wages WHERE worker_id = ?) AS total_earned, " +
                     "(SELECT COUNT(*) FROM tasks WHERE assigned_to = ? AND status = 'completed') AS tasks_completed, " +
                     "(SELECT COUNT(*) FROM tasks WHERE assigned_to = ?) AS assigned_tasks, " +
                     "(SELECT COALESCE(AVG(rating), 0) FROM task_submissions WHERE worker_id = ? AND status = 'approved') AS avg_rating, " +
                     "(SELECT COALESCE(SUM(amount), 0) FROM wages WHERE worker_id = ? AND status = 'pending') AS pending_payment, " +
                     "(SELECT COUNT(*) FROM task_submissions ts JOIN tasks t ON ts.task_id = t.id " +
                     "WHERE ts.worker_id = ? AND ts.submitted_at > t.deadline) AS late_submissions";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            for (int i = 1; i <= 6; i++) {
                pstmt.setInt(i, workerId);
            }
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                stats.put("total_earned", rs.getDouble("total_earned"));
                stats.put("tasks_completed", rs.getInt("tasks_completed"));
                stats.put("assigned_tasks", rs.getInt("assigned_tasks"));
                stats.put("avg_rating", rs.getDouble("avg_rating"));
                stats.put("pending_payment", rs.getDouble("pending_payment"));
                stats.put("late_submissions", rs.getInt("late_submissions"));
                
                int assigned = rs.getInt("assigned_tasks");
                int completed = rs.getInt("tasks_completed");
                double rate = (assigned > 0) ? (double) completed / assigned * 100 : 0;
                stats.put("completion_rate", rate);
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
    
    public boolean updateUserRating(int userId, double rating) {
        String sql = "UPDATE users SET rating = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setDouble(1, rating);
            pstmt.setInt(2, userId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
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