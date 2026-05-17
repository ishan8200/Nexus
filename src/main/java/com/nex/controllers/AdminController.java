package com.nex.controllers;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import com.nex.dao.TaskDAO;
import com.nex.dao.UserDAO;
import com.nex.dao.WageDAO;
import com.nex.dao.SettingsDAO;
import com.nex.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet({"/admin", "/admin/update-settings"})
public class AdminController extends HttpServlet {
    
    private static final long serialVersionUID = 1L;
    private TaskDAO taskDAO;
    private UserDAO userDAO;
    private WageDAO wageDAO;
    private SettingsDAO settingsDAO;
    
    @Override
    public void init() throws ServletException {
        super.init();
        taskDAO = new TaskDAO();
        userDAO = new UserDAO();
        wageDAO = new WageDAO();
        settingsDAO = new SettingsDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        handleAdminDashboard(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String path = request.getServletPath();
        if ("/admin/update-settings".equals(path)) {
            handleUpdateSettings(request, response);
        } else {
            doGet(request, response);
        }
    }

    private void handleUpdateSettings(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Security check
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("user") : null;
        if (currentUser == null || !"admin".equals(currentUser.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String action = request.getParameter("action");
        if ("updateContent".equals(action)) {
            String key = request.getParameter("configKey");
            String value = request.getParameter("configValue");
            
            boolean success = settingsDAO.updateSetting(key, value);
            
            response.setContentType("application/json");
            if (success) {
                response.getWriter().write("{\"success\": true, \"message\": \"Setting updated successfully\"}");
            } else {
                response.getWriter().write("{\"success\": false, \"message\": \"Failed to update setting\"}");
            }
        }
    }

    private void handleAdminDashboard(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("user") : null;
        
        if (currentUser == null || !"admin".equals(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        // Load dashboard data
        // Get sorting parameters
        String taskSortBy = request.getParameter("taskSortBy");
        String taskSortDir = request.getParameter("taskSortDir");
        String workerSortBy = request.getParameter("workerSortBy");
        String workerSortDir = request.getParameter("workerSortDir");
        String wageSortBy = request.getParameter("wageSortBy");
        String wageSortDir = request.getParameter("wageSortDir");
        String paymentSortBy = request.getParameter("paymentSortBy");
        String paymentSortDir = request.getParameter("paymentSortDir");
        
        // Get search parameters
        String taskSearch = request.getParameter("taskSearch");
        String workerSearch = request.getParameter("workerSearch");
        String wageSearch = request.getParameter("wageSearch");
        String paymentSearch = request.getParameter("paymentSearch");
        
        // Get filter parameters
        String taskFilter = request.getParameter("taskFilter");
        if (taskFilter == null) taskFilter = "my";
        
        String analyticsFilter = request.getParameter("analyticsFilter");
        if (analyticsFilter == null) analyticsFilter = "my";

        int totalTasks = taskDAO.getTotalTaskCount(currentUser.getId(), analyticsFilter);
        int completedTasks = taskDAO.getCompletedTaskCount(currentUser.getId(), analyticsFilter);
        int activeWorkers = userDAO.getActiveWorkerCount();
        double wagesDisbursed = wageDAO.getTotalWagesDisbursed(currentUser.getId(), analyticsFilter);
        int pendingSubmissions = taskDAO.getPendingSubmissionCount(currentUser.getId());
        
        // Performance Nodes
        double avgRating = userDAO.getAverageWorkerRating();
        double taskEfficiency = (totalTasks > 0) ? ((double) completedTasks / totalTasks * 100) : 0;
        double networkGrowth = userDAO.getNetworkGrowth();
        double systemHealth = 100.0; // Assume 100% health for now

        List<Map<String, Object>> recentTasks = taskDAO.getRecentTasks(5, currentUser.getId());
        List<User> pendingWorkersList = userDAO.getPendingWorkersList();
        List<Map<String, Object>> pendingSubmissionsList = taskDAO.getPendingSubmissionsList(currentUser.getId());
        List<User> allWorkers = userDAO.getAllWorkers(workerSortBy, workerSortDir, workerSearch);
        List<Map<String, Object>> allTasks = taskDAO.getAllTasks(currentUser.getId(), taskFilter, taskSortBy, taskSortDir, taskSearch);
        List<Map<String, Object>> wageSummary = wageDAO.getWageSummary(currentUser.getId());
        List<Map<String, Object>> pendingWages = wageDAO.getPendingWagesWithDetails(currentUser.getId(), wageSortBy, wageSortDir, wageSearch);
        List<Map<String, Object>> paidWages = wageDAO.getPaidWagesWithDetails(currentUser.getId(), paymentSortBy, paymentSortDir, paymentSearch);
        List<Map<String, Object>> taskTrends = taskDAO.getTaskTrends(currentUser.getId(), analyticsFilter);
        List<Map<String, Object>> tasksByCategory = taskDAO.getTasksByCategory(currentUser.getId(), analyticsFilter);
        List<Map<String, Object>> tasksByPriority = taskDAO.getTasksByPriority(currentUser.getId(), analyticsFilter);
        List<Map<String, Object>> tasksByStatus = taskDAO.getTasksByStatus(currentUser.getId(), analyticsFilter);
        
        // CMS Settings
        java.util.Map<String, String> siteSettings = settingsDAO.getAllSettings();
        
        request.setAttribute("totalTasks", totalTasks);
        request.setAttribute("completedTasks", completedTasks);
        request.setAttribute("activeWorkers", activeWorkers);
        request.setAttribute("wagesDisbursed", wagesDisbursed);
        request.setAttribute("pendingSubmissions", pendingSubmissions);
        
        request.setAttribute("avgRating", avgRating);
        request.setAttribute("taskEfficiency", taskEfficiency);
        request.setAttribute("networkGrowth", networkGrowth);
        request.setAttribute("systemHealth", systemHealth);

        request.setAttribute("recentTasks", recentTasks);
        request.setAttribute("pendingWorkersList", pendingWorkersList);
        request.setAttribute("pendingSubmissionsList", pendingSubmissionsList);
        request.setAttribute("allWorkers", allWorkers);
        request.setAttribute("allTasks", allTasks);
        request.setAttribute("wageSummary", wageSummary);
        request.setAttribute("pendingWages", pendingWages);
        request.setAttribute("paidWages", paidWages);
        request.setAttribute("taskTrends", taskTrends);
        request.setAttribute("tasksByCategory", tasksByCategory);
        request.setAttribute("tasksByPriority", tasksByPriority);
        request.setAttribute("tasksByStatus", tasksByStatus);
        request.setAttribute("siteSettings", siteSettings);
        request.setAttribute("currentUser", currentUser);
        
        // Preserve sort, search and filter parameters
        request.setAttribute("taskSortBy", taskSortBy);
        request.setAttribute("taskSortDir", taskSortDir);
        request.setAttribute("workerSortBy", workerSortBy);
        request.setAttribute("workerSortDir", workerSortDir);
        request.setAttribute("wageSortBy", wageSortBy);
        request.setAttribute("wageSortDir", wageSortDir);
        request.setAttribute("paymentSortBy", paymentSortBy);
        request.setAttribute("paymentSortDir", paymentSortDir);
        request.setAttribute("taskSearch", taskSearch);
        request.setAttribute("workerSearch", workerSearch);
        request.setAttribute("wageSearch", wageSearch);
        request.setAttribute("paymentSearch", paymentSearch);
        request.setAttribute("taskFilter", taskFilter);
        request.setAttribute("analyticsFilter", analyticsFilter);
        
        request.getRequestDispatcher("/WEB-INF/pages/adminDash.jsp").forward(request, response);
    }
}