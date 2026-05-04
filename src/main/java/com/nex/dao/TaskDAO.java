package com.nex.dao;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.google.gson.Gson;
import com.nex.config.DBConnection;
import com.nex.model.Task;

public class TaskDAO {
    
    private Gson gson = new Gson();
    
    // ==================== TASK CRUD OPERATIONS ====================
    
    public boolean createTask(Task task) {
        String sql = "INSERT INTO tasks (title, description, wage, wage_type, deadline, priority, recurrence, category, estimated_hours, created_by, assigned_to) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            pstmt.setString(1, task.getTitle());
            pstmt.setString(2, task.getDescription());
            pstmt.setDouble(3, task.getWage());
            pstmt.setString(4, task.getWageType());
            pstmt.setDate(5, task.getDeadline());
            pstmt.setString(6, task.getPriority());
            pstmt.setString(7, task.getRecurrence());
            pstmt.setString(8, task.getCategory());
            pstmt.setInt(9, task.getEstimatedHours());
            pstmt.setInt(10, task.getCreatedBy());
            
            if (task.getAssignedTo() > 0) {
                pstmt.setInt(11, task.getAssignedTo());
            } else {
                pstmt.setNull(11, Types.INTEGER);
            }
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public Task getTaskById(int taskId) {
        String sql = "SELECT t.*, u.full_name as assigned_to_name FROM tasks t LEFT JOIN users u ON t.assigned_to = u.id WHERE t.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, taskId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return extractTaskFromResultSet(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    public List<Map<String, Object>> getAllTasks() {
        List<Map<String, Object>> tasks = new ArrayList<>();
        String sql = "SELECT t.*, u.full_name as assigned_to_name FROM tasks t LEFT JOIN users u ON t.assigned_to = u.id ORDER BY t.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> task = new HashMap<>();
                task.put("id", rs.getInt("id"));
                task.put("title", rs.getString("title"));
                task.put("description", rs.getString("description"));
                task.put("wage", rs.getDouble("wage"));
                task.put("wage_type", rs.getString("wage_type"));
                task.put("deadline", rs.getDate("deadline").toString());
                task.put("priority", rs.getString("priority"));
                task.put("status", rs.getString("status"));
                task.put("category", rs.getString("category"));
                task.put("assignedToName", rs.getString("assigned_to_name"));
                task.put("assigned_to", rs.getInt("assigned_to"));
                tasks.add(task);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return tasks;
    }
    
    public String getAllTasksAsJSON() {
        return gson.toJson(getAllTasks());
    }
    
    public List<Map<String, Object>> getRecentTasks(int limit) {
        List<Map<String, Object>> tasks = new ArrayList<>();
        String sql = "SELECT t.*, u.full_name as assigned_to_name FROM tasks t LEFT JOIN users u ON t.assigned_to = u.id ORDER BY t.created_at DESC LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, limit);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> task = new HashMap<>();
                task.put("id", rs.getInt("id"));
                task.put("title", rs.getString("title"));
                task.put("status", rs.getString("status"));
                task.put("deadline", rs.getDate("deadline"));
                task.put("assigned_to_name", rs.getString("assigned_to_name"));
                tasks.add(task);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return tasks;
    }
    
    public boolean updateTask(Task task) {
        String sql = "UPDATE tasks SET title=?, description=?, wage=?, wage_type=?, deadline=?, priority=?, category=?, estimated_hours=?, assigned_to=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, task.getTitle());
            pstmt.setString(2, task.getDescription());
            pstmt.setDouble(3, task.getWage());
            pstmt.setString(4, task.getWageType());
            pstmt.setDate(5, task.getDeadline());
            pstmt.setString(6, task.getPriority());
            pstmt.setString(7, task.getCategory());
            pstmt.setInt(8, task.getEstimatedHours());
            pstmt.setInt(9, task.getAssignedTo());
            pstmt.setInt(10, task.getId());
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean deleteTask(int taskId) {
        // We need to delete dependent records first to avoid foreign key violations
        String deleteWagesSql = "DELETE FROM wages WHERE task_id = ?";
        String deleteSubmissionsSql = "DELETE FROM task_submissions WHERE task_id = ?";
        String deleteTaskSql = "DELETE FROM tasks WHERE id = ?";
        
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Start transaction
            
            // 1. Delete associated wages
            try (PreparedStatement pstmt = conn.prepareStatement(deleteWagesSql)) {
                pstmt.setInt(1, taskId);
                pstmt.executeUpdate();
            }
            
            // 2. Delete associated submissions
            try (PreparedStatement pstmt = conn.prepareStatement(deleteSubmissionsSql)) {
                pstmt.setInt(1, taskId);
                pstmt.executeUpdate();
            }
            
            // 3. Delete the task
            int rowsDeleted = 0;
            try (PreparedStatement pstmt = conn.prepareStatement(deleteTaskSql)) {
                pstmt.setInt(1, taskId);
                rowsDeleted = pstmt.executeUpdate();
            }
            
            conn.commit(); // Commit transaction
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
    
    public boolean updateTaskStatus(int taskId, String status) {
        String sql = "UPDATE tasks SET status = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, status);
            pstmt.setInt(2, taskId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // ==================== TASK STATISTICS ====================
    
    public int getTotalTaskCount() {
        String sql = "SELECT COUNT(*) FROM tasks";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    public int getCompletedTaskCount() {
        String sql = "SELECT COUNT(*) FROM tasks WHERE status = 'completed'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    public int getOpenTaskCount() {
        String sql = "SELECT COUNT(*) FROM tasks WHERE status = 'open'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    public int getInProgressTaskCount() {
        String sql = "SELECT COUNT(*) FROM tasks WHERE status = 'in-progress'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    // ==================== TASK SUBMISSIONS ====================
    
    public boolean submitTask(int taskId, int workerId, String submissionText, String attachmentPath) {
        String sql = "INSERT INTO task_submissions (task_id, worker_id, submission_text, attachment_path, status) VALUES (?, ?, ?, ?, 'pending')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, taskId);
            pstmt.setInt(2, workerId);
            pstmt.setString(3, submissionText);
            pstmt.setString(4, attachmentPath);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean processSubmissionApproval(int submissionId, int reviewedBy, int rating, String comment) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Get submission details (task_id, worker_id, and the current wage for that task)
            int taskId = -1;
            int workerId = -1;
            double wage = 0;
            String getSubSql = "SELECT ts.task_id, ts.worker_id, t.wage FROM task_submissions ts JOIN tasks t ON ts.task_id = t.id WHERE ts.id = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(getSubSql)) {
                pstmt.setInt(1, submissionId);
                ResultSet rs = pstmt.executeQuery();
                if (rs.next()) {
                    taskId = rs.getInt("task_id");
                    workerId = rs.getInt("worker_id");
                    wage = rs.getDouble("wage");
                } else {
                    return false;
                }
            }

            // 2. Update submission status
            String updateSubSql = "UPDATE task_submissions SET status = 'approved', rating = ?, admin_comment = ?, reviewed_at = NOW(), reviewed_by = ? WHERE id = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(updateSubSql)) {
                pstmt.setInt(1, rating);
                pstmt.setString(2, comment);
                pstmt.setInt(3, reviewedBy);
                pstmt.setInt(4, submissionId);
                pstmt.executeUpdate();
            }

            // 3. Update task status to completed
            String updateTaskSql = "UPDATE tasks SET status = 'completed' WHERE id = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(updateTaskSql)) {
                pstmt.setInt(1, taskId);
                pstmt.executeUpdate();
            }

            // 4. Create wage record (credited to worker, but pending disbursement)
            String createWageSql = "INSERT INTO wages (worker_id, task_id, submission_id, amount, status) VALUES (?, ?, ?, ?, 'pending')";
            try (PreparedStatement pstmt = conn.prepareStatement(createWageSql)) {
                pstmt.setInt(1, workerId);
                pstmt.setInt(2, taskId);
                pstmt.setInt(3, submissionId);
                pstmt.setDouble(4, wage);
                pstmt.executeUpdate();
            }
            
            // 5. Update worker profile statistics
            String updateWorkerSql = "UPDATE users SET tasks_completed = tasks_completed + 1 WHERE id = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(updateWorkerSql)) {
                pstmt.setInt(1, workerId);
                pstmt.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }

    public boolean approveSubmission(int submissionId, int reviewedBy, int rating, String comment) {
        String sql = "UPDATE task_submissions SET status = 'approved', rating = ?, admin_comment = ?, reviewed_at = NOW(), reviewed_by = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, rating);
            pstmt.setString(2, comment);
            pstmt.setInt(3, reviewedBy);
            pstmt.setInt(4, submissionId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean rejectSubmission(int submissionId, int reviewedBy, String comment) {
        String sql = "UPDATE task_submissions SET status = 'rejected', admin_comment = ?, reviewed_at = NOW(), reviewed_by = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, comment);
            pstmt.setInt(2, reviewedBy);
            pstmt.setInt(3, submissionId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public int getPendingSubmissionCount() {
        String sql = "SELECT COUNT(*) FROM task_submissions WHERE status = 'pending'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    public List<Map<String, Object>> getPendingSubmissionsList() {
        List<Map<String, Object>> submissions = new ArrayList<>();
        String sql = "SELECT ts.*, u.full_name as worker_name, t.title as task_title " +
                     "FROM task_submissions ts " +
                     "JOIN users u ON ts.worker_id = u.id " +
                     "JOIN tasks t ON ts.task_id = t.id " +
                     "WHERE ts.status = 'pending' " +
                     "ORDER BY ts.submitted_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> submission = new HashMap<>();
                submission.put("id", rs.getInt("id"));
                submission.put("task_id", rs.getInt("task_id"));
                submission.put("task_title", rs.getString("task_title"));
                submission.put("worker_id", rs.getInt("worker_id"));
                submission.put("worker_name", rs.getString("worker_name"));
                submission.put("submission_text", rs.getString("submission_text"));
                submission.put("attachment_path", rs.getString("attachment_path"));
                submission.put("submitted_at", rs.getTimestamp("submitted_at"));
                submissions.add(submission);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return submissions;
    }
    
    public List<Map<String, Object>> getAvailableTasks() {
        List<Map<String, Object>> tasks = new ArrayList<>();
        String sql = "SELECT t.*, u.full_name as created_by_name FROM tasks t JOIN users u ON t.created_by = u.id WHERE t.status = 'open' ORDER BY t.deadline ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> task = new HashMap<>();
                task.put("id", rs.getInt("id"));
                task.put("title", rs.getString("title"));
                task.put("description", rs.getString("description"));
                task.put("wage", rs.getDouble("wage"));
                task.put("wage_type", rs.getString("wage_type"));
                task.put("deadline", rs.getDate("deadline"));
                task.put("priority", rs.getString("priority"));
                task.put("category", rs.getString("category"));
                task.put("estimated_hours", rs.getInt("estimated_hours"));
                tasks.add(task);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return tasks;
    }
    
    public boolean assignTaskToWorker(int taskId, int workerId) {
        String sql = "UPDATE tasks SET assigned_to = ?, status = 'in-progress' WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, workerId);
            pstmt.setInt(2, taskId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // ==================== ADMIN STATISTICS ====================
    
    public Map<String, Object> getAdminStats() {
        Map<String, Object> stats = new HashMap<>();
        String sql = "{CALL GetAdminStats()}";
        try (Connection conn = DBConnection.getConnection();
             CallableStatement cstmt = conn.prepareCall(sql);
             ResultSet rs = cstmt.executeQuery()) {
            if (rs.next()) {
                stats.put("total_tasks", rs.getInt("total_tasks"));
                stats.put("completed_tasks", rs.getInt("completed_tasks"));
                stats.put("active_workers", rs.getInt("active_workers"));
                stats.put("wages_disbursed", rs.getDouble("wages_disbursed"));
                stats.put("pending_workers", rs.getInt("pending_workers"));
                stats.put("pending_submissions", rs.getInt("pending_submissions"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return stats;
    }
    
    public List<Map<String, Object>> getTaskTrends() {
        List<Map<String, Object>> trends = new ArrayList<>();
        String sql = "{CALL GetTaskTrends()}";
        try (Connection conn = DBConnection.getConnection();
             CallableStatement cstmt = conn.prepareCall(sql);
             ResultSet rs = cstmt.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> trend = new HashMap<>();
                trend.put("date", rs.getString("date"));
                trend.put("completed", rs.getInt("completed"));
                trend.put("open", rs.getInt("open"));
                trend.put("in_progress", rs.getInt("in_progress"));
                trends.add(trend);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return trends;
    }
    
    // ==================== HELPER METHODS ====================
    
    private Task extractTaskFromResultSet(ResultSet rs) throws SQLException {
        Task task = new Task();
        task.setId(rs.getInt("id"));
        task.setTitle(rs.getString("title"));
        task.setDescription(rs.getString("description"));
        task.setWage(rs.getDouble("wage"));
        task.setWageType(rs.getString("wage_type"));
        task.setDeadline(rs.getDate("deadline"));
        task.setPriority(rs.getString("priority"));
        task.setRecurrence(rs.getString("recurrence"));
        task.setStatus(rs.getString("status"));
        task.setAssignedTo(rs.getInt("assigned_to"));
        task.setCreatedBy(rs.getInt("created_by"));
        task.setCategory(rs.getString("category"));
        task.setEstimatedHours(rs.getInt("estimated_hours"));
        task.setCreatedAt(rs.getTimestamp("created_at"));
        task.setAssignedToName(rs.getString("assigned_to_name"));
        return task;
    }

    // Get worker's ratings
public List<Map<String, Object>> getWorkerRatings(int workerId) {
    List<Map<String, Object>> ratings = new ArrayList<>();
    String sql = "SELECT ts.rating, ts.reviewed_at, t.title as task_title " +
                 "FROM task_submissions ts " +
                 "JOIN tasks t ON ts.task_id = t.id " +
                 "WHERE ts.worker_id = ? AND ts.status = 'approved' AND ts.rating IS NOT NULL " +
                 "ORDER BY ts.reviewed_at DESC LIMIT 10";
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {
        pstmt.setInt(1, workerId);
        ResultSet rs = pstmt.executeQuery();
        while (rs.next()) {
            Map<String, Object> rating = new HashMap<>();
            rating.put("rating", rs.getInt("rating"));
            rating.put("reviewed_at", rs.getTimestamp("reviewed_at"));
            rating.put("task_title", rs.getString("task_title"));
            ratings.add(rating);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return ratings;
    }

    public List<Map<String, Object>> getCompletedTasksWithRatings(int workerId) {
    List<Map<String, Object>> performance = new ArrayList<>();
    String sql = "SELECT t.title, t.wage, t.status as task_status, ts.rating, ts.rating_comment, ts.reviewed_at " +
                 "FROM tasks t " +
                 "JOIN task_submissions ts ON t.id = ts.task_id " +
                 "WHERE ts.worker_id = ? AND t.status = 'completed' AND ts.status = 'approved' " +
                 "ORDER BY ts.reviewed_at DESC";
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {
        pstmt.setInt(1, workerId);
        ResultSet rs = pstmt.executeQuery();
        while (rs.next()) {
            Map<String, Object> record = new HashMap<>();
            record.put("title", rs.getString("title"));
            record.put("wage", rs.getDouble("wage"));
            record.put("rating", rs.getInt("rating"));
            record.put("comment", rs.getString("rating_comment"));
            record.put("date", rs.getTimestamp("reviewed_at"));
            performance.add(record);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return performance;
    }
    }