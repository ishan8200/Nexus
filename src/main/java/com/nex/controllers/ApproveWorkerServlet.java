package com.nex.controllers;

import java.io.IOException;
import java.io.PrintWriter;

import com.nex.dao.UserDAO;
import com.nex.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/ApproveWorkerServlet")
public class ApproveWorkerServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        userDAO = new UserDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("user") : null;
        
        if (currentUser == null || !"admin".equals(currentUser.getRole())) {
            out.print("{\"success\": false, \"message\": \"Unauthorized access. Please login as admin.\"}");
            return;
        }

        try {
            String workerIdStr = request.getParameter("workerId");
            String action = request.getParameter("action");
            
            if (workerIdStr == null || action == null) {
                out.print("{\"success\": false, \"message\": \"Missing parameters\"}");
                return;
            }
            
            int workerId = Integer.parseInt(workerIdStr);
            String status = "approve".equals(action) ? "approved" : "rejected";
            
            boolean success = userDAO.updateWorkerStatus(workerId, status);
            
            if (success) {
                out.print("{\"success\": true, \"message\": \"Worker " + status + " successfully.\"}");
            } else {
                out.print("{\"success\": false, \"message\": \"Database update failed. User may not exist.\"}");
            }
        } catch (NumberFormatException e) {
            out.print("{\"success\": false, \"message\": \"Invalid worker ID format\"}");
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\": false, \"message\": \"Internal server error: " + e.getMessage() + "\"}");
        }
    }
}
