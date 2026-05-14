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
    
    public List<Map<String, Object>> getAllTasks(int adminId, String sortBy, String sortDir, String search) {
        List<Map<String, Object>> tasks = new ArrayList<>();
        
        // Define allowed sort columns for security
        Map<String, String> allowedCols = new HashMap<>();
        allowedCols.put("title", "t.title");
        allowedCols.put("priority", "t.priority");
        allowedCols.put("status", "t.status");
        allowedCols.put("wage", "t.wage");
        allowedCols.put("deadline", "t.deadline");
        
        String orderBy = allowedCols.getOrDefault(sortBy, "t.created_at");
        String dir = "DESC".equalsIgnoreCase(sortDir) ? "DESC" : "ASC";
        
        StringBuilder sql = new StringBuilder("SELECT t.*, u.full_name as assigned_to_name FROM tasks t LEFT JOIN users u ON t.assigned_to = u.id WHERE t.created_by = ?");
        
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (t.title LIKE ? OR t.priority LIKE ? OR t.status LIKE ? OR t.category LIKE ? OR u.full_name LIKE ?)");
        }
        
        sql.append(" ORDER BY ").append(orderBy).append(" ").append(dir);
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {
            
            pstmt.setInt(1, adminId);
            if (search != null && !search.trim().isEmpty()) {
                String searchPattern = "%" + search.trim() + "%";
                for (int i = 2; i <= 6; i++) {
                    pstmt.setString(i, searchPattern);
                }
            }
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> task = new HashMap<>();
                    task.put("id", rs.getInt("id"));
                    task.put("title", rs.getString("title"));
                    task.put("description", rs.getString("description"));
                    task.put("wage", rs.getDouble("wage"));
                    task.put("wage_type", rs.getString("wage_type"));
                    task.put("deadline", rs.getDate("deadline") != null ? rs.getDate("deadline").toString() : "");
                    task.put("priority", rs.getString("priority"));
                    task.put("status", rs.getString("status"));
                    task.put("category", rs.getString("category"));
                    task.put("estimated_hours", rs.getInt("estimated_hours"));
                    task.put("assignedToName", rs.getString("assigned_to_name"));
                    task.put("assigned_to", rs.getInt("assigned_to"));
                    tasks.add(task);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return tasks;
    }

    public List<Map<String, Object>> getAllTasks(int adminId, String sortBy, String sortDir) {
        return getAllTasks(adminId, sortBy, sortDir, null);
    }

    public List<Map<String, Object>> getAllTasks(int adminId) {
        return getAllTasks(adminId, "created_at", "DESC");
    }
    
    public String getAllTasksAsJSON(int adminId) {
        return gson.toJson(getAllTasks(adminId));
    }
    
    public List<Map<String, Object>> getRecentTasks(int limit, int adminId) {
        List<Map<String, Object>> tasks = new ArrayList<>();
        String sql = "SELECT t.*, u.full_name as assigned_to_name FROM tasks t LEFT JOIN users u ON t.assigned_to = u.id WHERE t.created_by = ? ORDER BY t.created_at DESC LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, adminId);
            pstmt.setInt(2, limit);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> task = new HashMap<>();
                task.put("id", rs.getInt("id"));
                task.put("title", rs.getString("title"));
                task.put("category", rs.getString("category"));
                task.put("estimated_hours", rs.getInt("estimated_hours"));
                task.put("status", rs.getString("status"));                task.put("deadline", rs.getDate("deadline"));
                task.put("assigned_to_name", rs.getString("assigned_to_name"));
                tasks.add(task);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return tasks;
    }
    
    public boolean updateTask(Task task, int adminId) {
        String sql = "UPDATE tasks SET title=?, description=?, wage=?, wage_type=?, deadline=?, priority=?, category=?, estimated_hours=?, assigned_to=? WHERE id=? AND created_by=?";
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
            if (task.getAssignedTo() > 0) {
                pstmt.setInt(9, task.getAssignedTo());
            } else {
                pstmt.setNull(9, java.sql.Types.INTEGER);
            }
            pstmt.setInt(10, task.getId());
            pstmt.setInt(11, adminId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean deleteTask(int taskId, int adminId) {
        // We need to delete dependent records first to avoid foreign key violations
        String deleteWagesSql = "DELETE FROM wages WHERE task_id = ?";
        String deleteSubmissionsSql = "DELETE FROM task_submissions WHERE task_id = ?";
        String deleteTaskSql = "DELETE FROM tasks WHERE id = ? AND created_by = ?";
        
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
                pstmt.setInt(2, adminId);
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
    
    public int getTaskCount(int adminId) {
        return getTotalTaskCount(adminId);
    }

    public int getTotalTaskCount(int adminId) {
        String sql = "SELECT COUNT(*) FROM tasks WHERE created_by = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, adminId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    public int getCompletedTaskCount(int adminId) {
        String sql = "SELECT COUNT(*) FROM tasks WHERE status = 'completed' AND created_by = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, adminId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    public int getOpenTaskCount(int adminId) {
        String sql = "SELECT COUNT(*) FROM tasks WHERE status = 'open' AND created_by = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, adminId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    public int getInProgressTaskCount(int adminId) {
        String sql = "SELECT COUNT(*) FROM tasks WHERE status = 'in-progress' AND created_by = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, adminId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
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
    // Check if the reviewedBy admin is the creator of the task
    String checkOwnerSql = "SELECT t.created_by FROM tasks t JOIN task_assignments ta ON t.id = ta.task_id WHERE ta.id = ?";
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement pstmt = conn.prepareStatement(checkOwnerSql)) {
        pstmt.setInt(1, assignmentId);
        ResultSet rs = pstmt.executeQuery();
        if (rs.next()) {
            int creatorId = rs.getInt("created_by");
            if (creatorId != reviewedBy) {
                return false; // Unauthorized
            }
        } else {
            return false; // Not found
        }
    } catch (SQLException e) {
        e.printStackTrace();
        return false;
    }

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
        String sql = "UPDATE task_assignments ta JOIN tasks t ON ta.task_id = t.id " +
                     "SET ta.status = 'rejected', ta.admin_feedback = ?, ta.completed_at = NOW() " +
                     "WHERE ta.id = ? AND ta.status = 'submitted' AND t.created_by = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, comment);
            pstmt.setInt(2, assignmentId);
            pstmt.setInt(3, reviewedBy);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public int getPendingSubmissionCount(int adminId) {
        String sql = "SELECT COUNT(*) FROM task_assignments ta JOIN tasks t ON ta.task_id = t.id WHERE ta.status = 'submitted' AND t.created_by = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, adminId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    public List<Map<String, Object>> getPendingSubmissionsList(int adminId) {
        List<Map<String, Object>> submissions = new ArrayList<>();
        String sql = "SELECT ta.id, ta.task_id, ta.worker_id, ta.submission_text, ta.attachment_path, ta.submitted_at, " +
                     "u.full_name as worker_name, t.title as task_title " +
                     "FROM task_assignments ta " +
                     "JOIN users u ON ta.worker_id = u.id " +
                     "JOIN tasks t ON ta.task_id = t.id " +
                     "WHERE ta.status = 'submitted' AND t.created_by = ? " +
                     "ORDER BY ta.submitted_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, adminId);
            try (ResultSet rs = pstmt.executeQuery()) {
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
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return submissions;
    }
    
    public List<Map<String, Object>> getAvailableTasks(String sortBy, String sortDir, String search) {
        List<Map<String, Object>> tasks = new ArrayList<>();
        
        Map<String, String> allowedCols = new HashMap<>();
        allowedCols.put("title", "t.title");
        allowedCols.put("wage", "t.wage");
        allowedCols.put("deadline", "t.deadline");
        allowedCols.put("priority", "t.priority");
        
        String orderBy = allowedCols.getOrDefault(sortBy, "t.deadline");
        String dir = "DESC".equalsIgnoreCase(sortDir) ? "DESC" : "ASC";
        
        StringBuilder sql = new StringBuilder("SELECT t.* FROM tasks t " +
                     "WHERE t.status = 'open' AND t.assigned_to IS NULL " +
                     "AND NOT EXISTS (SELECT 1 FROM task_assignments ta WHERE ta.task_id = t.id AND ta.status NOT IN ('cancelled', 'rejected'))");
        
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (t.title LIKE ? OR t.description LIKE ? OR t.priority LIKE ? OR t.category LIKE ?)");
        }
        
        sql.append(" ORDER BY ").append(orderBy).append(" ").append(dir);
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {
            
            if (search != null && !search.trim().isEmpty()) {
                String searchPattern = "%" + search.trim() + "%";
                for (int i = 1; i <= 4; i++) {
                    pstmt.setString(i, searchPattern);
                }
            }
            
            try (ResultSet rs = pstmt.executeQuery()) {
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
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return tasks;
    }

    public List<Map<String, Object>> getAvailableTasks() {
        return getAvailableTasks("deadline", "ASC", null);
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

    public List<Map<String, Object>> getWorkerTasks(int workerId, String sortBy, String sortDir, String search) {
        List<Map<String, Object>> tasks = new ArrayList<>();
        
        Map<String, String> allowedCols = new HashMap<>();
        allowedCols.put("title", "t.title");
        allowedCols.put("deadline", "t.deadline");
        allowedCols.put("wage", "t.wage");
        allowedCols.put("status", "ta.status");
        
        String orderBy = allowedCols.getOrDefault(sortBy, "t.deadline");
        String dir = "DESC".equalsIgnoreCase(sortDir) ? "DESC" : "ASC";
        
        StringBuilder sql = new StringBuilder("SELECT ta.id as assignment_id, ta.status as assignment_status, t.* " +
                     "FROM task_assignments ta " +
                     "JOIN tasks t ON ta.task_id = t.id " +
                     "WHERE ta.worker_id = ? AND ta.status NOT IN ('approved', 'cancelled')");
        
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (t.title LIKE ? OR t.description LIKE ? OR t.status LIKE ?)");
        }
        
        sql.append(" ORDER BY ").append(orderBy).append(" ").append(dir);
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {
            
            pstmt.setInt(1, workerId);
            if (search != null && !search.trim().isEmpty()) {
                String searchPattern = "%" + search.trim() + "%";
                for (int i = 2; i <= 4; i++) {
                    pstmt.setString(i, searchPattern);
                }
            }
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> task = new HashMap<>();
                    task.put("assignment_id", rs.getInt("assignment_id"));
                    task.put("id", rs.getInt("id"));
                    task.put("title", rs.getString("title"));
                    task.put("description", rs.getString("description"));
                    task.put("wage", rs.getDouble("wage"));
                    task.put("deadline", rs.getDate("deadline") != null ? rs.getDate("deadline").toString() : "");
                    task.put("status", rs.getString("status"));
                    task.put("category", rs.getString("category"));
                    task.put("estimated_hours", rs.getInt("estimated_hours"));
                    task.put("assignment_status", rs.getString("assignment_status"));
                    tasks.add(task);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return tasks;
    }

    public List<Map<String, Object>> getWorkerTasks(int workerId, String sortBy, String sortDir) {
        return getWorkerTasks(workerId, sortBy, sortDir, null);
    }

    public List<Map<String, Object>> getWorkerTasks(int workerId) {
        return getWorkerTasks(workerId, "deadline", "ASC");
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
    
    public List<Map<String, Object>> getTaskTrends(int adminId) {
        List<Map<String, Object>> trends = new ArrayList<>();
        String sql = "SELECT DATE_FORMAT(created_at, '%Y-%m-%d') AS date, " +
                     "COUNT(CASE WHEN status = 'completed' THEN 1 END) AS completed, " +
                     "COUNT(CASE WHEN status = 'open' THEN 1 END) AS open, " +
                     "COUNT(CASE WHEN status = 'in-progress' THEN 1 END) AS in_progress " +
                     "FROM tasks WHERE created_by = ? AND created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY) " +
                     "GROUP BY DATE_FORMAT(created_at, '%Y-%m-%d') ORDER BY date DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, adminId);
            ResultSet rs = pstmt.executeQuery();
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

    public List<Map<String, Object>> getTasksByCategory(int adminId) {
        List<Map<String, Object>> categories = new ArrayList<>();
        String sql = "SELECT category, COUNT(*) as count FROM tasks WHERE created_by = ? GROUP BY category";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, adminId);
            ResultSet rs = pstmt.executeQuery();
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

    public List<Map<String, Object>> getTasksByPriority(int adminId) {
        List<Map<String, Object>> priorities = new ArrayList<>();
        String sql = "SELECT priority, COUNT(*) as count FROM tasks WHERE created_by = ? GROUP BY priority";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, adminId);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> p = new HashMap<>();
                p.put("priority", rs.getString("priority"));
                p.put("count", rs.getInt("count"));
                priorities.add(p);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return priorities;
    }

    public List<Map<String, Object>> getTasksByStatus(int adminId) {
        List<Map<String, Object>> statuses = new ArrayList<>();
        String sql = "SELECT status, COUNT(*) as count FROM tasks WHERE created_by = ? GROUP BY status";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, adminId);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> s = new HashMap<>();
                s.put("status", rs.getString("status"));
                s.put("count", rs.getInt("count"));
                statuses.add(s);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return statuses;
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
    String sql = "SELECT ta.quality_rating as rating, ta.completed_at as reviewed_at, t.title as task_title " +
                 "FROM task_assignments ta " +
                 "JOIN tasks t ON ta.task_id = t.id " +
                 "WHERE ta.worker_id = ? AND ta.status = 'approved' AND ta.quality_rating IS NOT NULL " +
                 "ORDER BY ta.completed_at DESC LIMIT 10";
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

    public List<Map<String, Object>> getCompletedTasksWithRatings(int workerId, String sortBy, String sortDir, String search) {
        List<Map<String, Object>> performance = new ArrayList<>();
        
        Map<String, String> allowedCols = new HashMap<>();
        allowedCols.put("title", "t.title");
        allowedCols.put("date", "ta.completed_at");
        allowedCols.put("wage", "t.wage");
        allowedCols.put("rating", "ta.quality_rating");
        
        String orderBy = allowedCols.getOrDefault(sortBy, "ta.completed_at");
        String dir = "DESC".equalsIgnoreCase(sortDir) ? "DESC" : "ASC";
        
        StringBuilder sql = new StringBuilder("SELECT t.title, t.wage, t.status as task_status, ta.quality_rating as rating, ta.admin_feedback as rating_comment, ta.completed_at as reviewed_at " +
                     "FROM tasks t " +
                     "JOIN task_assignments ta ON t.id = ta.task_id " +
                     "WHERE ta.worker_id = ? AND t.status = 'completed' AND ta.status = 'approved'");
        
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND t.title LIKE ?");
        }
        
        sql.append(" ORDER BY ").append(orderBy).append(" ").append(dir);
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {
            
            pstmt.setInt(1, workerId);
            if (search != null && !search.trim().isEmpty()) {
                pstmt.setString(2, "%" + search.trim() + "%");
            }
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> record = new HashMap<>();
                    record.put("title", rs.getString("title"));
                    record.put("wage", rs.getDouble("wage"));
                    record.put("rating", rs.getInt("rating"));
                    record.put("comment", rs.getString("rating_comment"));
                    record.put("date", rs.getTimestamp("reviewed_at") != null ? rs.getTimestamp("reviewed_at").toString() : "");
                    performance.add(record);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return performance;
    }

    public List<Map<String, Object>> getCompletedTasksWithRatings(int workerId, String sortBy, String sortDir) {
        return getCompletedTasksWithRatings(workerId, sortBy, sortDir, null);
    }

    public List<Map<String, Object>> getCompletedTasksWithRatings(int workerId) {
        return getCompletedTasksWithRatings(workerId, "date", "DESC");
    }
    }