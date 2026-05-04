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

@WebServlet("/RateWorkerServlet")
public class RateWorkerServlet extends HttpServlet {
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
            double rating = Double.parseDouble(request.getParameter("rating"));
            
            // Validate rating range
            if (rating < 0 || rating > 5) {
                out.print("{\"success\": false, \"message\": \"Invalid rating value\"}");
                return;
            }
            
            boolean success = userDAO.updateUserRating(workerId, rating);
            
            if (success) {
                out.print("{\"success\": true, \"message\": \"Worker rated successfully.\"}");
            } else {
                out.print("{\"success\": false, \"message\": \"Update failed.\"}");
            }
        } catch (Exception e) {
            out.print("{\"success\": false, \"message\": \"Invalid request parameters.\"}");
        }
    }
}
