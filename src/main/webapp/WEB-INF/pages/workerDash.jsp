<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, com.nex.model.User, com.nex.model.Skill" %>
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
    List<Skill> allSkills = (List<Skill>) request.getAttribute("allSkills");
    List<Skill> workerSkills = (List<Skill>) request.getAttribute("workerSkills");
    List<Map<String, Object>> performance = (List<Map<String, Object>>) request.getAttribute("performance");
    
    // Stats
    Double totalEarned = (Double) request.getAttribute("totalEarned");
    Integer tasksCompleted = (Integer) request.getAttribute("tasksCompleted");
    Double avgRating = (Double) request.getAttribute("avgRating");
    Double pendingPayment = (Double) request.getAttribute("pendingPayment");
    Double completionRate = (Double) request.getAttribute("completionRate");
    Integer lateSubmissions = (Integer) request.getAttribute("lateSubmissions");
    
    // Formatter for currency
    java.text.NumberFormat cur = java.text.NumberFormat.getCurrencyInstance(new Locale("en", "NP"));
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
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <script src="${pageContext.request.contextPath}/js/alert.js"></script>
    <script src="${pageContext.request.contextPath}/js/dashboard-utils.js"></script>
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
                <img src="${pageContext.request.contextPath}/images/Nexuslogo_1.jpg" alt="Nexus Logo" style="height: 40px; width: auto;">
            </a>
            <div class="nav-links">
                <a href="${pageContext.request.contextPath}/">Home</a>
                <a href="${pageContext.request.contextPath}/about">About</a>
                <a href="${pageContext.request.contextPath}/contact">Contact</a>
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
                    <div class="admin-avatar" id="sidebarAvatar">
                        <% if (currentUser.getProfilePic() != null && !currentUser.getProfilePic().isEmpty()) { %>
                            <img src="${pageContext.request.contextPath}/images/<%= currentUser.getProfilePic() %>" alt="Avatar" style="width: 100%; height: 100%; border-radius: var(--radius-lg); object-fit: cover;">
                        <% } else { %>
                            <%= currentUser.getFullName().substring(0, 1).toUpperCase() %>
                        <% } %>
                    </div>
                    <div class="admin-info">
                        <h4><%= currentUser.getFullName() %></h4>
                        <p><%= currentUser.getRole().substring(0, 1).toUpperCase() + currentUser.getRole().substring(1) %></p>
                    </div>
                </div>
            </div>
            
            <nav class="sidebar-nav">
                <div class="nav-section-title">MAIN</div>
                <a href="javascript:void(0)" class="nav-item active" onclick="switchToPage('dashboard')">
                    <span class="nav-icon"><i class="fas fa-th-large"></i></span>
                    <span class="nav-text">Dashboard</span>
                </a>
                <a href="javascript:void(0)" class="nav-item" onclick="switchToPage('notifications')">
                    <span class="nav-icon"><i class="fas fa-bell"></i></span>
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
                    <span class="nav-icon"><i class="fas fa-search-plus"></i></span>
                    <span class="nav-text">Available Tasks</span>
                    <span class="nav-badge"><%= availableTasks != null ? availableTasks.size() : 0 %></span>
                </a>
                <a href="javascript:void(0)" class="nav-item" onclick="switchToPage('my-tasks')">
                    <span class="nav-icon"><i class="fas fa-tasks"></i></span>
                    <span class="nav-text">My Tasks</span>
                    <span class="nav-badge"><%= myTasks != null ? myTasks.size() : 0 %></span>
                </a>
                <a href="javascript:void(0)" class="nav-item" onclick="switchToPage('my-performance')">
                    <span class="nav-icon"><i class="fas fa-chart-line"></i></span>
                    <span class="nav-text">My Performance</span>
                </a>
                <a href="javascript:void(0)" class="nav-item" onclick="switchToPage('my-skills')">
                    <span class="nav-icon"><i class="fas fa-tools"></i></span>
                    <span class="nav-text">My Skills</span>
                    <span class="nav-badge"><%= workerSkills != null ? workerSkills.size() : 0 %></span>
                </a>
                
                <div class="nav-section-title">FINANCES</div>
                <a href="javascript:void(0)" class="nav-item" onclick="switchToPage('earnings')">
                    <span class="nav-icon"><i class="fas fa-wallet"></i></span>
                    <span class="nav-text">Earnings History</span>
                </a>
                
                <div class="nav-section-title">ACCOUNT</div>
                <a href="javascript:void(0)" class="nav-item" onclick="switchToPage('profile')">
                    <span class="nav-icon"><i class="fas fa-user-circle"></i></span>
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
                            <span class="worker-stat-icon"><i class="fas fa-hand-holding-usd" style="color: var(--nexus-success);"></i></span>
                            <span class="worker-stat-label">Total Earned</span>
                        </div>
                        <div class="worker-stat-value"><%= cur.format(totalEarned != null ? totalEarned : 0) %></div>
                        <div class="worker-stat-change">Life-time earnings</div>
                    </div>
                    <div class="worker-stat-card">
                        <div class="worker-stat-header">
                            <span class="worker-stat-icon"><i class="fas fa-check-circle" style="color: var(--nexus-accent);"></i></span>
                            <span class="worker-stat-label">Tasks Done</span>
                        </div>
                        <div class="worker-stat-value"><%= tasksCompleted != null ? tasksCompleted : 0 %></div>
                        <div class="worker-stat-change">Completed missions</div>
                    </div>
                    <div class="worker-stat-card">
                        <div class="worker-stat-header">
                            <span class="worker-stat-icon"><i class="fas fa-star" style="color: var(--nexus-warning);"></i></span>
                            <span class="worker-stat-label">Rating</span>
                        </div>
                        <div class="worker-stat-value"><%= avgRating != null ? String.format("%.1f", avgRating) : "0.0" %></div>
                        <div class="worker-stat-change">Quality score</div>
                    </div>
                    <div class="worker-stat-card">
                        <div class="worker-stat-header">
                            <span class="worker-stat-icon"><i class="fas fa-clock" style="color: var(--nexus-warning);"></i></span>
                            <span class="worker-stat-label">Pending</span>
                        </div>
                        <div class="worker-stat-value"><%= cur.format(pendingPayment != null ? pendingPayment : 0) %></div>
                        <div class="worker-stat-change">Awaiting approval</div>
                    </div>
                </div>

                <!-- Quick Actions -->
                <div class="quick-actions" style="margin: var(--space-lg) 0; display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-md);">
                    <div class="quick-action-card" onclick="switchToPage('available-tasks')">
                        <div class="quick-action-icon"><i class="fas fa-search"></i></div>
                        <div class="quick-action-title">Find New Tasks</div>
                        <div class="quick-action-desc">Browse available work</div>
                    </div>
                    <div class="quick-action-card" onclick="switchToPage('my-tasks')">
                        <div class="quick-action-icon"><i class="fas fa-list-check"></i></div>
                        <div class="quick-action-title">My Active Tasks</div>
                        <div class="quick-action-desc">Continue working</div>
                    </div>
                    <div class="quick-action-card" onclick="switchToPage('earnings')">
                        <div class="quick-action-icon"><i class="fas fa-money-bill-transfer"></i></div>
                        <div class="quick-action-title">View Earnings</div>
                        <div class="quick-action-desc">Track your income</div>
                    </div>
                    <div class="quick-action-card" onclick="switchToPage('my-performance')">
                        <div class="quick-action-icon"><i class="fas fa-gauge-high"></i></div>
                        <div class="quick-action-title">Performance</div>
                        <div class="quick-action-desc">See your stats</div>
                    </div>
                </div>

                <div class="dashboard-grid">
                    <div class="admin-card">
                        <div class="admin-card-header">
                            <h3><i class="fas fa-thumbtack" style="color: var(--nexus-accent); margin-right: 8px;"></i>Active Deliverables</h3>
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
                            <h3><i class="fas fa-chart-pie" style="color: var(--nexus-accent); margin-right: 8px;"></i>Performance Summary</h3>
                            <button class="btn-icon" onclick="switchToPage('my-performance')">Details →</button>
                        </div>
                        <div class="admin-card-body">
                            <div class="performance-grid">
                                <div class="performance-card" style="background: var(--nexus-elevated);">
                                    <div class="performance-value" style="font-size: 1.2rem;"><%= completionRate != null ? String.format("%.0f%%", completionRate) : "0%" %></div>
                                    <div class="performance-label">Completion</div>
                                </div>
                                <div class="performance-card" style="background: var(--nexus-elevated);">
                                    <div class="performance-value" style="font-size: 1.2rem;"><%= avgRating != null ? String.format("%.1f", avgRating) : "0.0" %></div>
                                    <div class="performance-label">Avg Rating</div>
                                </div>
                                <div class="performance-card" style="background: var(--nexus-elevated);">
                                    <div class="performance-value" style="font-size: 1.2rem;"><%= tasksCompleted != null ? tasksCompleted : 0 %></div>
                                    <div class="performance-label">Total Done</div>
                                </div>
                                <div class="performance-card" style="background: var(--nexus-elevated);">
                                    <div class="performance-value" style="font-size: 1.2rem;"><%= lateSubmissions != null ? lateSubmissions : 0 %></div>
                                    <div class="performance-label">Late Subs</div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="admin-card">
                        <div class="admin-card-header">
                            <h3><i class="fas fa-history" style="color: var(--nexus-accent); margin-right: 8px;"></i>Recent Activity</h3>
                        </div>
                        <div class="admin-card-body">
                            <% if (earningsHistory != null && !earningsHistory.isEmpty()) { %>
                                <% for (int i = 0; i < Math.min(earningsHistory.size(), 5); i++) { 
                                    Map<String, Object> entry = earningsHistory.get(i);
                                %>
                                <div style="padding: 12px; border-bottom: 1px solid var(--nexus-border); display: flex; gap: 15px; align-items: center;">
                                    <div style="font-size: 18px; color: var(--nexus-success);"><i class="fas fa-hand-holding-usd"></i></div>
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
            <div id="available-tasksView" class="page-section">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem; gap: 1rem;">
                    <div class="search-group" style="flex: 1; max-width: none;">
                        <div class="search-wrapper">
                            <span class="search-icon">🔍</span>
                            <input type="text" id="availableTaskSearch" class="search-input" placeholder="Search tasks by title, description or priority..." value="${availSearch}" onkeypress="if(event.key === 'Enter') serverSideSearch('availSearch', this.value)">
                        </div>
                        <button class="search-action-btn" onclick="serverSideSearch('availSearch', document.getElementById('availableTaskSearch').value)">Search</button>
                    </div>
                    <div class="sort-container" style="display: flex; align-items: center; gap: 10px;">
                        <label style="font-size: 14px; font-weight: 600; color: var(--text-muted); white-space: nowrap;">Sort by:</label>
                        <select class="select-field" style="width: 150px; padding: 8px;" onchange="const val = this.value.split(':'); serverSideSearch('availSortBy', val[0]); serverSideSearch('availSortDir', val[1]);">
                            <option value="deadline:ASC" ${availSortBy == 'deadline' && availSortDir == 'ASC' ? 'selected' : ''}>Deadline (Soonest)</option>
                            <option value="deadline:DESC" ${availSortBy == 'deadline' && availSortDir == 'DESC' ? 'selected' : ''}>Deadline (Latest)</option>
                            <option value="wage:DESC" ${availSortBy == 'wage' && availSortDir == 'DESC' ? 'selected' : ''}>Wage (High to Low)</option>
                            <option value="wage:ASC" ${availSortBy == 'wage' && availSortDir == 'ASC' ? 'selected' : ''}>Wage (Low to High)</option>
                            <option value="title:ASC" ${availSortBy == 'title' && availSortDir == 'ASC' ? 'selected' : ''}>Title (A-Z)</option>
                        </select>
                    </div>
                </div>
                <div class="grid-2" id="availableTasksGrid">
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
                                        <i class="fas fa-calendar-alt"></i> Deadline: <%= task.get("deadline") %>
                                    </div>
                                    <button onclick="acceptTask(<%= task.get("id") %>, this)" class="btn btn-primary" style="padding: 8px 16px;">Accept Task →</button>
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
            <div id="my-tasksView" class="page-section">
                <div class="admin-card">
                    <div class="admin-card-header">
                        <h3>Assigned Deliverables</h3>
                    </div>
                    <div class="search-container">
                        <div class="search-group">
                            <div class="search-wrapper">
                                <span class="search-icon">🔍</span>
                                <input type="text" id="myTaskSearch" class="search-input" placeholder="Search my tasks..." value="${mySearch}" onkeypress="if(event.key === 'Enter') serverSideSearch('mySearch', this.value)">
                            </div>
                            <button class="search-action-btn" onclick="serverSideSearch('mySearch', document.getElementById('myTaskSearch').value)">Search</button>
                        </div>
                    </div>
                    <div class="admin-card-body" style="padding: 0;">
                        <table class="admin-table" id="myTasksTable">
                            <thead>
                                <tr>
                                    <th class="sortable ${mySortBy == 'title' ? (mySortDir == 'ASC' ? 'sort-asc' : 'sort-desc') : ''}" onclick="serverSideSort('mySortBy', 'title', 'mySortDir')">Task Title</th>
                                    <th class="sortable ${mySortBy == 'deadline' ? (mySortDir == 'ASC' ? 'sort-asc' : 'sort-desc') : ''}" onclick="serverSideSort('mySortBy', 'deadline', 'mySortDir')">Deadline</th>
                                    <th class="sortable ${mySortBy == 'wage' ? (mySortDir == 'ASC' ? 'sort-asc' : 'sort-desc') : ''}" onclick="serverSideSort('mySortBy', 'wage', 'mySortDir')">Wage</th>
                                    <th class="sortable ${mySortBy == 'status' ? (mySortDir == 'ASC' ? 'sort-asc' : 'sort-desc') : ''}" onclick="serverSideSort('mySortBy', 'status', 'mySortDir')">Status</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (myTasks != null && !myTasks.isEmpty()) { %>
                                    <% for (Map<String, Object> task : myTasks) { 
                                        String aStatus = (String) task.get("assignment_status");
                                        int aId = (int) task.get("assignment_id");
                                    %>
                                        <tr>
                                            <td style="font-weight: 600;"><%= task.get("title") %></td>
                                            <td><%= task.get("deadline") %></td>
                                            <td style="font-family: 'JetBrains Mono'; font-weight: 700;"><%= cur.format(task.get("wage")) %></td>
                                            <td>
                                                <span class="status-badge <%= aStatus.toLowerCase().replace("_", "-") %>">
                                                    <%= aStatus.toUpperCase() %>
                                                </span>
                                            </td>
                                            <td>
                                                <% if ("accepted".equals(aStatus)) { %>
                                                    <button onclick="startTask('<%= aId %>', this)" class="btn btn-primary" style="padding: 5px 12px; font-size: 11px;">Start Task</button>
                                                <% } else if ("in_progress".equals(aStatus)) { %>
                                                    <button onclick="openSubmitModal(this.getAttribute('data-id'), this.getAttribute('data-title'))" 
                                                            data-id="<%= aId %>"
                                                            data-title="<%= task.get("title").toString().replace("\"", "&quot;") %>"
                                                            class="btn btn-secondary" 
                                                            style="padding: 5px 12px; font-size: 11px; background: var(--nexus-success); color: white; border: none;">
                                                        Submit Work
                                                    </button>
                                                <% } else if ("submitted".equals(aStatus)) { %>
                                                    <span style="font-size: 11px; color: var(--text-muted);">Awaiting Review</span>
                                                <% } %>
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
                <div class="performance-grid" style="margin-bottom: var(--space-lg);">
                    <div class="performance-card">
                        <div class="performance-value"><%= tasksCompleted != null ? tasksCompleted : 0 %></div>
                        <div class="performance-label">Tasks Completed</div>
                    </div>
                    <div class="performance-card">
                        <div class="performance-value"><%= avgRating != null ? String.format("%.1f", avgRating) : "0.0" %></div>
                        <div class="performance-label">Avg Rating ★</div>
                    </div>
                    <div class="performance-card">
                        <div class="performance-value"><%= completionRate != null ? String.format("%.0f%%", completionRate) : "0%" %></div>
                        <div class="performance-label">Completion Rate</div>
                    </div>
                    <div class="performance-card">
                        <div class="performance-value"><%= lateSubmissions != null ? lateSubmissions : 0 %></div>
                        <div class="performance-label">Late Submissions</div>
                    </div>
                </div>

                <div class="admin-card">
                    <div class="admin-card-header">
                        <h3>📈 Task Performance & Ratings</h3>
                    </div>
                    <div class="search-container">
                        <div class="search-group">
                            <div class="search-wrapper">
                                <span class="search-icon">🔍</span>
                                <input type="text" id="perfSearch" class="search-input" placeholder="Search performance history..." value="${perfSearch}" onkeypress="if(event.key === 'Enter') serverSideSearch('perfSearch', this.value)">
                            </div>
                            <button class="search-action-btn" onclick="serverSideSearch('perfSearch', document.getElementById('perfSearch').value)">Search</button>
                        </div>
                    </div>
                    <div class="admin-card-body" style="padding: 0;">
                        <table class="admin-table" id="perfTable">
                            <thead>
                                <tr>
                                    <th class="sortable ${perfSortBy == 'title' ? (perfSortDir == 'ASC' ? 'sort-asc' : 'sort-desc') : ''}" onclick="serverSideSort('perfSortBy', 'title', 'perfSortDir')">Task Title</th>
                                    <th class="sortable ${perfSortBy == 'date' ? (perfSortDir == 'ASC' ? 'sort-asc' : 'sort-desc') : ''}" onclick="serverSideSort('perfSortBy', 'date', 'perfSortDir')">Completion Date</th>
                                    <th class="sortable ${perfSortBy == 'wage' ? (perfSortDir == 'ASC' ? 'sort-asc' : 'sort-desc') : ''}" onclick="serverSideSort('perfSortBy', 'wage', 'perfSortDir')">Wage Earned</th>
                                    <th class="sortable ${perfSortBy == 'rating' ? (perfSortDir == 'ASC' ? 'sort-asc' : 'sort-desc') : ''}" onclick="serverSideSort('perfSortBy', 'rating', 'perfSortDir')">Rating</th>
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
            <div id="my-skillsView" class="page-section">
                <div class="admin-card" style="max-width: 900px; margin: 0 auto;">
                    <div class="admin-card-header">
                        <h3>🛠️ Professional Skill Portfolio</h3>
                    </div>
                    <div class="admin-card-body">
                        <div class="grid-2" style="gap: 40px;">
                            <div>
                                <h4 style="margin-bottom: 20px; font-weight: 700; color: var(--text-primary);">Add New Expertise</h4>
                                <form action="${pageContext.request.contextPath}/manage-skills" method="POST">
                                    <input type="hidden" name="action" value="add">
                                    <div class="form-group">
                                        <label class="form-label">Select Recognized Skill</label>
                                        <select name="skillId" class="input-field">
                                            <option value="">-- Choose from library --</option>
                                            <% if (allSkills != null) { 
                                                for (Skill skill : allSkills) { %>
                                                    <option value="<%= skill.getId() %>"><%= skill.getSkillName() %></option>
                                                <% } 
                                            } %>
                                        </select>
                                    </div>
                                    <div style="text-align: center; margin: 15px 0; color: var(--text-muted); font-size: 11px; font-weight: 700; letter-spacing: 0.1em;">OR DEFINE CUSTOM</div>
                                    <div class="form-group">
                                        <label class="form-label">Custom Skill Name</label>
                                        <input type="text" name="otherSkill" class="input-field" placeholder="e.g. Advanced Prompt Engineering">
                                    </div>
                                    <div class="form-group" style="margin-top: 15px;">
                                        <label class="form-label">Proficiency Level</label>
                                        <select name="proficiency" class="input-field">
                                            <option value="1">Beginner (1/5)</option>
                                            <option value="2">Intermediate (2/5)</option>
                                            <option value="3">Advanced (3/5)</option>
                                            <option value="4">Expert (4/5)</option>
                                            <option value="5">Master (5/5)</option>
                                        </select>
                                    </div>
                                    <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 20px;">Update Portfolio</button>
                                </form>
                            </div>

                            <div style="border-left: 1px solid var(--nexus-border); padding-left: 40px;">
                                <h4 style="margin-bottom: 20px; font-weight: 700; color: var(--text-primary);">Your Verified Skillset</h4>
                                <div style="display: flex; flex-wrap: wrap; gap: 12px;">
                                    <% if (workerSkills != null && !workerSkills.isEmpty()) { 
                                        String[] levels = {"", "Beginner", "Intermediate", "Advanced", "Expert", "Master"};
                                        for (Skill skill : workerSkills) { 
                                            int pLevel = skill.getProficiencyLevel();
                                            String levelLabel = pLevel >= 1 && pLevel <= 5 ? levels[pLevel] : "Novice";
                                    %>
                                            <div style="background: var(--nexus-elevated); border: 1px solid var(--nexus-border); border-radius: 12px; padding: 10px 15px; display: flex; align-items: center; gap: 12px; transition: all 0.2s;">
                                                <div style="display: flex; flex-direction: column;">
                                                    <span style="font-size: 14px; font-weight: 600; color: var(--text-primary);"><%= skill.getSkillName() %></span>
                                                    <span style="font-size: 10px; color: var(--nexus-accent); font-weight: 800; text-transform: uppercase;"><%= levelLabel %></span>
                                                </div>
                                                <form action="${pageContext.request.contextPath}/manage-skills" method="POST" style="margin: 0; display: flex;">
                                                    <input type="hidden" name="action" value="remove">
                                                    <input type="hidden" name="skillId" value="<%= skill.getId() %>">
                                                    <button type="submit" style="background: var(--nexus-danger-light); border: none; color: var(--nexus-danger); cursor: pointer; font-size: 14px; width: 24px; height: 24px; border-radius: 50%; display: flex; align-items: center; justify-content: center; transition: all 0.2s;">×</button>
                                                </form>
                                            </div>
                                        <% } 
                                    } else { %>
                                        <div style="text-align: center; width: 100%; padding: 40px 0;">
                                            <div style="font-size: 40px; margin-bottom: 10px;">🛠️</div>
                                            <p style="color: var(--text-muted); font-size: 14px;">No skills listed in your profile yet.</p>
                                        </div>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Earnings View -->
            <div id="earningsView" class="page-section">
                <div class="admin-card">
                    <div class="admin-card-header">
                        <h3><i class="fas fa-wallet" style="color: var(--nexus-accent); margin-right: 8px;"></i>Monthly Earnings Summary</h3>
                    </div>                    <div class="search-container">
                        <div class="search-group">
                            <div class="search-wrapper">
                                <span class="search-icon">🔍</span>
                                <input type="text" id="earningsSearch" class="search-input" placeholder="Search earnings history..." onkeyup="searchTable('earningsSearch', 'earningsTable')">
                            </div>
                            <button class="search-action-btn" onclick="searchTable('earningsSearch', 'earningsTable')">Search</button>
                        </div>
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
                            <table class="admin-table" id="earningsTable">
                                <thead>
                                    <tr>
                                        <th class="sortable ${earnSortBy == 'period' ? (earnSortDir == 'ASC' ? 'sort-asc' : 'sort-desc') : ''}" onclick="serverSideSort('earnSortBy', 'period', 'earnSortDir')">Period (Month)</th>
                                        <th class="sortable ${earnSortBy == 'tasks' ? (earnSortDir == 'ASC' ? 'sort-asc' : 'sort-desc') : ''}" onclick="serverSideSort('earnSortBy', 'tasks', 'earnSortDir')">Tasks Completed</th>
                                        <th class="sortable ${earnSortBy == 'amount' ? (earnSortDir == 'ASC' ? 'sort-asc' : 'sort-desc') : ''}" onclick="serverSideSort('earnSortBy', 'amount', 'earnSortDir')">Total Amount</th>
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
                        <div style="text-align: center; margin-bottom: 30px;">
                            <div class="admin-avatar" id="settingsAvatar" style="width: 100px; height: 100px; margin: 0 auto 15px; font-size: 2.5rem;">
                                <% if (currentUser.getProfilePic() != null && !currentUser.getProfilePic().isEmpty()) { %>
                                    <img src="${pageContext.request.contextPath}/images/<%= currentUser.getProfilePic() %>" alt="Avatar" style="width: 100%; height: 100%; border-radius: var(--radius-lg); object-fit: cover;">
                                <% } else { %>
                                    <%= currentUser.getFullName().substring(0, 1).toUpperCase() %>
                                <% } %>
                            </div>
                            <h4>Manage Profile Picture</h4>
                            <p class="text-muted" style="font-size: 13px;">Select an image from the operational repository</p>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Upload Profile Image</label>
                            <div style="margin-top: 10px; padding: 20px; background: var(--nexus-surface); border-radius: var(--radius-md); border: 1px solid var(--nexus-border); display: flex; flex-direction: column; gap: 15px;">
                                <div style="display: flex; align-items: center; gap: 15px;">
                                    <div style="flex: 1;">
                                        <input type="file" id="profilePicInput" accept="image/*" class="input-field" style="padding: 8px;">
                                        <p class="text-muted" style="font-size: 11px; margin-top: 5px;">Supported formats: JPG, PNG, WEBP (Max 10MB)</p>
                                    </div>
                                    <button onclick="uploadProfilePic()" class="btn btn-primary">Upload & Apply</button>
                                </div>
                            </div>
                        </div>

                        <div class="form-row" style="margin-top: 25px;">
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
                            <textarea class="textarea-field" readonly><% 
                                if (workerSkills != null && !workerSkills.isEmpty()) {
                                    StringBuilder sb = new StringBuilder();
                                    for (int i = 0; i < workerSkills.size(); i++) {
                                        sb.append(workerSkills.get(i).getSkillName());
                                        if (i < workerSkills.size() - 1) sb.append(", ");
                                    }
                                    out.print(sb.toString());
                                } else {
                                    out.print("No skills listed.");
                                }
                            %></textarea>
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
                                    <div class="notification-icon" style="font-size: 18px;">
                                        <% if ("success".equals(n.get("type"))) { %>
                                            <i class="fas fa-check-circle" style="color: var(--nexus-success);"></i>
                                        <% } else if ("warning".equals(n.get("type"))) { %>
                                            <i class="fas fa-exclamation-triangle" style="color: var(--nexus-warning);"></i>
                                        <% } else { %>
                                            <i class="fas fa-info-circle" style="color: var(--nexus-accent);"></i>
                                        <% } %>
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

    <!-- Submission Modal -->
    <div id="submitModal" class="modal-overlay" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 1000; justify-content: center; align-items: center;">
        <div class="modal-content" style="background: white; padding: 30px; border-radius: 12px; width: 500px; max-width: 90%; box-shadow: 0 20px 40px rgba(0,0,0,0.2);">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                <h2 id="modalTaskTitle" style="margin: 0;">Submit Work</h2>
                <button id="restoreDraftBtn" onclick="restoreDraft()" class="btn btn-outline" style="display: none; padding: 4px 10px; font-size: 11px; border-color: var(--nexus-accent); color: var(--nexus-accent);">⚡ Resume Draft</button>
            </div>
            <form action="${pageContext.request.contextPath}/submit-task" method="POST" enctype="multipart/form-data">
                <input type="hidden" id="modalAssignmentId" name="assignmentId">
                <div class="form-group">
                    <label class="form-label">Submission Details / Proof of Work</label>
                    <textarea id="modalSubmissionText" name="submissionText" class="textarea-field" required placeholder="Describe what you've completed..." style="height: 120px;" oninput="saveDraft()"></textarea>
                </div>
                <div class="form-group" style="margin-top: 15px;">
                    <label class="form-label">Attach Files (Optional)</label>
                    <div style="position: relative;">
                        <input type="file" name="attachment" id="modalAttachment" class="input-field" style="padding: 8px;" onchange="updateFileName(this)" multiple>
                        <div id="fileSelectedName" style="font-size: 11px; color: var(--nexus-accent); margin-top: 4px; font-weight: 600;"></div>
                    </div>
                    <p class="text-muted" style="font-size: 11px; margin-top: 5px;">Supported: PDF, ZIP, Images (Max 50MB per file)</p>
                </div>
                <div class="form-group" style="margin-top: 15px;">
                    <label class="form-label">Hours Worked</label>
                    <input type="number" id="modalHoursWorked" name="hoursWorked" step="0.5" min="0" class="input-field" placeholder="e.g. 2.5" oninput="saveDraft()">
                </div>
                <div style="display: flex; gap: 10px; margin-top: 25px;">
                    <button type="button" onclick="closeSubmitModal()" class="btn btn-secondary" style="flex: 1;">Cancel</button>
                    <button type="submit" id="submitBtn" class="btn btn-primary" style="flex: 1;">Submit Deliverable</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function updateFileName(input) {
            const fileNameDiv = document.getElementById('fileSelectedName');
            if (input.files && input.files.length > 0) {
                if (input.files.length === 1) {
                    fileNameDiv.textContent = '📎 Selected: ' + input.files[0].name;
                } else {
                    fileNameDiv.textContent = '📎 ' + input.files.length + ' files selected';
                    // Optional: show first few names
                    let names = [];
                    for (let i = 0; i < Math.min(input.files.length, 3); i++) {
                        names.push(input.files[i].name);
                    }
                    if (input.files.length > 3) names.push('...');
                    fileNameDiv.title = Array.from(input.files).map(f => f.name).join(', ');
                }
            } else {
                fileNameDiv.textContent = '';
            }
        }

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
                // Persist the current page
                localStorage.setItem('worker_active_tab', pageId);
            }
            
            // Update sidebar active state
            document.querySelectorAll('.nav-item').forEach(item => {
                item.classList.remove('active');
            });
            
            const activeItem = document.querySelector(`.nav-item[onclick*="\${pageId}"]`);
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
        
        function saveDraft() {
            const assignmentId = document.getElementById('modalAssignmentId').value;
            const text = document.getElementById('modalSubmissionText').value;
            const hours = document.getElementById('modalHoursWorked').value;
            
            if (assignmentId) {
                const draft = { text, hours, timestamp: new Date().getTime() };
                localStorage.setItem('submission_draft_' + assignmentId, JSON.stringify(draft));
            }
        }

        function restoreDraft() {
            const assignmentId = document.getElementById('modalAssignmentId').value;
            const draftJson = localStorage.getItem('submission_draft_' + assignmentId);
            if (draftJson) {
                const draft = JSON.parse(draftJson);
                document.getElementById('modalSubmissionText').value = draft.text;
                document.getElementById('modalHoursWorked').value = draft.hours;
                document.getElementById('restoreDraftBtn').style.display = 'none';
                showAlert('alertContainer', 'Draft restored successfully!', 'success');
            }
        }

        function clearDraft() {
            const assignmentId = document.getElementById('modalAssignmentId').value;
            if (assignmentId) {
                localStorage.removeItem('submission_draft_' + assignmentId);
            }
        }

       function openSubmitModal(assignmentId, taskTitle) {
            try {
                console.log('openSubmitModal called with:', { assignmentId, taskTitle });
                
                const assignmentIdInput = document.getElementById('modalAssignmentId');
                const taskTitleElem = document.getElementById('modalTaskTitle');
                const modal = document.getElementById('submitModal');
                
                if (!assignmentIdInput || !taskTitleElem || !modal) {
                    console.error('Missing modal elements:', { assignmentIdInput, taskTitleElem, modal });
                    alert('Technical error: Modal elements not found.');
                    return;
                }
                
                assignmentIdInput.value = assignmentId;
                taskTitleElem.textContent = 'Submit Work: ' + taskTitle;
                
                // Check for draft
                const draft = localStorage.getItem('submission_draft_' + assignmentId);
                const restoreBtn = document.getElementById('restoreDraftBtn');
                if (draft && restoreBtn) {
                    restoreBtn.style.display = 'block';
                } else if (restoreBtn) {
                    restoreBtn.style.display = 'none';
                }
                
                // Clear fields if no draft or starting fresh
                if (!draft) {
                    document.getElementById('modalSubmissionText').value = '';
                    document.getElementById('modalHoursWorked').value = '';
                }
                
                modal.style.display = 'flex';
                // Small delay to allow display: flex to take effect before adding the active class for transition
                setTimeout(() => {
                    modal.classList.add('active');
                }, 10);
                console.log('Modal display set to flex and active class added');
            } catch (err) {
                console.error('Exception in openSubmitModal:', err);
                alert('An error occurred while opening the submission window.');
            }
        }
        
        function closeSubmitModal() {
            const modal = document.getElementById('submitModal');
            if (modal) {
                modal.classList.remove('active');
                // Wait for the transition to finish before hiding the element (matching --transition-smooth: 300ms)
                setTimeout(() => {
                    modal.style.display = 'none';
                }, 300);
            }
        }

        function acceptTask(taskId, btn) {
            fetch('${pageContext.request.contextPath}/accept-task', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'taskId=' + taskId
            }).then(response => {
                if (response.redirected) {
                    const url = new URL(response.url);
                    const msg = url.searchParams.get('success');
                    const err = url.searchParams.get('error');
                    if (msg) {
                        showAlert('alertContainer', msg, 'success');
                        // Remove the task card from available tasks
                        const taskCard = btn.closest('.task-card-improved');
                        if (taskCard) taskCard.remove();
                        // Also might want to refresh the my-tasks section
                        setTimeout(() => {
                            window.location.reload();
                        }, 1500);
                    } else if (err) {
                        showAlert('alertContainer', err, 'error');
                    }
                }
            }).catch(error => {
                console.error('Error:', error);
                showAlert('alertContainer', 'Network error occurred', 'error');
            });
        }

        function startTask(assignmentId, btn) {
            fetch('${pageContext.request.contextPath}/update-assignment', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'assignmentId=' + assignmentId + '&action=start'
            }).then(response => {
                if (response.redirected) {
                    const url = new URL(response.url);
                    const msg = url.searchParams.get('success');
                    const err = url.searchParams.get('error');
                    if (msg) {
                        showAlert('alertContainer', msg, 'success');
                        // Update the UI
                        const row = btn.closest('tr');
                        const statusBadge = row.querySelector('.status-badge');
                        statusBadge.className = 'status-badge in-progress';
                        statusBadge.textContent = 'IN_PROGRESS';
                        // Change button to submit button with proper escaping and DOM-based title retrieval
                        btn.outerHTML = `<button onclick="openSubmitModal('\${assignmentId}', this.closest('tr').cells[0].textContent.trim())" class="btn btn-secondary" style="padding: 5px 12px; font-size: 11px; background: var(--nexus-success); color: white; border: none;">Submit Work</button>`;
                    } else if (err) {
                        showAlert('alertContainer', err, 'error');
                    }
                }
            }).catch(error => {
                console.error('Error:', error);
                showAlert('alertContainer', 'Network error occurred', 'error');
            });
        }

        function submitWork(event) {
            event.preventDefault();
            const form = event.target;
            const formData = new URLSearchParams(new FormData(form));
            
            fetch(form.action, {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: formData.toString()
            }).then(response => {
                if (response.redirected) {
                    const url = new URL(response.url);
                    const msg = url.searchParams.get('success');
                    if (msg) {
                        showAlert('alertContainer', msg, 'success');
                        closeSubmitModal();
                        const aId = document.getElementById('modalAssignmentId').value;
                        const row = document.querySelector(`button[onclick*="'\${aId}'"]`)?.closest('tr');
                        if (row) {
                            const statusBadge = row.querySelector('.status-badge');
                            statusBadge.className = 'status-badge submitted';
                            statusBadge.textContent = 'SUBMITTED';
                            row.cells[4].innerHTML = '<span style="font-size: 11px; color: var(--text-muted);">Awaiting Review</span>';
                        }
                    }
                }
            });
        }

        function manageSkill(event, action) {
            event.preventDefault();
            const form = event.target;
            const formData = new URLSearchParams(new FormData(form));
            
            fetch(form.action, {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: formData.toString()
            }).then(response => {
                // For skills, since the structure is complex, a partial reload or dynamic update is needed
                // For now, let's reload just the skill section or use simple location.reload for this specific complex one
                // to ensure all UI elements (dropdowns, lists) are in sync.
                location.reload(); 
            });
        }

        function uploadProfilePic() {
            const fileInput = document.getElementById('profilePicInput');
            const file = fileInput.files[0];
            
            if (!file) {
                showAlert('alertContainer', 'Please select a file to upload.', 'error');
                return;
            }
            
            if (file.size > 10 * 1024 * 1024) {
                showAlert('alertContainer', 'File is too large. Maximum size is 10MB.', 'error');
                return;
            }
            
            const formData = new FormData();
            formData.append('action', 'uploadPicture');
            formData.append('profilePicFile', file);
            
            fetch('${pageContext.request.contextPath}/update-profile', {
                method: 'POST',
                body: formData
            }).then(response => response.json())
              .then(result => {
                  if (result.success) {
                      showAlert('alertContainer', result.message, 'success');
                      // Update avatars on the page
                      const avatarUrl = '${pageContext.request.contextPath}/images/' + result.profilePic;
                      const avatarHtml = `<img src="\${avatarUrl}" alt="Avatar" style="width: 100%; height: 100%; border-radius: var(--radius-lg); object-fit: cover;">`;
                      
                      document.getElementById('sidebarAvatar').innerHTML = avatarHtml;
                      document.getElementById('settingsAvatar').innerHTML = avatarHtml;
                      
                      // Clear input
                      fileInput.value = '';
                  } else {
                      showAlert('alertContainer', result.message, 'error');
                  }
              }).catch(err => {
                  console.error('Error:', err);
                  showAlert('alertContainer', 'An error occurred during upload.', 'error');
              });
        }

        function selectProfilePic(fileName) {
            if (!confirm('Update profile picture to ' + fileName + '?')) return;
            
            fetch('${pageContext.request.contextPath}/update-profile', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'action=updatePicture&profilePic=' + encodeURIComponent(fileName)
            }).then(response => response.json())
              .then(result => {
                  if (result.success) {
                      showAlert('alertContainer', result.message, 'success');
                      // Update avatars on the page
                      const avatarUrl = '${pageContext.request.contextPath}/images/' + fileName;
                      const avatarHtml = `<img src="\${avatarUrl}" alt="Avatar" style="width: 100%; height: 100%; border-radius: var(--radius-lg); object-fit: cover;">`;
                      
                      document.getElementById('sidebarAvatar').innerHTML = avatarHtml;
                      document.getElementById('settingsAvatar').innerHTML = avatarHtml;
                      
                      // Update active state in selector
                      document.querySelectorAll('.image-option').forEach(opt => {
                          opt.classList.remove('active');
                          opt.style.borderColor = 'transparent';
                          const check = opt.querySelector('div');
                          if (check) check.remove();
                      });
                      
                      // Find the selected option and mark it
                      const options = document.querySelectorAll('.image-option');
                      for (const opt of options) {
                          if (opt.getAttribute('onclick').includes(fileName)) {
                              opt.classList.add('active');
                              opt.style.borderColor = 'var(--nexus-accent)';
                              const check = document.createElement('div');
                              check.style = "position: absolute; bottom: 2px; right: 2px; background: var(--nexus-accent); color: white; border-radius: 50%; width: 18px; height: 18px; display: flex; align-items: center; justify-content: center; font-size: 10px;";
                              check.textContent = '✓';
                              opt.appendChild(check);
                              break;
                          }
                      }
                  } else {
                      showAlert('alertContainer', result.message, 'error');
                  }
              }).catch(err => showAlert('alertContainer', 'Network error', 'error'));
        }

        // Make sure form submission is handled
        document.querySelector('#submitModal form')?.addEventListener('submit', function(e) {
            e.preventDefault();
            const formData = new FormData(this);
            
            fetch(this.action, {
                method: 'POST',
                body: formData
            }).then(response => {
                if (response.redirected) {
                    const url = new URL(response.url);
                    const msg = url.searchParams.get('success');
                    const err = url.searchParams.get('error');
                    if (msg) {
                        showAlert('alertContainer', msg, 'success');
                        closeSubmitModal();
                        // Refresh the page to show updated task status
                        setTimeout(() => {
                            window.location.reload();
                        }, 1500);
                    } else if (err) {
                        showAlert('alertContainer', err, 'error');
                    }
                }
            }).catch(error => {
                console.error('Error:', error);
                showAlert('alertContainer', 'Network error occurred', 'error');
            });
        });

        // Initial setup
        window.onload = function() {
            // Restore last active tab
            const savedTab = localStorage.getItem('worker_active_tab');
            if (savedTab) {
                switchToPage(savedTab);
            }

            // Check for success/error messages in URL if needed
            const urlParams = new URLSearchParams(window.location.search);
            if (urlParams.has('success')) {
                showAlert('alertContainer', urlParams.get('success'), 'success');
            }
            if (urlParams.has('error')) {
                showAlert('alertContainer', urlParams.get('error'), 'error');
            }
        };
    </script>
</body>
</html>
