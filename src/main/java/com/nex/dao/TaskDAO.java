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
    
   public boolean processSubmissionApproval(int assignmentId, int reviewedBy, int rating, String comment) {
    String sql = "{CALL ApproveTaskWork(?, ?, ?)}";
    try (Connection conn = DBConnection.getConnection();
         CallableStatement cstmt = conn.prepareCall(sql)) {
        cstmt.setInt(1, assignmentId);
        cstmt.setInt(2, rating);
        cstmt.setString(3, comment);
        
        // Execute and check if successful
        boolean hasResult = cstmt.execute();
        // The stored procedure returns a result set with success field
        if (hasResult) {
            ResultSet rs = cstmt.getResultSet();
            if (rs.next()) {
                return rs.getInt("success") == 1;
            }
        }
        return true; // If no result set, assume success if no exception
    } catch (SQLException e) {
        e.printStackTrace();
        return false;
    }
}
    public boolean approveSubmission(int assignmentId, int reviewedBy, int rating, String comment) {
        return processSubmissionApproval(assignmentId, reviewedBy, rating, comment);
    }
    
    public boolean rejectSubmission(int assignmentId, int reviewedBy, String comment) {
        String sql = "UPDATE task_assignments SET status = 'rejected', admin_feedback = ?, completed_at = NOW() WHERE id = ? AND status = 'submitted'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, comment);
            pstmt.setInt(2, assignmentId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public int getPendingSubmissionCount() {
        String sql = "SELECT COUNT(*) FROM task_assignments WHERE status = 'submitted'";
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
        String sql = "SELECT ta.id, ta.task_id, ta.worker_id, ta.submission_text, ta.attachment_path, ta.submitted_at, " +
                     "u.full_name as worker_name, t.title as task_title " +
                     "FROM task_assignments ta " +
                     "JOIN users u ON ta.worker_id = u.id " +
                     "JOIN tasks t ON ta.task_id = t.id " +
                     "WHERE ta.status = 'submitted' " +
                     "ORDER BY ta.submitted_at DESC";
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
        String sql = "SELECT t.* FROM tasks t " +
                     "WHERE t.status = 'open' AND t.assigned_to IS NULL " +
                     "AND NOT EXISTS (SELECT 1 FROM task_assignments ta WHERE ta.task_id = t.id AND ta.status NOT IN ('cancelled', 'rejected')) " +
                     "ORDER BY t.deadline ASC";
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
        String sql = "{CALL AssignTaskToWorker(?, ?)}";
        try (Connection conn = DBConnection.getConnection();
             CallableStatement cstmt = conn.prepareCall(sql)) {
            cstmt.setInt(1, taskId);
            cstmt.setInt(2, workerId);
            ResultSet rs = cstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("success") == 1;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Map<String, Object>> getWorkerTasks(int workerId) {
        List<Map<String, Object>> tasks = new ArrayList<>();
        String sql = "SELECT ta.id as assignment_id, ta.status as assignment_status, t.* " +
                     "FROM task_assignments ta " +
                     "JOIN tasks t ON ta.task_id = t.id " +
                     "WHERE ta.worker_id = ? AND ta.status NOT IN ('approved', 'cancelled') " +
                     "ORDER BY t.deadline ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, workerId);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> task = new HashMap<>();
                task.put("assignment_id", rs.getInt("assignment_id"));
                task.put("id", rs.getInt("id"));
                task.put("title", rs.getString("title"));
                task.put("description", rs.getString("description"));
                task.put("wage", rs.getDouble("wage"));
                task.put("deadline", rs.getDate("deadline"));
                task.put("status", rs.getString("status"));
                task.put("assignment_status", rs.getString("assignment_status"));
                tasks.add(task);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return tasks;
    }

    public boolean startTask(int assignmentId) {
        String sql = "UPDATE task_assignments SET status = 'in_progress' WHERE id = ? AND status = 'accepted'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, assignmentId);
            int updated = pstmt.executeUpdate();
            if (updated > 0 || isAlreadyInProgress(assignmentId)) {
                // Also update the parent task status
                String updateTaskSql = "UPDATE tasks t JOIN task_assignments ta ON t.id = ta.task_id SET t.status = 'in-progress' WHERE ta.id = ?";
                try (PreparedStatement pstmt2 = conn.prepareStatement(updateTaskSql)) {
                    pstmt2.setInt(1, assignmentId);
                    pstmt2.executeUpdate();
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private boolean isAlreadyInProgress(int assignmentId) {
        String sql = "SELECT 1 FROM task_assignments WHERE id = ? AND status = 'in_progress'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, assignmentId);
            ResultSet rs = pstmt.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            return false;
        }
    }
    public boolean submitTaskWork(int assignmentId, String submissionText, String attachmentPath, double hoursWorked) {
        String sql = "{CALL SubmitTaskWork(?, ?, ?, ?)}";
        try (Connection conn = DBConnection.getConnection();
             CallableStatement cstmt = conn.prepareCall(sql)) {
            cstmt.setInt(1, assignmentId);
            cstmt.setString(2, submissionText);
            cstmt.setString(3, attachmentPath);
            cstmt.setDouble(4, hoursWorked);
            ResultSet rs = cstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("success") == 1;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
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

    public List<Map<String, Object>> getTasksByCategory() {
        List<Map<String, Object>> categories = new ArrayList<>();
        String sql = "SELECT category, COUNT(*) as count FROM tasks GROUP BY category";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> cat = new HashMap<>();
                cat.put("category", rs.getString("category") != null ? rs.getString("category") : "Uncategorized");
                cat.put("count", rs.getInt("count"));
                categories.add(cat);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return categories;
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