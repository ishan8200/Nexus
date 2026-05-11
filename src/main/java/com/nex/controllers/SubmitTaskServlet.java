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

@WebServlet("/submit-task")
public class SubmitTaskServlet extends HttpServlet {
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
        String submissionText = request.getParameter("submissionText");
        String hoursWorkedStr = request.getParameter("hoursWorked");

        if (assignmentIdStr == null || submissionText == null || submissionText.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/worker?error=Missing submission details");
            return;
        }

        try {
            int assignmentId = Integer.parseInt(assignmentIdStr);
            double hoursWorked = 0.0;
            if (hoursWorkedStr != null && !hoursWorkedStr.isEmpty()) {
                hoursWorked = Double.parseDouble(hoursWorkedStr);
            }

            boolean success = taskDAO.submitTaskWork(assignmentId, submissionText, null, hoursWorked);
            
            if (success) {
                response.sendRedirect(request.getContextPath() + "/worker?success=Work submitted successfully! Awaiting review.");
            } else {
                response.sendRedirect(request.getContextPath() + "/worker?error=Failed to submit work");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/worker?error=Invalid assignment ID");
        }
    }
}