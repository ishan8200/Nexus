<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, com.nex.model.User" %>
<%@ page import="com.nex.dao.TaskDAO, com.nex.dao.UserDAO, com.nex.dao.WageDAO" %>
<%
    // Check if user is logged in and is worker
    HttpSession sessionObj = request.getSession(false);
    User currentUser = (sessionObj != null) ? (User) sessionObj.getAttribute("user") : null;
    
    if (currentUser == null || !"worker".equals(currentUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Initialize DAOs
    TaskDAO taskDAO = new TaskDAO();
    UserDAO userDAO = new UserDAO();
    WageDAO wageDAO = new WageDAO();
    
    int workerId = currentUser.getId();
    
    // Get worker statistics
    Map<String, Object> workerStats = userDAO.getWorkerStats(workerId);
    double totalEarned = (double) workerStats.get("total_earned");
    int tasksCompleted = (int) workerStats.get("tasks_completed");
    double avgRating = (double) workerStats.get("avg_rating");
    double pendingPayment = (double) workerStats.get("pending_payment");
    
    // Get available tasks
    List<Map<String, Object>> availableTasks = taskDAO.getAvailableTasks();
    
    // Get worker's assigned tasks
    List<Map<String, Object>> myTasks = userDAO.getMyTasks(workerId);
    
    // Get earnings breakdown
    List<Map<String, Object>> earningsBreakdown = userDAO.getWorkerEarnings(workerId);
    
    // Get payment history
    List<Map<String, Object>> paymentHistory = wageDAO.getPaymentHistory(workerId);
    
    // Get recent ratings
    List<Map<String, Object>> recentRatings = taskDAO.getWorkerRatings(workerId);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Worker Dashboard | Nexus Works</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:opsz,wght@14..32,300;14..32,400;14..32,500;14..32,600;14..32,700;14..32,800&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <style>
        .page-section { display: none; }
        .page-section.active { display: block; }
        .toast-container { position: fixed; bottom: 20px; right: 20px; z-index: 1000; }
        .modal-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); display: flex; align-items: center; justify-content: center; z-index: 1000; visibility: hidden; opacity: 0; transition: all 0.3s ease; }
        .modal-overlay.active { visibility: visible; opacity: 1; }
        .modal-container { background: white; border-radius: 16px; max-width: 600px; width: 90%; max-height: 85vh; overflow-y: auto; }
        .modal-header { display: flex; justify-content: space-between; align-items: center; padding: 20px; border-bottom: 1px solid #e2e2dc; }
        .modal-close { background: none; border: none; font-size: 24px; cursor: pointer; }
        .modal-body { padding: 20px; }
        .modal-footer { padding: 16px 20px; border-top: 1px solid #e2e2dc; display: flex; justify-content: flex-end; gap: 12px; }
        .file-upload { border: 2px dashed #e2e2dc; border-radius: 8px; padding: 30px; text-align: center; cursor: pointer; transition: all 0.3s ease; }
        .file-upload:hover { border-color: #3b82f6; background: rgba(59,130,246,0.02); }
        .progress-bar { height: 8px; background: #e2e2dc; border-radius: 4px; overflow: hidden; }
        .progress-fill { height: 100%; background: linear-gradient(90deg, #3b82f6, #10b981); border-radius: 4px; transition: width 0.3s ease; }
        .deadline-countdown.urgent { color: #ef4444; font-weight: 600; }
        .deadline-countdown.warning { color: #f59e0b; }
        .deadline-countdown.normal { color: #10b981; }
        .heatmap { display: grid; grid-template-columns: repeat(7, 1fr); gap: 4px; margin-top: 16px; }
        .heatmap-day { aspect-ratio: 1; background: #e2e2dc; border-radius: 2px; transition: all 0.2s ease; }
        .heatmap-day.level-1 { background: rgba(59,130,246,0.2); }
        .heatmap-day.level-2 { background: rgba(59,130,246,0.4); }
        .heatmap-day.level-3 { background: rgba(59,130,246,0.6); }
        .heatmap-day.level-4 { background: rgba(59,130,246,0.8); }
        .heatmap-day.level-5 { background: #3b82f6; }
        .heatmap-day:hover { transform: scale(1.1); }
    </style>
</head>
<body>
    <!-- Top Navigation Bar -->
    <nav class="navbar">
        <div class="nav-container">
            <a href="${pageContext.request.contextPath}/" class="logo">
                <span class="logo-mark">⌘</span>
                <span class="logo-text">NEXUS</span>
            </a>
            <div class="nav-links">
                <a href="${pageContext.request.contextPath}/">Home</a>
                <a href="#" class="active">Dashboard</a>
                <a href="${pageContext.request.contextPath}/logout" class="btn-login-nav">Logout</a>
            </div>
        </div>
    </nav>

    <!-- Worker Layout with Sidebar -->
    <div class="admin-layout">
        <!-- Left Sidebar Navigation -->
        <aside class="admin-sidebar" id="sidebar">
            <div class="sidebar-header">
                <h3>Navigation</h3>
                <div class="admin-profile">
                    <div class="admin-avatar"><%= currentUser.getFullName().charAt(0) %></div>
                    <div class="admin-info">
                        <h4><%= currentUser.getFullName() %></h4>
                        <p>Worker</p>
                    </div>
                </div>
            </div>
            
            <nav class="sidebar-nav">
                <div class="nav-section-title">MAIN</div>
                <a href="#" class="nav-item active" data-page="dashboard">
                    <span class="nav-icon">📊</span>
                    <span class="nav-text">Dashboard</span>
                </a>
                <a href="#" class="nav-item" data-page="available-tasks">
                    <span class="nav-icon">🔍</span>
                    <span class="nav-text">Available Tasks</span>
                    <span class="nav-badge" id="availableTasksBadge"><%= availableTasks.size() %></span>
                </a>
                <a href="#" class="nav-item" data-page="my-tasks">
                    <span class="nav-icon">📋</span>
                    <span class="nav-text">My Tasks</span>
                    <span class="nav-badge" id="myTasksBadge"><%= myTasks.size() %></span>
                </a>
                
                <div class="nav-section-title">FINANCES</div>
                <a href="#" class="nav-item" data-page="earnings">
                    <span class="nav-icon">💰</span>
                    <span class="nav-text">Earnings</span>
                </a>
                <a href="#" class="nav-item" data-page="payment-history">
                    <span class="nav-icon">📜</span>
                    <span class="nav-text">Payment History</span>
                </a>
                
                <div class="nav-section-title">PERFORMANCE</div>
                <a href="#" class="nav-item" data-page="performance">
                    <span class="nav-icon">📈</span>
                    <span class="nav-text">My Performance</span>
                </a>
                <a href="#" class="nav-item" data-page="activity">
                    <span class="nav-icon">🔥</span>
                    <span class="nav-text">Activity</span>
                </a>
                
                <div class="nav-section-title">SETTINGS</div>
                <a href="#" class="nav-item" data-page="profile">
                    <span class="nav-icon">👤</span>
                    <span class="nav-text">Profile</span>
                </a>
            </nav>
        </aside>

        <!-- Mobile Sidebar Toggle -->
        <button class="sidebar-toggle" id="sidebarToggle">☰</button>

        <!-- Main Content Area -->
        <main class="admin-main">
            <div class="admin-main-header">
                <div class="page-title">
                    <div>
                        <h1 id="pageTitle">Worker Dashboard</h1>
                        <p id="pageSubtitle">Welcome back, <%= currentUser.getFullName() %>! Track your tasks and earnings.</p>
                    </div>
                </div>
            </div>

            <!-- Dashboard View -->
            <div id="dashboardView" class="page-section active">
                <!-- Worker Stats -->
                <div class="worker-stats-grid">
                    <div class="worker-stat-card">
                        <div class="worker-stat-header">
                            <span class="worker-stat-icon">💰</span>
                            <span class="worker-stat-label">Total Earned</span>
                        </div>
                        <div class="worker-stat-value">$<%= String.format("%,.0f", totalEarned) %></div>
                        <div class="worker-stat-change">All time earnings</div>
                    </div>
                    <div class="worker-stat-card">
                        <div class="worker-stat-header">
                            <span class="worker-stat-icon">✅</span>
                            <span class="worker-stat-label">Tasks Completed</span>
                        </div>
                        <div class="worker-stat-value"><%= tasksCompleted %></div>
                        <div class="worker-stat-change">Total tasks done</div>
                    </div>
                    <div class="worker-stat-card">
                        <div class="worker-stat-header">
                            <span class="worker-stat-icon">⭐</span>
                            <span class="worker-stat-label">Average Rating</span>
                        </div>
                        <div class="worker-stat-value"><%= String.format("%.1f", avgRating) %></div>
                        <div class="worker-stat-change"><%= avgRating >= 4.5 ? "Top performer" : "Good standing" %></div>
                    </div>
                    <div class="worker-stat-card">
                        <div class="worker-stat-header">
                            <span class="worker-stat-icon">⏳</span>
                            <span class="worker-stat-label">Pending Payment</span>
                        </div>
                        <div class="worker-stat-value">$<%= String.format("%,.0f", pendingPayment) %></div>
                        <div class="worker-stat-change">Awaiting approval</div>
                    </div>
                </div>

                <!-- Quick Actions -->
                <div class="quick-actions">
                    <div class="quick-action-card" onclick="switchToPage('available-tasks')">
                        <div class="quick-action-icon">🔍</div>
                        <div class="quick-action-title">Find New Tasks</div>
                        <div class="quick-action-desc">Browse available work</div>
                    </div>
                    <div class="quick-action-card" onclick="switchToPage('my-tasks')">
                        <div class="quick-action-icon">📋</div>
                        <div class="quick-action-title">My Active Tasks</div>
                        <div class="quick-action-desc">Continue working</div>
                    </div>
                    <div class="quick-action-card" onclick="switchToPage('earnings')">
                        <div class="quick-action-icon">💰</div>
                        <div class="quick-action-title">View Earnings</div>
                        <div class="quick-action-desc">Track your income</div>
                    </div>
                    <div class="quick-action-card" onclick="switchToPage('performance')">
                        <div class="quick-action-icon">📊</div>
                        <div class="quick-action-title">Performance</div>
                        <div class="quick-action-desc">See your stats</div>
                    </div>
                </div>

                <!-- Recent Tasks & Activity -->
                <div class="dashboard-grid">
                    <div class="admin-card">
                        <div class="admin-card-header">
                            <h3>📌 My Active Tasks</h3>
                            <button class="btn-icon" onclick="switchToPage('my-tasks')">View All →</button>
                        </div>
                        <div class="admin-card-body">
                            <div class="my-tasks-list">
                                <% int count = 0; for (Map<String, Object> task : myTasks) { if (count++ >= 3) break; %>
                                <div class="my-task-item">
                                    <div class="my-task-header">
                                        <span class="my-task-title"><%= task.get("title") %></span>
                                        <span class="deadline-countdown warning">⚠️ Due soon</span>
                                    </div>
                                    <div class="task-description"><%= ((String)task.get("description")).length() > 100 ? ((String)task.get("description")).substring(0, 100) + "..." : task.get("description") %></div>
                                    <div class="task-footer">
                                        <span>💰 $<%= task.get("wage") %></span>
                                        <button class="btn-primary" style="padding: 0.25rem 0.75rem;" onclick="showSubmitWorkModal(<%= task.get("id") %>)">Submit Work</button>
                                    </div>
                                </div>
                                <% } %>
                                <% if (myTasks.isEmpty()) { %>
                                <div style="text-align: center; padding: 40px; color: var(--text-muted);">No active tasks. Browse available tasks to get started!</div>
                                <% } %>
                            </div>
                        </div>
                    </div>
                    <div class="admin-card">
                        <div class="admin-card-header">
                            <h3>📊 Recent Earnings</h3>
                            <button class="btn-icon" onclick="switchToPage('earnings')">View All →</button>
                        </div>
                        <div class="admin-card-body">
                            <div class="earnings-timeline">
                                <% List<Map<String, Object>> recentEarnings = wageDAO.getPaymentHistory(workerId); 
                                   int earnCount = 0; for (Map<String, Object> payment : recentEarnings) { if (earnCount++ >= 3) break; %>
                                <div class="earning-item">
                                    <div class="earning-info">
                                        <h4><%= payment.get("description") != null ? payment.get("description") : "Payment" %></h4>
                                        <p>Received on <%= payment.get("payment_date") %></p>
                                    </div>
                                    <div class="earning-amount">$<%= payment.get("amount") %></div>
                                    <div class="earning-status paid">Paid</div>
                                </div>
                                <% } %>
                                <% if (recentEarnings.isEmpty()) { %>
                                <div style="text-align: center; padding: 20px; color: var(--text-muted);">No payment history yet</div>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Available Tasks View -->
            <div id="availableTasksView" class="page-section">
                <div class="filter-bar">
                    <select class="filter-select" id="taskTypeFilter">
                        <option value="all">All Types</option>
                        <option value="fixed">Fixed Price</option>
                        <option value="hourly">Hourly</option>
                    </select>
                    <select class="filter-select" id="sortByFilter">
                        <option value="newest">Newest First</option>
                        <option value="highest">Highest Wage</option>
                        <option value="deadline">Earliest Deadline</option>
                    </select>
                    <input type="text" class="search-input" id="availableTaskSearch" placeholder="Search tasks...">
                </div>

                <div class="available-tasks-grid" id="availableTasksGrid">
                    <% for (Map<String, Object> task : availableTasks) { %>
                    <div class="available-task-card" data-task='<%= new com.google.gson.Gson().toJson(task) %>' onclick="acceptTask(this)">
                        <div class="available-task-header">
                            <span class="available-task-title"><%= task.get("title") %></span>
                            <span class="available-task-wage">$<%= task.get("wage") %>/<%= task.get("wage_type") %></span>
                        </div>
                        <div class="available-task-desc"><%= ((String)task.get("description")).length() > 100 ? ((String)task.get("description")).substring(0, 100) + "..." : task.get("description") %></div>
                        <div class="available-task-meta">
                            <span>📅 Due: <%= task.get("deadline") %></span>
                            <span>⏰ <%= task.get("estimated_hours") %> hrs est.</span>
                        </div>
                        <div class="available-task-footer">
                            <span class="task-priority priority-<%= task.get("priority") %>"><%= task.get("priority") %></span>
                            <button class="btn-primary" style="padding: 0.25rem 0.75rem;" onclick="event.stopPropagation(); acceptTaskFromId(<%= task.get("id") %>, '<%= task.get("title") %>', <%= task.get("wage") %>, '<%= task.get("deadline") %>', '<%= task.get("description") %>')">Accept Task →</button>
                        </div>
                    </div>
                    <% } %>
                    <% if (availableTasks.isEmpty()) { %>
                    <div style="text-align: center; padding: 60px; color: var(--text-muted); grid-column: 1/-1;">No available tasks at the moment. Check back later!</div>
                    <% } %>
                </div>
            </div>

            <!-- My Tasks View -->
            <div id="myTasksView" class="page-section">
                <div class="my-tasks-list" id="myTasksList">
                    <% for (Map<String, Object> task : myTasks) { %>
                    <div class="my-task-item" data-task-id="<%= task.get("id") %>">
                        <div class="my-task-header">
                            <span class="my-task-title"><%= task.get("title") %></span>
                            <span class="deadline-countdown normal">📅 Status: <%= task.get("status") %></span>
                        </div>
                        <div class="task-description"><%= task.get("description") %></div>
                        <div class="task-footer">
                            <span>💰 $<%= task.get("wage") %></span>
                            <div>
                                <% if (!"pending".equals(task.get("submission_status"))) { %>
                                <button class="btn-primary" style="padding: 0.25rem 0.75rem; margin-right: 0.5rem;" onclick="showSubmitWorkModal(<%= task.get("id") %>)">Submit Work</button>
                                <% } else { %>
                                <button class="btn-secondary" style="padding: 0.25rem 0.75rem; margin-right: 0.5rem;" disabled>Pending Review</button>
                                <% } %>
                                <button class="btn-secondary" style="padding: 0.25rem 0.75rem;" onclick="viewTaskDetails(<%= task.get("id") %>)">Details</button>
                            </div>
                        </div>
                    </div>
                    <% } %>
                    <% if (myTasks.isEmpty()) { %>
                    <div style="text-align: center; padding: 60px; color: var(--text-muted);">You haven't accepted any tasks yet. Browse available tasks to get started!</div>
                    <% } %>
                </div>
            </div>

            <!-- Earnings View -->
            <div id="earningsView" class="page-section">
                <div class="worker-stats-grid">
                    <div class="worker-stat-card">
                        <div class="worker-stat-header"><span class="worker-stat-icon">💰</span><span class="worker-stat-label">Total Earned</span></div>
                        <div class="worker-stat-value">$<%= String.format("%,.0f", totalEarned) %></div>
                    </div>
                    <div class="worker-stat-card">
                        <div class="worker-stat-header"><span class="worker-stat-icon">✅</span><span class="worker-stat-label">Tasks Completed</span></div>
                        <div class="worker-stat-value"><%= tasksCompleted %></div>
                    </div>
                    <div class="worker-stat-card">
                        <div class="worker-stat-header"><span class="worker-stat-icon">⭐</span><span class="worker-stat-label">Avg Rating</span></div>
                        <div class="worker-stat-value"><%= String.format("%.1f", avgRating) %></div>
                    </div>
                    <div class="worker-stat-card">
                        <div class="worker-stat-header"><span class="worker-stat-icon">⏳</span><span class="worker-stat-label">Pending Payment</span></div>
                        <div class="worker-stat-value">$<%= String.format("%,.0f", pendingPayment) %></div>
                    </div>
                </div>
                <div class="admin-card">
                    <div class="admin-card-header"><h3>📜 Earnings Breakdown</h3></div>
                    <div class="admin-card-body">
                        <div class="earnings-timeline" id="earningsList">
                            <% for (Map<String, Object> earning : earningsBreakdown) { %>
                            <div class="earning-item">
                                <div class="earning-info">
                                    <h4>Monthly Summary</h4>
                                    <p><%= earning.get("month") %></p>
                                </div>
                                <div class="earning-amount">$<%= earning.get("total_amount") %></div>
                                <div class="earning-status paid"><%= earning.get("task_count") %> tasks</div>
                            </div>
                            <% } %>
                            <% if (earningsBreakdown.isEmpty()) { %>
                            <div style="text-align: center; padding: 40px; color: var(--text-muted);">No earnings data available yet</div>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Payment History View -->
            <div id="paymentHistoryView" class="page-section">
                <div class="admin-card">
                    <div class="admin-card-header"><h3>💰 Payment History</h3></div>
                    <div class="admin-card-body">
                        <table class="admin-table">
                            <thead>
                                <tr><th>Date</th><th>Description</th><th>Amount</th><th>Method</th><th>Transaction ID</th><th>Status</th></tr>
                            </thead>
                            <tbody>
                                <% for (Map<String, Object> payment : paymentHistory) { %>
                                <tr>
                                    <td><%= payment.get("payment_date") %></td>
                                    <td><%= payment.get("description") != null ? payment.get("description") : "Payment" %></td>
                                    <td>$${payment.get("amount")}</td>
                                    <td><%= payment.get("payment_method") != null ? payment.get("payment_method") : "-" %></td>
                                    <td class="text-muted"><%= payment.get("transaction_id") != null ? payment.get("transaction_id") : "-" %></td>
                                    <td><span class="status-badge paid">Completed</span></td>
                                </tr>
                                <% } %>
                                <% if (paymentHistory.isEmpty()) { %>
                                <tr><td colspan="6" style="text-align: center;">No payment history available</td></tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Performance View -->
            <div id="performanceView" class="page-section">
                <div class="performance-grid">
                    <div class="performance-card"><div class="performance-value"><%= tasksCompleted %></div><div class="performance-label">Tasks Completed</div></div>
                    <div class="performance-card"><div class="performance-value"><%= String.format("%.1f", avgRating) %></div><div class="performance-label">Avg Rating ★</div></div>
                    <div class="performance-card"><div class="performance-value"><%= tasksCompleted > 0 ? Math.round((double)tasksCompleted / (tasksCompleted + (myTasks.size() - tasksCompleted)) * 100) : 0 %>%</div><div class="performance-label">Completion Rate</div></div>
                    <div class="performance-card"><div class="performance-value">0</div><div class="performance-label">Late Submissions</div></div>
                </div>
                <div class="admin-card">
                    <div class="admin-card-header"><h3>⭐ Recent Ratings</h3></div>
                    <div class="admin-card-body">
                        <div class="earnings-timeline" id="recentRatingsList">
                            <% List<Map<String, Object>> ratings = taskDAO.getWorkerRatings(workerId);
                               for (Map<String, Object> rating : ratings) { %>
                            <div class="earning-item">
                                <div class="earning-info">
                                    <h4><%= rating.get("task_title") %></h4>
                                    <p>Completed on <%= rating.get("reviewed_at") %></p>
                                </div>
                                <div class="rating-display">
                                    <span class="rating-score"><%= rating.get("rating") %>.0</span>
                                    <span><% for (int i = 1; i <= (int)rating.get("rating"); i++) { %>★<% } %><% for (int i = (int)rating.get("rating") + 1; i <= 5; i++) { %>☆<% } %></span>
                                </div>
                            </div>
                            <% } %>
                            <% if (ratings.isEmpty()) { %>
                            <div style="text-align: center; padding: 40px; color: var(--text-muted);">No ratings received yet</div>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Activity View -->
            <div id="activityView" class="page-section">
                <div class="admin-card">
                    <div class="admin-card-header"><h3>🔥 Weekly Activity</h3></div>
                    <div class="admin-card-body">
                        <div class="heatmap" id="activityHeatmap"></div>
                        <div class="earnings-timeline" style="margin-top: 24px;" id="activityLog">
                            <!-- Activity log will be loaded via AJAX -->
                            <div style="text-align: center; padding: 20px; color: var(--text-muted);">Loading activity...</div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Profile View -->
            <div id="profileView" class="page-section">
                <div class="admin-card" style="max-width: 600px; margin: 0 auto;">
                    <div class="admin-card-header"><h3>👤 My Profile</h3></div>
                    <div class="admin-card-body">
                        <form id="profileForm" action="${pageContext.request.contextPath}/UpdateProfileServlet" method="POST">
                            <div style="text-align: center; margin-bottom: 24px;">
                                <div class="admin-avatar" style="width: 80px; height: 80px; font-size: 2rem; margin: 0 auto; background: linear-gradient(135deg, #3b82f6, #2563eb); color: white; display: flex; align-items: center; justify-content: center; border-radius: 16px;">
                                    <%= currentUser.getFullName().charAt(0) %>
                                </div>
                                <h3 style="margin-top: 16px;"><%= currentUser.getFullName() %></h3>
                                <p class="text-muted">Worker since <%= currentUser.getCreatedAt() != null ? currentUser.getCreatedAt().toString().substring(0, 10) : "2025" %></p>
                            </div>
                            <div class="form-group">
                                <label class="form-label">Full Name</label>
                                <input type="text" class="input-field" name="fullName" value="<%= currentUser.getFullName() %>">
                            </div>
                            <div class="form-group">
                                <label class="form-label">Email</label>
                                <input type="email" class="input-field" name="email" value="<%= currentUser.getEmail() %>">
                            </div>
                            <div class="form-group">
                                <label class="form-label">Phone</label>
                                <input type="tel" class="input-field" name="phone" value="<%= currentUser.getPhone() != null ? currentUser.getPhone() : "" %>">
                            </div>
                            <div class="form-group">
                                <label class="form-label">Skills</label>
                                <input type="text" class="input-field" name="skills" value="<%= currentUser.getSkills() != null ? currentUser.getSkills() : "" %>" placeholder="Web Design, UI/UX, Figma">
                            </div>
                            <div style="display: flex; gap: 12px;">
                                <button type="submit" class="btn-primary">Save Changes</button>
                                <button type="button" class="btn-secondary" onclick="showChangePasswordModal()">Change Password</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <!-- Submit Work Modal -->
    <div id="submitWorkModal" class="modal-overlay">
        <div class="modal-container">
            <div class="modal-header">
                <h3 id="submitTaskTitle">Submit Work</h3>
                <button class="modal-close" onclick="closeModal('submitWorkModal')">&times;</button>
            </div>
            <div class="modal-body">
                <form id="submitForm" action="${pageContext.request.contextPath}/SubmitWorkServlet" method="POST" enctype="multipart/form-data">
                    <input type="hidden" name="taskId" id="submitTaskId">
                    <div class="form-group">
                        <label class="form-label">Work Description / Notes *</label>
                        <textarea class="textarea-field" name="submissionText" id="workDescription" rows="5" placeholder="Describe what you've completed. Include details about your work..." required></textarea>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Hours Worked (if hourly)</label>
                        <input type="number" step="0.5" class="input-field" name="hoursWorked" placeholder="0.00">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Attach Proof</label>
                        <div class="file-upload" onclick="document.getElementById('proofFile').click()">
                            <span>📎 Click to upload files</span>
                            <input type="file" name="attachment" id="proofFile" style="display: none;" onchange="updateFileName(this)">
                        </div>
                        <div class="file-name" id="fileName">No files selected</div>
                    </div>
                    <div style="display: flex; gap: 12px; justify-content: flex-end; margin-top: 20px;">
                        <button type="button" class="btn-secondary" onclick="closeModal('submitWorkModal')">Cancel</button>
                        <button type="submit" class="btn-primary">Submit Work</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Change Password Modal -->
    <div id="changePasswordModal" class="modal-overlay">
        <div class="modal-container">
            <div class="modal-header">
                <h3>Change Password</h3>
                <button class="modal-close" onclick="closeModal('changePasswordModal')">&times;</button>
            </div>
            <div class="modal-body">
                <form id="passwordForm" action="${pageContext.request.contextPath}/ChangePasswordServlet" method="POST">
                    <div class="form-group">
                        <label class="form-label">Current Password</label>
                        <input type="password" class="input-field" name="currentPassword" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">New Password</label>
                        <input type="password" class="input-field" name="newPassword" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Confirm New Password</label>
                        <input type="password" class="input-field" name="confirmPassword" required>
                    </div>
                    <div style="display: flex; gap: 12px; justify-content: flex-end; margin-top: 20px;">
                        <button type="button" class="btn-secondary" onclick="closeModal('changePasswordModal')">Cancel</button>
                        <button type="submit" class="btn-primary">Update Password</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        // Task data from server
        const availableTasksData = <%= new com.google.gson.Gson().toJson(availableTasks) %>;
        const myTasksData = <%= new com.google.gson.Gson().toJson(myTasks) %>;
        let currentTaskId = null;
        
        // Render available tasks with filters
        function renderAvailableTasks() {
            const grid = document.getElementById('availableTasksGrid');
            const typeFilter = document.getElementById('taskTypeFilter').value;
            const sortBy = document.getElementById('sortByFilter').value;
            const searchTerm = document.getElementById('availableTaskSearch').value.toLowerCase();
            
            let filtered = availableTasksData.filter(task => {
                if (typeFilter !== 'all' && task.wageType !== typeFilter) return false;
                if (searchTerm && !task.title.toLowerCase().includes(searchTerm)) return false;
                return true;
            });
            
            if (sortBy === 'highest') filtered.sort((a,b) => b.wage - a.wage);
            else if (sortBy === 'deadline') filtered.sort((a,b) => new Date(a.deadline) - new Date(b.deadline));
            
            if (filtered.length === 0) {
                grid.innerHTML = '<div style="text-align: center; padding: 60px; color: var(--text-muted); grid-column: 1/-1;">No tasks match your filters</div>';
                return;
            }
            
            grid.innerHTML = filtered.map(task => `
                <div class="available-task-card" onclick="acceptTaskFromId(${task.id}, '${task.title}', ${task.wage}, '${task.deadline}', '${task.description.replace(/'/g, "\\'")}')">
                    <div class="available-task-header">
                        <span class="available-task-title">${task.title}</span>
                        <span class="available-task-wage">$${task.wage}/${task.wageType}</span>
                    </div>
                    <div class="available-task-desc">${task.description.substring(0, 100)}${task.description.length > 100 ? '...' : ''}</div>
                    <div class="available-task-meta">
                        <span>📅 Due: ${task.deadline}</span>
                        <span>⏰ ${task.estimatedHours || 0} hrs est.</span>
                    </div>
                    <div class="available-task-footer">
                        <span class="task-priority priority-${task.priority}">${task.priority}</span>
                        <button class="btn-primary" style="padding: 0.25rem 0.75rem;" onclick="event.stopPropagation(); acceptTaskFromId(${task.id}, '${task.title}', ${task.wage}, '${task.deadline}', '${task.description.replace(/'/g, "\\'")}')">Accept Task →</button>
                    </div>
                </div>
            `).join('');
            document.getElementById('availableTasksBadge').textContent = filtered.length;
        }
        
        // Accept task from ID
        function acceptTaskFromId(taskId, title, wage, deadline, description) {
            if (confirm(`Accept "${title}"? Wage: $${wage}. Deadline: ${deadline}`)) {
                fetch('${pageContext.request.contextPath}/AcceptTaskServlet', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: 'taskId=' + taskId
                })
                .then(response => response.json())
                .then(result => {
                    if (result.success) {
                        showToast(`Task "${title}" accepted!`, 'success');
                        setTimeout(() => location.reload(), 1500);
                    } else {
                        showToast(result.message || 'Failed to accept task', 'error');
                    }
                })
                .catch(error => {
                    showToast('Error accepting task', 'error');
                });
            }
        }
        
        // Show submit work modal
        function showSubmitWorkModal(taskId) {
            currentTaskId = taskId;
            document.getElementById('submitTaskId').value = taskId;
            document.getElementById('submitTaskTitle').textContent = `Submit Work for Task #${taskId}`;
            document.getElementById('workDescription').value = '';
            document.getElementById('fileName').textContent = 'No files selected';
            document.getElementById('submitWorkModal').classList.add('active');
        }
        
        // Update file name display
        function updateFileName(input) {
            document.getElementById('fileName').textContent = input.files.length + ' file(s) selected';
        }
        
        // View task details
        function viewTaskDetails(taskId) {
            const task = myTasksData.find(t => t.id == taskId);
            if (task) {
                showToast(`Task: ${task.title}`, 'info');
            }
        }
        
        // Show change password modal
        function showChangePasswordModal() {
            document.getElementById('changePasswordModal').classList.add('active');
        }
        
        // Page switching
        function switchToPage(page) {
            document.querySelectorAll('.page-section').forEach(section => section.classList.remove('active'));
            document.getElementById(page + 'View').classList.add('active');
            document.querySelectorAll('.nav-item').forEach(item => item.classList.remove('active'));
            document.querySelector(`.nav-item[data-page="${page}"]`).classList.add('active');
            
            const titles = {
                dashboard: { title: 'Worker Dashboard', subtitle: 'Welcome back, <%= currentUser.getFullName() %>! Track your tasks and earnings.' },
                'available-tasks': { title: 'Available Tasks', subtitle: 'Find and accept tasks that match your skills.' },
                'my-tasks': { title: 'My Tasks', subtitle: 'Track your active tasks and submit work.' },
                earnings: { title: 'My Earnings', subtitle: 'Track your income and payment status.' },
                'payment-history': { title: 'Payment History', subtitle: 'View all your past payments.' },
                performance: { title: 'My Performance', subtitle: 'See your ratings and performance metrics.' },
                activity: { title: 'Activity Log', subtitle: 'Track your work activity and submissions.' },
                profile: { title: 'My Profile', subtitle: 'Manage your personal information.' }
            };
            
            const current = titles[page] || titles.dashboard;
            document.getElementById('pageTitle').textContent = current.title;
            document.getElementById('pageSubtitle').textContent = current.subtitle;
            
            if (page === 'available-tasks') renderAvailableTasks();
            else if (page === 'activity') loadActivity();
        }
        
        // Load activity data
        function loadActivity() {
            fetch('${pageContext.request.contextPath}/GetActivityServlet')
                .then(response => response.json())
                .then(data => {
                    // Render heatmap
                    const heatmap = document.getElementById('activityHeatmap');
                    if (data.heatmap) {
                        heatmap.innerHTML = data.heatmap.map(level => `<div class="heatmap-day level-${level}"></div>`).join('');
                    }
                    
                    // Render activity log
                    const logContainer = document.getElementById('activityLog');
                    if (data.activities && data.activities.length > 0) {
                        logContainer.innerHTML = data.activities.map(activity => `
                            <div class="earning-item">
                                <div class="earning-info">
                                    <h4>${activity.title}</h4>
                                    <p>${activity.date}</p>
                                </div>
                                <div class="earning-status ${activity.type}">${activity.status}</div>
                            </div>
                        `).join('');
                    } else {
                        logContainer.innerHTML = '<div style="text-align: center; padding: 20px; color: var(--text-muted);">No recent activity</div>';
                    }
                })
                .catch(() => {
                    document.getElementById('activityLog').innerHTML = '<div style="text-align: center; padding: 20px; color: var(--text-muted);">Unable to load activity data</div>';
                });
        }
        
        // Toast notification
        function showToast(message, type = 'info') {
            let container = document.querySelector('.toast-container');
            if (!container) {
                container = document.createElement('div');
                container.className = 'toast-container';
                container.style.cssText = 'position: fixed; bottom: 20px; right: 20px; z-index: 1000;';
                document.body.appendChild(container);
            }
            const toast = document.createElement('div');
            toast.className = `alert alert-${type}`;
            toast.style.cssText = 'margin-bottom: 10px; animation: slideIn 0.3s ease; cursor: pointer;';
            toast.innerHTML = `<span>${type === 'success' ? '✓' : (type === 'error' ? '⚠️' : 'ℹ️')}</span><span>${message}</span>`;
            container.appendChild(toast);
            setTimeout(() => { toast.style.opacity = '0'; setTimeout(() => toast.remove(), 300); }, 3000);
            toast.onclick = () => { toast.style.opacity = '0'; setTimeout(() => toast.remove(), 300); };
        }
        
        function closeModal(modalId) { document.getElementById(modalId).classList.remove('active'); }
        
        // Mobile sidebar toggle
        document.getElementById('sidebarToggle').addEventListener('click', () => { document.getElementById('sidebar').classList.toggle('open'); });
        document.addEventListener('click', (e) => { const sidebar = document.getElementById('sidebar'); const toggle = document.getElementById('sidebarToggle'); if (window.innerWidth <= 768 && sidebar.classList.contains('open') && !sidebar.contains(e.target) && !toggle.contains(e.target)) sidebar.classList.remove('open'); });
        
        // Filter event listeners
        document.getElementById('taskTypeFilter')?.addEventListener('change', renderAvailableTasks);
        document.getElementById('sortByFilter')?.addEventListener('change', renderAvailableTasks);
        document.getElementById('availableTaskSearch')?.addEventListener('input', renderAvailableTasks);
        
        // Sidebar navigation
        document.querySelectorAll('.sidebar-nav .nav-item').forEach(item => {
            item.addEventListener('click', function(e) {
                e.preventDefault();
                switchToPage(this.getAttribute('data-page'));
            });
        });
        
        // Initial render
        renderAvailableTasks();
        
        // Show success message if redirected
        const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.get('success') === 'submitted') {
            showToast('Work submitted successfully! Waiting for admin approval.', 'success');
        }
    </script>
</body>
</html>