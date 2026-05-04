package com.nex.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.nex.config.DBConnection;
import com.nex.model.Wage;

public class WageDAO {
    
    // ==================== WAGE MANAGEMENT ====================
    
    public boolean createWage(int workerId, int taskId, double amount) {
        String sql = "INSERT INTO wages (worker_id, task_id, amount, status) VALUES (?, ?, ?, 'pending')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, workerId);
            pstmt.setInt(2, taskId);
            pstmt.setDouble(3, amount);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean createWageWithSubmission(int workerId, int taskId, int submissionId, double amount) {
        String sql = "INSERT INTO wages (worker_id, task_id, submission_id, amount, status) VALUES (?, ?, ?, ?, 'pending')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, workerId);
            pstmt.setInt(2, taskId);
            pstmt.setInt(3, submissionId);
            pstmt.setDouble(4, amount);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean markAsPaid(int wageId, int paidBy, String transactionId, String paymentMethod) {
        String sql = "UPDATE wages SET status = 'paid', paid_at = NOW(), paid_by = ?, transaction_id = ?, payment_method = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, paidBy);
            pstmt.setString(2, transactionId);
            pstmt.setString(3, paymentMethod);
            pstmt.setInt(4, wageId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean markWorkerWagesAsPaid(int workerId, int paidBy, String transactionId) {
        String sql = "UPDATE wages SET status = 'paid', paid_at = NOW(), paid_by = ?, transaction_id = ? WHERE worker_id = ? AND status = 'pending'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, paidBy);
            pstmt.setString(2, transactionId);
            pstmt.setInt(3, workerId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public double getTotalWagesDisbursed() {
        String sql = "SELECT COALESCE(SUM(amount), 0) FROM wages WHERE status = 'paid'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) return rs.getDouble(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    public double getPendingWagesTotal() {
        String sql = "SELECT COALESCE(SUM(amount), 0) FROM wages WHERE status = 'pending'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) return rs.getDouble(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    public List<Map<String, Object>> getWageSummary() {
        List<Map<String, Object>> summary = new ArrayList<>();
        String sql = "SELECT u.id as worker_id, u.full_name, u.tasks_completed, u.total_earned, " +
                     "CASE WHEN EXISTS(SELECT 1 FROM wages w WHERE w.worker_id = u.id AND w.status = 'pending') " +
                     "THEN 'pending' ELSE 'paid' END as payment_status " +
                     "FROM users u WHERE u.role = 'worker' ORDER BY u.total_earned DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> wage = new HashMap<>();
                wage.put("worker_id", rs.getInt("worker_id"));
                wage.put("full_name", rs.getString("full_name"));
                wage.put("tasks_completed", rs.getInt("tasks_completed"));
                wage.put("total_earned", rs.getDouble("total_earned"));
                wage.put("payment_status", rs.getString("payment_status"));
                summary.add(wage);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return summary;
    }
    
    public List<Wage> getWagesByWorker(int workerId) {
        List<Wage> wages = new ArrayList<>();
        String sql = "SELECT w.*, t.title as task_title FROM wages w JOIN tasks t ON w.task_id = t.id WHERE w.worker_id = ? ORDER BY w.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, workerId);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                Wage wage = extractWageFromResultSet(rs);
                wage.setTaskTitle(rs.getString("task_title"));
                wages.add(wage);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return wages;
    }
    
    public List<Wage> getAllWages() {
        List<Wage> wages = new ArrayList<>();
        String sql = "SELECT w.*, u.full_name as worker_name, t.title as task_title FROM wages w " +
                     "JOIN users u ON w.worker_id = u.id " +
                     "JOIN tasks t ON w.task_id = t.id " +
                     "ORDER BY w.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                Wage wage = extractWageFromResultSet(rs);
                wage.setWorkerName(rs.getString("worker_name"));
                wage.setTaskTitle(rs.getString("task_title"));
                wages.add(wage);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return wages;
    }
    
    public boolean updateWorkerTotalEarned(int workerId) {
        String sql = "UPDATE users u SET u.total_earned = (SELECT COALESCE(SUM(amount), 0) FROM wages WHERE worker_id = u.id AND status = 'paid') WHERE u.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, workerId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // ==================== PAYMENT HISTORY ====================
    
    public boolean addPaymentHistory(int workerId, double amount, String paymentMethod, String transactionId, String description) {
        String sql = "INSERT INTO payment_history (worker_id, amount, payment_date, payment_method, transaction_id, description, status) VALUES (?, ?, CURDATE(), ?, ?, ?, 'completed')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, workerId);
            pstmt.setDouble(2, amount);
            pstmt.setString(3, paymentMethod);
            pstmt.setString(4, transactionId);
            pstmt.setString(5, description);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public List<Map<String, Object>> getPaymentHistory(int workerId) {
        List<Map<String, Object>> history = new ArrayList<>();
        String sql = "SELECT * FROM payment_history WHERE worker_id = ? ORDER BY payment_date DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, workerId);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> payment = new HashMap<>();
                payment.put("id", rs.getInt("id"));
                payment.put("amount", rs.getDouble("amount"));
                payment.put("payment_date", rs.getDate("payment_date"));
                payment.put("payment_method", rs.getString("payment_method"));
                payment.put("transaction_id", rs.getString("transaction_id"));
                payment.put("description", rs.getString("description"));
                payment.put("status", rs.getString("status"));
                history.add(payment);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return history;
    }
    
    // ==================== HELPER METHODS ====================
    
    private Wage extractWageFromResultSet(ResultSet rs) throws SQLException {
        Wage wage = new Wage();
        wage.setId(rs.getInt("id"));
        wage.setWorkerId(rs.getInt("worker_id"));
        wage.setTaskId(rs.getInt("task_id"));
        wage.setSubmissionId(rs.getInt("submission_id"));
        wage.setAmount(rs.getDouble("amount"));
        wage.setStatus(rs.getString("status"));
        wage.setPaidAt(rs.getTimestamp("paid_at"));
        wage.setPaidBy(rs.getInt("paid_by"));
        wage.setTransactionId(rs.getString("transaction_id"));
        wage.setPaymentMethod(rs.getString("payment_method"));
        wage.setNotes(rs.getString("notes"));
        wage.setCreatedAt(rs.getTimestamp("created_at"));
        return wage;
    }
}