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

@WebServlet("/accept-task")
public class AcceptTaskServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private TaskDAO taskDAO;

    @Override
    public void init() throws ServletException {
        taskDAO = new TaskDAO();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null || !"worker".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String taskIdStr = request.getParameter("taskId");
        if (taskIdStr != null) {
            try {
                int taskId = Integer.parseInt(taskIdStr);
                boolean success = taskDAO.assignTaskToWorker(taskId, user.getId());
                if (success) {
                    response.sendRedirect(request.getContextPath() + "/worker?success=Task accepted successfully");
                } else {
                    response.sendRedirect(request.getContextPath() + "/worker?error=Could not accept task");
                }
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/worker?error=Invalid task ID");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/worker?error=Missing task ID");
        }
    }
}
