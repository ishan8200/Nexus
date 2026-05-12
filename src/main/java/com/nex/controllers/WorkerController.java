package com.nex.controllers;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import com.nex.dao.TaskDAO;
import com.nex.dao.UserDAO;
import com.nex.model.Skill;
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
    private com.nex.dao.NotificationDAO notificationDAO;
    private com.nex.dao.SkillDAO skillDAO;
    
    @Override
    public void init() throws ServletException {
        super.init();
        taskDAO = new TaskDAO();
        userDAO = new UserDAO();
        notificationDAO = new com.nex.dao.NotificationDAO();
        skillDAO = new com.nex.dao.SkillDAO();
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
        
        // Get sorting and search parameters
        String availSortBy = request.getParameter("availSortBy");
        String availSortDir = request.getParameter("availSortDir");
        String availSearch = request.getParameter("availSearch");
        
        String mySortBy = request.getParameter("mySortBy");
        String mySortDir = request.getParameter("mySortDir");
        String mySearch = request.getParameter("mySearch");
        
        String perfSortBy = request.getParameter("perfSortBy");
        String perfSortDir = request.getParameter("perfSortDir");
        String perfSearch = request.getParameter("perfSearch");
        
        String earnSortBy = request.getParameter("earnSortBy");
        String earnSortDir = request.getParameter("earnSortDir");

        // Load worker data
        Map<String, Object> stats = userDAO.getWorkerStats(currentUser.getId());
        List<Map<String, Object>> availableTasks = taskDAO.getAvailableTasks(availSortBy, availSortDir, availSearch);
        List<Map<String, Object>> myTasks = taskDAO.getWorkerTasks(currentUser.getId(), mySortBy, mySortDir, mySearch);
        
        com.nex.dao.WageDAO wageDAO = new com.nex.dao.WageDAO();
        List<Map<String, Object>> earningsHistory = wageDAO.getWorkerEarnings(currentUser.getId(), earnSortBy, earnSortDir);
        
        List<Map<String, Object>> notifications = notificationDAO.getNotificationsForUser(currentUser.getId());
        List<Skill> allSkills = skillDAO.getAllSkills();
        List<Skill> workerSkills = skillDAO.getWorkerSkills(currentUser.getId());
        List<Map<String, Object>> performance = taskDAO.getCompletedTasksWithRatings(currentUser.getId(), perfSortBy, perfSortDir, perfSearch);
        
        request.setAttribute("totalEarned", stats.get("total_earned"));
        request.setAttribute("tasksCompleted", stats.get("tasks_completed"));
        request.setAttribute("avgRating", stats.get("avg_rating"));
        request.setAttribute("pendingPayment", stats.get("pending_payment"));
        request.setAttribute("completionRate", stats.get("completion_rate"));
        request.setAttribute("lateSubmissions", stats.get("late_submissions"));

        request.setAttribute("availableTasks", availableTasks);

        request.setAttribute("myTasks", myTasks);
        request.setAttribute("earningsHistory", earningsHistory);
        request.setAttribute("notifications", notifications);
        request.setAttribute("allSkills", allSkills);
        request.setAttribute("workerSkills", workerSkills);
        request.setAttribute("performance", performance);
        request.setAttribute("currentUser", currentUser);

        // Preserve parameters
        request.setAttribute("availSortBy", availSortBy);
        request.setAttribute("availSortDir", availSortDir);
        request.setAttribute("availSearch", availSearch);
        request.setAttribute("mySortBy", mySortBy);
        request.setAttribute("mySortDir", mySortDir);
        request.setAttribute("mySearch", mySearch);
        request.setAttribute("perfSortBy", perfSortBy);
        request.setAttribute("perfSortDir", perfSortDir);
        request.setAttribute("perfSearch", perfSearch);
        request.setAttribute("earnSortBy", earnSortBy);
        request.setAttribute("earnSortDir", earnSortDir);
        
        request.getRequestDispatcher("/WEB-INF/pages/workerDash.jsp").forward(request, response);
    }
}