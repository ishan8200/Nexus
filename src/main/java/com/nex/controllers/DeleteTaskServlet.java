package com.nex.controllers;

import java.io.IOException;
import java.io.PrintWriter;

import com.nex.dao.TaskDAO;
import com.nex.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/DeleteTaskServlet")
public class DeleteTaskServlet extends HttpServlet {
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
        PrintWriter out = response.getWriter();
        
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("user") : null;
        
        if (currentUser == null || !"admin".equals(currentUser.getRole())) {
            out.print("{\"success\": false, \"message\": \"Unauthorized access\"}");
            return;
        }

        try {
            int taskId = Integer.parseInt(request.getParameter("taskId"));
            boolean success = taskDAO.deleteTask(taskId);
            
            if (success) {
                out.print("{\"success\": true, \"message\": \"Task deleted successfully\"}");
            } else {
                out.print("{\"success\": false, \"message\": \"Failed to delete task. It might be assigned to a worker.\" }");
            }
        } catch (Exception e) {
            out.print("{\"success\": false, \"message\": \"Invalid task ID\"}");
        }
    }
}
