package com.nex.controllers;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import com.nex.dao.TaskDAO;
import com.nex.dao.UserDAO;
import com.nex.dao.WageDAO;
import com.nex.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/admin")
public class AdminController extends HttpServlet {
    
    private static final long serialVersionUID = 1L;
    private TaskDAO taskDAO;
    private UserDAO userDAO;
    private WageDAO wageDAO;
    
    @Override
    public void init() throws ServletException {
        super.init();
        taskDAO = new TaskDAO();
        userDAO = new UserDAO();
        wageDAO = new WageDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("user") : null;
        
        if (currentUser == null || !"admin".equals(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        // Load dashboard data
        int totalTasks = taskDAO.getTotalTaskCount();
        int completedTasks = taskDAO.getCompletedTaskCount();
        int activeWorkers = userDAO.getActiveWorkerCount();
        double wagesDisbursed = wageDAO.getTotalWagesDisbursed();
        int pendingSubmissions = taskDAO.getPendingSubmissionCount();
        
        List<Map<String, Object>> recentTasks = taskDAO.getRecentTasks(5);
        List<User> pendingWorkersList = userDAO.getPendingWorkersList();
        List<Map<String, Object>> pendingSubmissionsList = taskDAO.getPendingSubmissionsList();
        List<User> allWorkers = userDAO.getAllWorkersWithStats();
        List<Map<String, Object>> allTasks = taskDAO.getAllTasks();
        List<Map<String, Object>> wageSummary = wageDAO.getWageSummary();
        List<Map<String, Object>> taskTrends = taskDAO.getTaskTrends();
        List<Map<String, Object>> tasksByCategory = taskDAO.getTasksByCategory();
        
        request.setAttribute("totalTasks", totalTasks);
        request.setAttribute("completedTasks", completedTasks);
        request.setAttribute("activeWorkers", activeWorkers);
        request.setAttribute("wagesDisbursed", wagesDisbursed);
        request.setAttribute("pendingSubmissions", pendingSubmissions);
        request.setAttribute("recentTasks", recentTasks);
        request.setAttribute("pendingWorkersList", pendingWorkersList);
        request.setAttribute("pendingSubmissionsList", pendingSubmissionsList);
        request.setAttribute("allWorkers", allWorkers);
        request.setAttribute("allTasks", allTasks);
        request.setAttribute("wageSummary", wageSummary);
        request.setAttribute("taskTrends", taskTrends);
        request.setAttribute("tasksByCategory", tasksByCategory);
        request.setAttribute("currentUser", currentUser);
        
        request.getRequestDispatcher("/WEB-INF/pages/adminDash.jsp").forward(request, response);
    }
}