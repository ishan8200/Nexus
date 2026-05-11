package com.nex.controllers;

import java.io.IOException;
import com.nex.dao.TaskDAO;
import com.nex.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/update-assignment")
public class UpdateAssignmentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private TaskDAO taskDAO;

    @Override
    public void init() throws ServletException {
        taskDAO = new TaskDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null || !"worker".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String assignmentIdStr = request.getParameter("assignmentId");
        String action = request.getParameter("action");

        if (assignmentIdStr == null) {
            response.sendRedirect(request.getContextPath() + "/worker?error=Missing assignment ID");
            return;
        }

        try {
            int assignmentId = Integer.parseInt(assignmentIdStr);
            boolean success = false;

            if ("start".equals(action)) {
                success = taskDAO.startTask(assignmentId);
                if (success) {
                    response.sendRedirect(request.getContextPath() + "/worker?success=Task started successfully");
                } else {
                    response.sendRedirect(request.getContextPath() + "/worker?error=Could not start task");
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/worker?error=Invalid action");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/worker?error=Invalid assignment ID");
        }
    }
}