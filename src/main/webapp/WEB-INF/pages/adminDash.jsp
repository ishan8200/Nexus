<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, com.nex.model.User" %>
<%@ page import="com.nex.dao.TaskDAO, com.nex.dao.UserDAO, com.nex.dao.WageDAO" %>
<%
    // Check if user is logged in and is admin
    HttpSession sessionObj = request.getSession(false);
    User currentUser = (sessionObj != null) ? (User) sessionObj.getAttribute("user") : null;
    
    if (currentUser == null || !"admin".equals(currentUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Get statistics using stored procedure
    TaskDAO taskDAO = new TaskDAO();
    UserDAO userDAO = new UserDAO();
    WageDAO wageDAO = new WageDAO();
    
    // Dashboard statistics
    int totalTasks = taskDAO.getTotalTaskCount();
    int completedTasks = taskDAO.getCompletedTaskCount();
    int activeWorkers = userDAO.getActiveWorkerCount();
    double wagesDisbursed = wageDAO.getTotalWagesDisbursed();
    int pendingWorkers = userDAO.getPendingWorkerCount();
    int pendingSubmissions = taskDAO.getPendingSubmissionCount();
    
    // Recent tasks
    List<Map<String, Object>> recentTasks = taskDAO.getRecentTasks(5);
    
    // Pending workers
    List<Map<String, Object>> pendingWorkersList = userDAO.getPendingWorkersList();
    
    // Pending submissions
    List<Map<String, Object>> pendingSubmissionsList = taskDAO.getPendingSubmissionsList();
    
    // All workers
    List<Map<String, Object>> allWorkers = userDAO.getAllWorkersWithStats();
    
    // Wage summary
    List<Map<String, Object>> wageSummary = wageDAO.getWageSummary();
    
    // All tasks
    List<Map<String, Object>> allTasks = taskDAO.getAllTasks();
%>
