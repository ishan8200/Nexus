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

        int totalTasks = taskDAO.getTaskCount();
        int completedTasks = taskDAO.getCompletedTaskCount();
        int activeWorkers = userDAO.getActiveWorkerCount();
        double wagesDisbursed = wageDAO.getTotalWagesPaid();
        int pendingSubmissions = taskDAO.getPendingSubmissionCount();

        List<Map<String, Object>> recentTasks = taskDAO.getRecentTasks(5);
        List<User> pendingWorkersList = userDAO.getPendingWorkersList();
        List<Map<String, Object>> pendingSubmissionsList = taskDAO.getPendingSubmissionsList();
        List<User> allWorkers = userDAO.getAllWorkers(workerSortBy, workerSortDir, workerSearch);
        List<Map<String, Object>> allTasks = taskDAO.getAllTasks(taskSortBy, taskSortDir, taskSearch);
        List<Map<String, Object>> wageSummary = wageDAO.getWageSummary();
        List<Map<String, Object>> pendingWages = wageDAO.getPendingWagesWithDetails(wageSortBy, wageSortDir, wageSearch);
        List<Map<String, Object>> paidWages = wageDAO.getPaidWagesWithDetails(paymentSortBy, paymentSortDir, paymentSearch);
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
        request.setAttribute("pendingWages", pendingWages);
        request.setAttribute("paidWages", paidWages);
        request.setAttribute("taskTrends", taskTrends);
        request.setAttribute("tasksByCategory", tasksByCategory);
        request.setAttribute("currentUser", currentUser);
        
        // Preserve sort and search parameters
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
        
        request.getRequestDispatcher("/WEB-INF/pages/adminDash.jsp").forward(request, response);
    }
}