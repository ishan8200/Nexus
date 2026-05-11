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

@WebServlet("/CreateTaskServlet")
public class CreateTaskServlet extends HttpServlet {
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
            String title = request.getParameter("title");
            String description = request.getParameter("description");
            double wage = Double.parseDouble(request.getParameter("wage"));
            String wageType = request.getParameter("wageType");
            Date deadline = Date.valueOf(request.getParameter("deadline"));
            String priority = request.getParameter("priority");
            
            // Create Task object
            Task task = new Task();
            task.setTitle(title);
            task.setDescription(description);
            task.setWage(wage);
            task.setWageType(wageType);
            task.setDeadline(deadline);
            task.setPriority(priority);
            task.setCreatedBy(currentUser.getId());
            task.setStatus("open");
            
            // Optional/Default fields
            task.setCategory("General");
            task.setRecurrence("none");
            task.setEstimatedHours(0);
            
            // Save to database
            boolean success = taskDAO.createTask(task);
            
            if (success) {
                out.print("{\"success\": true, \"message\": \"Mission deployed successfully!\"}");
            } else {
                out.print("{\"success\": false, \"message\": \"Failed to deploy mission. System error.\"}");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\": false, \"message\": \"Invalid input data: " + e.getMessage() + "\"}");
        }
    }
}
