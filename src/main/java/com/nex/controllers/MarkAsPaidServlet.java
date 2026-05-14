package com.nex.controllers;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.UUID;

import com.nex.dao.WageDAO;
import com.nex.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/MarkAsPaidServlet")
public class MarkAsPaidServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private WageDAO wageDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        wageDAO = new WageDAO();
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
            String wageIdParam = request.getParameter("wageId");
            String workerIdParam = request.getParameter("workerId");
            String transactionId = "TXN-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
            
            boolean success = false;
            
            if (wageIdParam != null && !wageIdParam.isEmpty()) {
                int wageId = Integer.parseInt(wageIdParam);
                success = wageDAO.markAsPaid(wageId, currentUser.getId(), transactionId, "System Transfer");
            } else if (workerIdParam != null && !workerIdParam.isEmpty()) {
                int workerId = Integer.parseInt(workerIdParam);
                // We need to ensure markWorkerWagesAsPaid also filters by adminId
                // Let's update WageDAO.markWorkerWagesAsPaid to support ownership
                success = wageDAO.markWorkerWagesAsPaid(workerId, currentUser.getId(), transactionId);
            }
            
            if (success) {
                out.print("{\"success\": true, \"message\": \"Payment processed! TXN: " + transactionId + "\"}");
            } else {
                out.print("{\"success\": false, \"message\": \"Failed to process payment. Record not found or already paid.\" }");
            }
        } catch (Exception e) {
            out.print("{\"success\": false, \"message\": \"Invalid parameters: " + e.getMessage() + "\"}");
        }
    }
}
