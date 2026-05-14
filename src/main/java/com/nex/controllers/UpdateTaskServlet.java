package com.nex.controllers;

import java.io.IOException;
import java.sql.Date;

import com.nex.dao.TaskDAO;
import com.nex.model.Task;
import com.nex.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/UpdateTaskServlet")
public class UpdateTaskServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private TaskDAO taskDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        taskDAO = new TaskDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        java.io.PrintWriter out = response.getWriter();
        
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("user") : null;
        
        // Security check
        if (currentUser == null || !"admin".equals(currentUser.getRole())) {
            out.print("{\"success\": false, \"message\": \"Unauthorized access\"}");
            return;
        }

        try {
            // Extract parameters from form
            int id = Integer.parseInt(request.getParameter("id"));
            String title = request.getParameter("title");
            String description = request.getParameter("description");
            double wage = Double.parseDouble(request.getParameter("wage"));
            String wageType = request.getParameter("wageType");
            Date deadline = Date.valueOf(request.getParameter("deadline"));
            String priority = request.getParameter("priority");
            String category = request.getParameter("category");
            int estimatedHours = 0;
            try {
                estimatedHours = Integer.parseInt(request.getParameter("estimatedHours"));
            } catch (Exception e) {}
            
            // Get existing task to ensure it exists and belongs to this admin (optional but good practice)
            Task task = taskDAO.getTaskById(id);
            if (task == null) {
                out.print("{\"success\": false, \"message\": \"Task not found\"}");
                return;
            }
            
            // Update fields
            task.setTitle(title);
            task.setDescription(description);
            task.setWage(wage);
            task.setWageType(wageType);
            task.setDeadline(deadline);
            task.setPriority(priority);
            task.setCategory(category != null ? category : "General");
            task.setEstimatedHours(estimatedHours);
            
            // Save to database
            boolean success = taskDAO.updateTask(task, currentUser.getId());
            
            if (success) {
                out.print("{\"success\": true, \"message\": \"Task updated successfully!\"}");
            } else {
                out.print("{\"success\": false, \"message\": \"Failed to update task.\"}");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\": false, \"message\": \"Invalid input data: " + e.getMessage() + "\"}");
        }
    }
}
