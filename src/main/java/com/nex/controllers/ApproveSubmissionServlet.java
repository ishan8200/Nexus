package com.nex.controllers;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Map;

import com.nex.dao.TaskDAO;
import com.nex.dao.WageDAO;
import com.nex.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/ApproveSubmissionServlet")
public class ApproveSubmissionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private TaskDAO taskDAO;
    private WageDAO wageDAO;
    private com.nex.dao.NotificationDAO notificationDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        taskDAO = new TaskDAO();
        wageDAO = new WageDAO();
        notificationDAO = new com.nex.dao.NotificationDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("user") : null;
        
        if (currentUser == null || !"admin".equals(currentUser.getRole())) {
            out.print("{\"success\": false, \"message\": \"Unauthorized access\"}");
            return;
        }

        try {
            int submissionId = Integer.parseInt(request.getParameter("submissionId"));
            String action = request.getParameter("action");
            
            if ("approve".equals(action)) {
                // Mark as approved, update task status, and create wage record
                // We use a default rating of 5 for now
                boolean success = taskDAO.processSubmissionApproval(submissionId, currentUser.getId(), 5, "Approved via Admin Dashboard");
                
                if (success) {
                    out.print("{\"success\": true, \"message\": \"Submission approved and payment recorded!\"}");
                } else {
                    out.print("{\"success\": false, \"message\": \"Approval process failed. Please check logs.\"}");
                }
            } else if ("reject".equals(action)) {
                String reason = request.getParameter("reason");
                
                // Get worker info before rejection for notification
                int workerId = -1;
                String taskTitle = "Unknown Task";
                try (java.sql.Connection conn = com.nex.config.DBConnection.getConnection();
                     java.sql.PreparedStatement pstmt = conn.prepareStatement("SELECT ts.worker_id, t.title FROM task_submissions ts JOIN tasks t ON ts.task_id = t.id WHERE ts.id = ?")) {
                    pstmt.setInt(1, submissionId);
                    java.sql.ResultSet rs = pstmt.executeQuery();
                    if (rs.next()) {
                        workerId = rs.getInt("worker_id");
                        taskTitle = rs.getString("title");
                    }
                }

                boolean success = taskDAO.rejectSubmission(submissionId, currentUser.getId(), reason);
                if (success) {
                    if (workerId != -1) {
                        notificationDAO.sendNotification(
                            workerId, 
                            "Submission Rejected", 
                            "Please resubmit the work after completing the task", 
                            "warning", 
                            submissionId, 
                            "submission"
                        );
                    }
                    out.print("{\"success\": true, \"message\": \"Submission rejected\"}");
                } else {
                    out.print("{\"success\": false, \"message\": \"Rejection failed\"}");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\": false, \"message\": \"Server error: " + e.getMessage() + "\"}");
        }
    }
}
