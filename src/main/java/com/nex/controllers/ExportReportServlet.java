package com.nex.controllers;

import java.io.IOException;
import java.io.PrintWriter;
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

@WebServlet("/export-report")
public class ExportReportServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private TaskDAO taskDAO;
    private UserDAO userDAO;
    private WageDAO wageDAO;

    @Override
    public void init() throws ServletException {
        taskDAO = new TaskDAO();
        userDAO = new UserDAO();
        wageDAO = new WageDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null || !"admin".equals(user.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String type = request.getParameter("type");
        if (type == null) type = "tasks";

        response.setContentType("text/csv");
        response.setHeader("Content-Disposition", "attachment; filename=\"nexus_report_" + type + "_" + System.currentTimeMillis() + ".csv\"");

        try (PrintWriter writer = response.getWriter()) {
            if ("workers".equals(type)) {
                exportWorkers(writer);
            } else if ("financial".equals(type)) {
                exportFinancial(writer);
            } else if ("trends".equals(type)) {
                exportTrends(writer);
            } else {
                exportTasks(writer);
            }
        }
    }

    private void exportTasks(PrintWriter writer) {
        writer.println("ID,Title,Status,Priority,Wage,Deadline,Category");
        List<Map<String, Object>> tasks = taskDAO.getAllTasks();
        for (Map<String, Object> task : tasks) {
            writer.printf("%s,\"%s\",%s,%s,%s,%s,%s\n",
                task.get("id"),
                task.get("title"),
                task.get("status"),
                task.get("priority"),
                task.get("wage"),
                task.get("deadline"),
                task.get("category"));
        }
    }

    private void exportWorkers(PrintWriter writer) {
        writer.println("ID,Full Name,Email,Tasks Completed,Rating,Status,Total Earned");
        List<User> workers = userDAO.getAllWorkersWithStats();
        for (User w : workers) {
            writer.printf("%d,\"%s\",%s,%d,%.1f,%s,%.2f\n",
                w.getId(),
                w.getFullName(),
                w.getEmail(),
                w.getTasksCompleted(),
                w.getRating(),
                w.getStatus(),
                w.getTotalEarned());
        }
    }

    private void exportFinancial(PrintWriter writer) {
        writer.println("Worker,Tasks Completed,Total Earned");
        List<Map<String, Object>> summary = wageDAO.getWageSummary();
        for (Map<String, Object> row : summary) {
            writer.printf("\"%s\",%s,%.2f\n",
                row.get("full_name"),
                row.get("tasks_completed"),
                (Double) row.get("total_earned"));
        }
    }

    private void exportTrends(PrintWriter writer) {
        writer.println("Date,Completed,Open,In-Progress");
        List<Map<String, Object>> trends = taskDAO.getTaskTrends();
        for (Map<String, Object> t : trends) {
            writer.printf("%s,%s,%s,%s\n",
                t.get("date"),
                t.get("completed"),
                t.get("open"),
                t.get("in_progress"));
        }
    }
}
