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

@WebServlet("/ManageWorkerServlet")
public class ManageWorkerServlet extends HttpServlet {
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
            out.print("{\"success\": false, \"message\": \"Unauthorized access\"}");
            return;
        }

        try {
            int workerId = Integer.parseInt(request.getParameter("workerId"));
            String status = request.getParameter("status");
            
            // Validate status
            if (!"approved".equals(status) && !"blocked".equals(status) && !"pending".equals(status)) {
                out.print("{\"success\": false, \"message\": \"Invalid status value\"}");
                return;
            }
            
            boolean success = userDAO.updateWorkerStatus(workerId, status);
            
            if (success) {
                out.print("{\"success\": true, \"message\": \"Worker account " + status + " successfully.\"}");
            } else {
                out.print("{\"success\": false, \"message\": \"Update failed.\"}");
            }
        } catch (Exception e) {
            out.print("{\"success\": false, \"message\": \"Invalid request.\"}");
        }
    }
}
