package com.nex.controllers;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import com.nex.dao.TaskDAO;
import com.nex.dao.UserDAO;
import com.nex.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/worker")
public class WorkerController extends HttpServlet {
    
    private static final long serialVersionUID = 1L;
    private TaskDAO taskDAO;
    private UserDAO userDAO;
    
    @Override
    public void init() throws ServletException {
        super.init();
        taskDAO = new TaskDAO();
        userDAO = new UserDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("user") : null;
        
        if (currentUser == null || !"worker".equals(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        if (!"approved".equals(currentUser.getStatus())) {
            request.setAttribute("error", "Your account is pending admin approval.");
            request.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(request, response);
            return;
        }
        
        // Load worker data
        Map<String, Object> stats = userDAO.getWorkerStats(currentUser.getId());
        List<Map<String, Object>> availableTasks = taskDAO.getAvailableTasks();
        List<Map<String, Object>> myTasks = userDAO.getMyTasks(currentUser.getId());
        List<Map<String, Object>> earningsHistory = userDAO.getWorkerEarnings(currentUser.getId());
        
        request.setAttribute("totalEarned", stats.get("total_earned"));
        request.setAttribute("tasksCompleted", stats.get("tasks_completed"));
        request.setAttribute("avgRating", stats.get("avg_rating"));
        request.setAttribute("pendingPayment", stats.get("pending_payment"));
        request.setAttribute("availableTasks", availableTasks);
        request.setAttribute("myTasks", myTasks);
        request.setAttribute("earningsHistory", earningsHistory);
        request.setAttribute("currentUser", currentUser);
        
        request.getRequestDispatcher("/WEB-INF/pages/workerDash.jsp").forward(request, response);
    }
}