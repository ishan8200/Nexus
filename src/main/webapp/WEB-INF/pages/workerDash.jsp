<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, com.nex.model.User" %>
<%
    // Check if user is logged in and is a worker
    User currentUser = (User) request.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    List<Map<String, Object>> availableTasks = (List<Map<String, Object>>) request.getAttribute("availableTasks");
    List<Map<String, Object>> myTasks = (List<Map<String, Object>>) request.getAttribute("myTasks");
    List<Map<String, Object>> earningsHistory = (List<Map<String, Object>>) request.getAttribute("earningsHistory");
    List<Map<String, Object>> allSkills = (List<Map<String, Object>>) request.getAttribute("allSkills");
    List<Map<String, Object>> workerSkills = (List<Map<String, Object>>) request.getAttribute("workerSkills");
    List<Map<String, Object>> performance = (List<Map<String, Object>>) request.getAttribute("performance");
    
    // Stats
    Double totalEarned = (Double) request.getAttribute("totalEarned");
    Integer tasksCompleted = (Integer) request.getAttribute("tasksCompleted");
    Double avgRating = (Double) request.getAttribute("avgRating");
    Double pendingPayment = (Double) request.getAttribute("pendingPayment");
    
    // Formatter for currency
    java.text.NumberFormat cur = java.text.NumberFormat.getCurrencyInstance(Locale.US);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Worker Dashboard | Nexus Works</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:opsz,wght@14..32,300;14..32,400;14..32,500;14..32,600;14..32,700;14..32,800&family=JetBrains+Mono:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <script src="${pageContext.request.contextPath}/js/alert.js"></script>
    <style>
        /* Custom overrides for dashboard specific elements */
        .admin-main {
            scroll-behavior: smooth;
        }
        .nav-badge {
            background: var(--nexus-accent);
            color: white;
            padding: 2px 8px;
            border-radius: 10px;
            font-size: 10px;
            font-weight: 700;
            margin-left: auto;
        }
        .worker-stat-card {
            background: white;
            border: 1px solid var(--nexus-border);
            border-radius: var(--radius-lg);
            padding: var(--space-lg);
            transition: all var(--transition-smooth);
            position: relative;
            overflow: hidden;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.02);
        }
        .worker-stat-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 20px rgba(0, 0, 0, 0.05);
            border-color: var(--nexus-accent-glow);
        }
        .worker-stat-card::before {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            height: 100%;
            width: 4px;
            background: var(--nexus-accent);
        }
        .worker-stat-header {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 12px;
        }
        .worker-stat-icon {
            font-size: 24px;
        }
        .worker-stat-label {
            font-size: 12px;
            font-weight: 600;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }
        .worker-stat-value {
            font-size: 28px;
            font-weight: 800;
            color: var(--text-primary);
            font-family: 'JetBrains Mono', monospace;
        }
        .worker-stat-change {
            font-size: 11px;
            margin-top: 8px;
            color: var(--nexus-success);
            font-weight: 600;
        }
        .page-section {
            display: none;
            animation: fadeIn 0.4s ease-out;
        }
        .page-section.active {
            display: block;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .task-card-improved {
            display: flex;
            flex-direction: column;
            gap: 16px;
            padding: 24px;
            background: white;
            border: 1px solid var(--nexus-border);
            border-radius: var(--radius-lg);
            transition: all 0.3s ease;
        }
        .task-card-improved:hover {
            border-color: var(--nexus-accent);
            box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.05);
        }
        .task-priority-tag {
            font-size: 10px;
            font-weight: 700;
            padding: 4px 10px;
            border-radius: 20px;
            text-transform: uppercase;
            width: fit-content;
        }
        .tag-high { background: var(--nexus-danger-light); color: var(--nexus-danger); }
        .tag-medium { background: var(--nexus-warning-light); color: var(--nexus-warning); }
        .tag-low { background: var(--nexus-success-light); color: var(--nexus-success); }
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

    <!-- Worker Layout -->
    <div class="admin-layout">
        <!-- Sidebar -->
        <aside class="admin-sidebar" id="sidebar">
            <div class="sidebar-header">
                <h3>Navigation</h3>
                <div class="admin-profile">
                    <div class="admin-avatar"><%= currentUser.getFullName().substring(0, 1).toUpperCase() %></div>
                    <div class="admin-info">
                        <h4><%= currentUser.getFullName() %></h4>
                        <p><%= currentUser.getRole().substring(0, 1).toUpperCase() + currentUser.getRole().substring(1) %></p>
                    </div>
                </div>
            </div>
            
            <nav class="sidebar-nav">
                <div class="nav-section-title">MAIN</div>
                <a href="javascript:void(0)" class="nav-item active" onclick="switchToPage('dashboard')">
                    <span class="nav-icon">📊</span>
                    <span class="nav-text">Dashboard</span>
                </a>
                <a href="javascript:void(0)" class="nav-item" onclick="switchToPage('notifications')">
                    <span class="nav-icon">🔔</span>
                    <span class="nav-text">Notifications</span>
                    <% 
                        List<Map<String, Object>> notifs = (List<Map<String, Object>>) request.getAttribute("notifications");
                        long unreadCount = notifs != null ? notifs.stream().filter(n -> !(boolean)n.get("is_read")).count() : 0;
                        if (unreadCount > 0) {
                    %>
                    <span class="nav-badge"><%= unreadCount %></span>
                    <% } %>
                </a>
                <a href="javascript:void(0)" class="nav-item" onclick="switchToPage('available-tasks')">
                    <span class="nav-icon">🔍</span>
                    <span class="nav-text">Available Tasks</span>
                    <span class="nav-badge"><%= availableTasks != null ? availableTasks.size() : 0 %></span>
                </a>
                <a href="javascript:void(0)" class="nav-item" onclick="switchToPage('my-tasks')">
                    <span class="nav-icon">📋</span>
                    <span class="nav-text">My Tasks</span>
                    <span class="nav-badge"><%= myTasks != null ? myTasks.size() : 0 %></span>
                </a>
                <a href="javascript:void(0)" class="nav-item" onclick="switchToPage('my-performance')">
                    <span class="nav-icon">📈</span>
                    <span class="nav-text">My Performance</span>
                </a>
                <a href="javascript:void(0)" class="nav-item" onclick="switchToPage('my-skills')">
                    <span class="nav-icon">🛠️</span>
                    <span class="nav-text">My Skills</span>
                    <span class="nav-badge"><%= workerSkills != null ? workerSkills.size() : 0 %></span>
                </a>
                
                <div class="nav-section-title">FINANCES</div>
                <a href="javascript:void(0)" class="nav-item" onclick="switchToPage('earnings')">
                    <span class="nav-icon">💰</span>
                    <span class="nav-text">Earnings History</span>
                </a>
                
                <div class="nav-section-title">ACCOUNT</div>
                <a href="javascript:void(0)" class="nav-item" onclick="switchToPage('profile')">
                    <span class="nav-icon">👤</span>
                    <span class="nav-text">My Profile</span>
                </a>
            </nav>
        </aside>

        <!-- Main Content -->
        <main class="admin-main">
            <div id="alertContainer"></div>

            <div class="admin-main-header">
                <div class="page-title">
                    <div>
                        <h1 id="pageTitle">Worker Dashboard</h1>
                        <p id="pageSubtitle">Welcome back, <%= currentUser.getFullName().split(" ")[0] %>! Track your tasks and performance.</p>
                    </div>
                </div>
            </div>

            <!-- Dashboard View -->
            <div id="dashboardView" class="page-section active">
                <div class="worker-stats-grid">
                    <div class="worker-stat-card">
                        <div class="worker-stat-header">
                            <span class="worker-stat-icon">💰</span>
                            <span class="worker-stat-label">Total Earned</span>
                        </div>
                        <div class="worker-stat-value"><%= cur.format(totalEarned != null ? totalEarned : 0) %></div>
                        <div class="worker-stat-change">Life-time earnings</div>
                    </div>
                    <div class="worker-stat-card">
                        <div class="worker-stat-header">
                            <span class="worker-stat-icon">✅</span>
                            <span class="worker-stat-label">Tasks Done</span>
                        </div>
                        <div class="worker-stat-value"><%= tasksCompleted != null ? tasksCompleted : 0 %></div>
                        <div class="worker-stat-change">Completed missions</div>
                    </div>
                    <div class="worker-stat-card">
                        <div class="worker-stat-header">
                            <span class="worker-stat-icon">⭐</span>
                            <span class="worker-stat-label">Rating</span>
                        </div>
                        <div class="worker-stat-value"><%= avgRating != null ? String.format("%.1f", avgRating) : "0.0" %></div>
                        <div class="worker-stat-change">Quality score</div>
                    </div>
                    <div class="worker-stat-card">
                        <div class="worker-stat-header">
                            <span class="worker-stat-icon">⏳</span>
                            <span class="worker-stat-label">Pending</span>
                        </div>
                        <div class="worker-stat-value"><%= cur.format(pendingPayment != null ? pendingPayment : 0) %></div>
                        <div class="worker-stat-change">Awaiting approval</div>
                    </div>
                </div>

                <div class="dashboard-grid">
                    <div class="admin-card">
                        <div class="admin-card-header">
                            <h3>📌 Active Deliverables</h3>
                            <button class="btn-icon" onclick="switchToPage('my-tasks')">View All →</button>
                        </div>
                        <div class="admin-card-body">
                            <% if (myTasks != null && !myTasks.isEmpty()) { %>
                                <% for (int i = 0; i < Math.min(myTasks.size(), 3); i++) { 
                                    Map<String, Object> task = myTasks.get(i);
                                %>
                                <div style="padding: 15px; border-bottom: 1px solid var(--nexus-border); display: flex; justify-content: space-between; align-items: center;">
                                    <div>
                                        <h4 style="font-weight: 600; margin-bottom: 4px;"><%= task.get("title") %></h4>
                                        <p style="font-size: 12px; color: var(--text-muted);">Due: <%= task.get("deadline") %></p>
                                    </div>
                                    <div style="text-align: right;">
                                        <p style="font-weight: 700; color: var(--nexus-accent);"><%= cur.format(task.get("wage")) %></p>
                                        <p style="font-size: 10px; color: var(--text-light);"><%= task.get("status") %></p>
                                    </div>
                                </div>
                                <% } %>
                            <% } else { %>
                                <div style="padding: 40px; text-align: center; color: var(--text-muted);">
                                    <p>No active tasks. Time to find some work!</p>
                                    <button class="btn btn-outline" style="margin-top: 15px;" onclick="switchToPage('available-tasks')">Browse Tasks</button>
                                </div>
                            <% } %>
                        </div>
                    </div>

                    <div class="admin-card">
                        <div class="admin-card-header">
                            <h3>📜 Recent Activity</h3>
                        </div>
                        <div class="admin-card-body">
                            <% if (earningsHistory != null && !earningsHistory.isEmpty()) { %>
                                <% for (int i = 0; i < Math.min(earningsHistory.size(), 5); i++) { 
                                    Map<String, Object> entry = earningsHistory.get(i);
                                %>
                                <div style="padding: 12px; border-bottom: 1px solid var(--nexus-border); display: flex; gap: 15px; align-items: center;">
                                    <div style="font-size: 20px;">💰</div>
                                    <div style="flex: 1;">
                                        <h4 style="font-weight: 600; font-size: 14px;">Earned in <%= entry.get("month") %></h4>
                                        <p style="font-size: 11px; color: var(--text-muted);"><%= entry.get("task_count") %> tasks finalized</p>
                                    </div>
                                    <div style="font-weight: 700; color: var(--nexus-success); font-family: 'JetBrains Mono';">
                                        +<%= cur.format(entry.get("total_amount")) %>
                                    </div>
                                </div>
                                <% } %>
                            <% } else { %>
                                <div style="padding: 40px; text-align: center; color: var(--text-muted);">
                                    <p>No recent earnings records found.</p>
                                </div>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Available Tasks View -->
            <div id="availableTasksView" class="page-section">
                <div class="grid-2">
                    <% if (availableTasks != null && !availableTasks.isEmpty()) { %>
                        <% for (Map<String, Object> task : availableTasks) { %>
                            <div class="task-card-improved">
                                <div style="display: flex; justify-content: space-between; align-items: flex-start;">
                                    <% 
                                        String priority = (String) task.get("priority");
                                        String tagClass = "tag-low";
                                        if ("High".equalsIgnoreCase(priority)) tagClass = "tag-high";
                                        else if ("Medium".equalsIgnoreCase(priority)) tagClass = "tag-medium";
                                    %>
                                    <span class="task-priority-tag <%= tagClass %>"><%= priority %></span>
                                    <span style="font-family: 'JetBrains Mono'; font-weight: 700; color: var(--nexus-accent); font-size: 18px;">
                                        <%= cur.format(task.get("wage")) %>
                                    </span>
                                </div>
                                <h3 style="font-size: 18px; font-weight: 700;"><%= task.get("title") %></h3>
                                <p style="font-size: 14px; color: var(--text-secondary); line-height: 1.5; flex: 1;">
                                    <%= task.get("description") %>
                                </p>
                                <div style="display: flex; justify-content: space-between; align-items: center; padding-top: 15px; border-top: 1px solid var(--nexus-border);">
                                    <div style="font-size: 12px; color: var(--text-muted);">
                                        📅 Deadline: <%= task.get("deadline") %>
                                    </div>
                                    <form action="${pageContext.request.contextPath}/accept-task" method="POST" style="margin: 0;">
                                        <input type="hidden" name="taskId" value="<%= task.get("id") %>">
                                        <button type="submit" class="btn btn-primary" style="padding: 8px 16px;">Accept Task →</button>
                                    </form>
                                </div>
                            </div>
                        <% } %>
                    <% } else { %>
                        <div style="grid-column: span 2; padding: 100px; text-align: center; background: white; border-radius: var(--radius-lg); border: 1px dashed var(--nexus-border);">
                            <h2 style="color: var(--text-light); margin-bottom: 10px;">No available tasks found</h2>
                            <p style="color: var(--text-muted);">Check back later for new opportunities.</p>
                        </div>
                    <% } %>
                </div>
            </div>

            <!-- My Tasks View -->
            <div id="myTasksView" class="page-section">
                <div class="admin-card">
                    <div class="admin-card-header">
                        <h3>📋 Assigned Deliverables</h3>
                    </div>
                    <div class="admin-card-body" style="padding: 0;">
                        <table class="admin-table">
                            <thead>
                                <tr>
                                    <th>Task Title</th>
                                    <th>Deadline</th>
                                    <th>Wage</th>
                                    <th>Status</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (myTasks != null && !myTasks.isEmpty()) { %>
                                    <% for (Map<String, Object> task : myTasks) { %>
                                        <tr>
                                            <td style="font-weight: 600;"><%= task.get("title") %></td>
                                            <td><%= task.get("deadline") %></td>
                                            <td style="font-family: 'JetBrains Mono'; font-weight: 700;"><%= cur.format(task.get("wage")) %></td>
                                            <td>
                                                <% String status = (String) task.get("status"); %>
                                                <span class="status-badge <%= status.toLowerCase().replace(" ", "-") %>">
                                                    <%= status %>
                                                </span>
                                            </td>
                                            <td>
                                                <button class="btn btn-secondary" style="padding: 5px 10px; font-size: 12px;">Submit Work</button>
                                            </td>
                                        </tr>
                                    <% } %>
                                <% } else { %>
                                    <tr>
                                        <td colspan="5" style="text-align: center; padding: 50px; color: var(--text-muted);">No tasks assigned to you.</td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- My Performance View -->
            <div id="my-performanceView" class="page-section">
                <div class="admin-card">
                    <div class="admin-card-header">
                        <h3>📈 Task Performance & Ratings</h3>
                    </div>
                    <div class="admin-card-body" style="padding: 0;">
                        <table class="admin-table">
                            <thead>
                                <tr>
                                    <th>Task Title</th>
                                    <th>Completion Date</th>
                                    <th>Wage Earned</th>
                                    <th>Rating</th>
                                    <th>Feedback</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (performance != null && !performance.isEmpty()) { %>
                                    <% for (Map<String, Object> record : performance) { %>
                                        <tr>
                                            <td style="font-weight: 600;"><%= record.get("title") %></td>
                                            <td><%= record.get("date") %></td>
                                            <td style="font-family: 'JetBrains Mono'; font-weight: 700; color: var(--nexus-success);">
                                                <%= cur.format(record.get("wage")) %>
                                            </td>
                                            <td>
                                                <div style="color: var(--nexus-warning); font-size: 16px;">
                                                    <% 
                                                        int stars = (int) record.get("rating");
                                                        for(int i=0; i<5; i++) {
                                                    %>
                                                        <%= i < stars ? "★" : "☆" %>
                                                    <% } %>
                                                </div>
                                            </td>
                                            <td style="font-size: 13px; color: var(--text-secondary); font-style: italic;">
                                                "<%= record.get("comment") != null ? record.get("comment") : "No feedback provided." %>"
                                            </td>
                                        </tr>
                                    <% } %>
                                <% } else { %>
                                    <tr>
                                        <td colspan="5" style="text-align: center; padding: 50px; color: var(--text-muted);">No completed tasks found in your history.</td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- My Skills View -->
            <div id="mySkillsView" class="page-section">
                <div class="grid-2">
                    <div class="admin-card">
                        <div class="admin-card-header">
                            <h3>🛠️ Manage My Skills</h3>
                        </div>
                        <div class="admin-card-body">
                            <form action="${pageContext.request.contextPath}/manage-skills" method="POST">
                                <input type="hidden" name="action" value="add">
                                <div class="form-group">
                                    <label class="form-label">Select Skill</label>
                                    <select name="skillId" class="input-field">
                                        <option value="">-- Choose a skill --</option>
                                        <% if (allSkills != null) { 
                                            for (Map<String, Object> skill : allSkills) { %>
                                                <option value="<%= skill.get("id") %>"><%= skill.get("skill_name") %></option>
                                            <% } 
                                        } %>
                                    </select>
                                </div>
                                <div style="text-align: center; margin: 15px 0; color: var(--text-muted); font-size: 12px; font-weight: 600;">OR ADD NEW</div>
                                <div class="form-group">
                                    <label class="form-label">Other Skill</label>
                                    <input type="text" name="otherSkill" class="input-field" placeholder="Enter custom skill name...">
                                </div>
                                <div class="form-group" style="margin-top: 15px;">
                                    <label class="form-label">Proficiency Level</label>
                                    <select name="proficiency" class="input-field">
                                        <option value="1">Beginner</option>
                                        <option value="2">Intermediate</option>
                                        <option value="3">Advanced</option>
                                        <option value="4">Expert</option>
                                        <option value="5">Master</option>
                                    </select>
                                </div>
                                <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 15px;">Add Skill to Portfolio</button>
                            </form>
                        </div>
                    </div>

                    <div class="admin-card">
                        <div class="admin-card-header">
                            <h3>📜 Current Skillset</h3>
                        </div>
                        <div class="admin-card-body">
                            <div style="display: flex; flex-wrap: wrap; gap: 10px;">
                                <% if (workerSkills != null && !workerSkills.isEmpty()) { 
                                    String[] levels = {"", "Beginner", "Intermediate", "Advanced", "Expert", "Master"};
                                    for (Map<String, Object> skill : workerSkills) { 
                                        int pLevel = (int) skill.get("proficiency_level");
                                        String levelLabel = pLevel >= 1 && pLevel <= 5 ? levels[pLevel] : "Novice";
                                %>
                                        <div style="background: var(--nexus-accent-light); border: 1px solid var(--nexus-accent); border-radius: 20px; padding: 5px 15px; display: flex; align-items: center; gap: 8px;">
                                            <div style="display: flex; flex-direction: column;">
                                                <span style="font-size: 13px; font-weight: 600; color: var(--nexus-accent);"><%= skill.get("skill_name") %></span>
                                                <span style="font-size: 9px; color: var(--text-muted); font-weight: 700; text-transform: uppercase;"><%= levelLabel %></span>
                                            </div>
                                            <form action="${pageContext.request.contextPath}/manage-skills" method="POST" style="margin: 0; display: flex;">
                                                <input type="hidden" name="action" value="remove">
                                                <input type="hidden" name="skillId" value="<%= skill.get("id") %>">
                                                <button type="submit" style="background: none; border: none; color: var(--nexus-danger); cursor: pointer; font-size: 16px; padding: 0; display: flex; align-items: center;">×</button>
                                            </form>
                                        </div>
                                    <% } 
                                } else { %>
                                    <p style="color: var(--text-muted); padding: 20px; text-align: center; width: 100%;">You haven't added any skills yet.</p>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Earnings View -->
            <div id="earningsView" class="page-section">
                <div class="admin-card">
                    <div class="admin-card-header">
                        <h3>💰 Monthly Earnings Summary</h3>
                    </div>
                    <div class="admin-card-body">
                        <% if (earningsHistory != null && !earningsHistory.isEmpty()) { %>
                            <div class="metrics-panel" style="margin-bottom: 30px;">
                                <% Map<String, Object> latest = earningsHistory.get(0); %>
                                <div class="metric-card">
                                    <div class="metric-label">Latest Period (<%= latest.get("month") %>)</div>
                                    <div class="metric-value"><%= cur.format(latest.get("total_amount")) %></div>
                                </div>
                            </div>
                            <table class="admin-table">
                                <thead>
                                    <tr>
                                        <th>Period (Month)</th>
                                        <th>Tasks Completed</th>
                                        <th>Total Amount</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (Map<String, Object> entry : earningsHistory) { %>
                                        <tr>
                                            <td style="font-weight: 600;"><%= entry.get("month") %></td>
                                            <td><%= entry.get("task_count") %></td>
                                            <td style="font-family: 'JetBrains Mono'; font-weight: 700; color: var(--nexus-success);">
                                                <%= cur.format(entry.get("total_amount")) %>
                                            </td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        <% } else { %>
                            <div style="padding: 100px; text-align: center;">
                                <p style="color: var(--text-muted);">No earnings data available yet.</p>
                            </div>
                        <% } %>
                    </div>
                </div>
            </div>

            <!-- Profile View -->
            <div id="profileView" class="page-section">
                <div class="admin-card" style="max-width: 700px; margin: 0 auto;">
                    <div class="admin-card-header">
                        <h3>👤 My Professional Profile</h3>
                    </div>
                    <div class="admin-card-body">
                        <div class="form-row">
                            <div class="form-group">
                                <label class="form-label">Full Name</label>
                                <input type="text" class="input-field" value="<%= currentUser.getFullName() %>" readonly>
                            </div>
                            <div class="form-group">
                                <label class="form-label">Username</label>
                                <input type="text" class="input-field" value="<%= currentUser.getUsername() %>" readonly>
                            </div>
                        </div>
                        <div class="form-row">
                            <div class="form-group">
                                <label class="form-label">Email Address</label>
                                <input type="email" class="input-field" value="<%= currentUser.getEmail() %>" readonly>
                            </div>
                            <div class="form-group">
                                <label class="form-label">Phone Number</label>
                                <input type="text" class="input-field" value="<%= currentUser.getPhone() != null ? currentUser.getPhone() : "Not provided" %>" readonly>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Core Skills</label>
                            <textarea class="textarea-field" readonly><%= currentUser.getSkills() != null ? currentUser.getSkills() : "No skills listed." %></textarea>
                        </div>
                        <div style="margin-top: 20px; padding: 15px; background: var(--nexus-accent-light); border-radius: var(--radius-md); border: 1px solid var(--nexus-accent);">
                            <p style="font-size: 13px; color: var(--text-secondary);">
                                <strong>Account Status:</strong> <span class="status-badge approved"><%= currentUser.getStatus() %></span>
                            </p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Notifications View -->
            <div id="notificationsView" class="page-section">
                <div class="admin-card" style="max-width: 800px; margin: 0 auto;">
                    <div class="admin-card-header">
                        <h3>🔔 Operational Alerts</h3>
                    </div>
                    <div class="admin-card-body">
                        <% if (notifs != null && !notifs.isEmpty()) { %>
                            <% for (Map<String, Object> n : notifs) { %>
                                <div class="notification-item" style="padding: 15px; border-bottom: 1px solid var(--nexus-border); display: flex; gap: 15px; background: <%= (boolean)n.get("is_read") ? "transparent" : "rgba(59, 130, 246, 0.03)" %>;">
                                    <div class="notification-icon" style="font-size: 20px;">
                                        <%= "success".equals(n.get("type")) ? "✅" : ("warning".equals(n.get("type")) ? "⚠️" : "ℹ️") %>
                                    </div>
                                    <div style="flex: 1;">
                                        <div style="display: flex; justify-content: space-between;">
                                            <h4 style="font-weight: 700; margin-bottom: 3px;"><%= n.get("title") %></h4>
                                            <span style="font-size: 11px; color: var(--text-muted);"><%= n.get("created_at") %></span>
                                        </div>
                                        <p style="font-size: 13px; color: var(--text-secondary);"><%= n.get("message") %></p>
                                    </div>
                                </div>
                            <% } %>
                        <% } else { %>
                            <div style="padding: 60px; text-align: center; color: var(--text-muted);">
                                No alerts in your transmission log.
                            </div>
                        <% } %>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <script>
        function switchToPage(pageId) {
            // Hide all sections
            document.querySelectorAll('.page-section').forEach(section => {
                section.classList.remove('active');
            });
            
            // Show target section
            const targetSection = document.getElementById(pageId + 'View');
            if (targetSection) {
                targetSection.classList.add('active');
                window.scrollTo({ top: 0, behavior: 'smooth' });
            }
            
            // Update sidebar active state
            document.querySelectorAll('.nav-item').forEach(item => {
                item.classList.remove('active');
            });
            
            const activeItem = document.querySelector(`.nav-item[onclick*="${pageId}"]`);
            if (activeItem) {
                activeItem.classList.add('active');
            }
            
            // Update page titles
            const titles = {
                'dashboard': 'Worker Dashboard',
                'notifications': 'Operational Alerts',
                'available-tasks': 'Available Tasks',
                'my-tasks': 'Assigned Deliverables',
                'my-performance': 'Task Performance & Ratings',
                'my-skills': 'My Professional Skills',
                'earnings': 'Earnings History',
                'profile': 'My Professional Profile'
            };
            
            const subtitles = {
                'dashboard': 'Welcome back, <%= currentUser.getFullName().split(" ")[0] %>! Track your tasks and performance.',
                'notifications': 'Important updates regarding your submissions and account status.',
                'available-tasks': 'Discover new high-velocity contracts tailored to your expertise.',
                'my-tasks': 'Manage and submit your currently assigned project nodes.',
                'my-performance': 'Review your past accomplishments and employer feedback.',
                'my-skills': 'Curate your technical portfolio and specialized capabilities.',
                'earnings': 'Direct oversight of your financial throughput and project payouts.',
                'profile': 'Configure your professional data and security protocols.'
            };
            
            document.getElementById('pageTitle').textContent = titles[pageId] || 'Nexus Portal';
            document.getElementById('pageSubtitle').textContent = subtitles[pageId] || 'Operational Node';
        }
        
        // Initial setup
        window.onload = function() {
            // Check for success/error messages in URL if needed
            const urlParams = new URLSearchParams(window.location.search);
            if (urlParams.has('success')) {
                showAlert('alertContainer', urlParams.get('success'), 'success');
            }
        };
    </script>
</body>
</html>
