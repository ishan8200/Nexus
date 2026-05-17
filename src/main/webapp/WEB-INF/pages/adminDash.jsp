<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, com.nex.model.User" %>
<%
    // Dashboard data from controller with safety checks
    String pageAnalyticsFilter = (String) request.getAttribute("analyticsFilter");
    if (pageAnalyticsFilter == null) pageAnalyticsFilter = "my";
    
    String taskFilter = (String) request.getAttribute("taskFilter");
    if (taskFilter == null) taskFilter = "my";

    // Check if user is logged in and is admin
    User currentUser = (User) request.getAttribute("currentUser");
    if (currentUser == null || !"admin".equals(currentUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    // Dashboard Statistics
    int totalTasks = request.getAttribute("totalTasks") != null ? (int) request.getAttribute("totalTasks") : 0;
    int completedTasks = request.getAttribute("completedTasks") != null ? (int) request.getAttribute("completedTasks") : 0;
    int activeWorkers = request.getAttribute("activeWorkers") != null ? (int) request.getAttribute("activeWorkers") : 0;
    double wagesDisbursed = request.getAttribute("wagesDisbursed") != null ? (double) request.getAttribute("wagesDisbursed") : 0.0;
    int pendingSubmissions = request.getAttribute("pendingSubmissions") != null ? (int) request.getAttribute("pendingSubmissions") : 0;

    // Performance Metrics
    double avgRating = request.getAttribute("avgRating") != null ? (double) request.getAttribute("avgRating") : 0.0;
    double taskEfficiency = request.getAttribute("taskEfficiency") != null ? (double) request.getAttribute("taskEfficiency") : 0.0;
    double networkGrowth = request.getAttribute("networkGrowth") != null ? (double) request.getAttribute("networkGrowth") : 0.0;
    double systemHealth = request.getAttribute("systemHealth") != null ? (double) request.getAttribute("systemHealth") : 0.0;

    // List Data
    List<Map<String, Object>> recentTasks = (List<Map<String, Object>>) request.getAttribute("recentTasks");
    if (recentTasks == null) recentTasks = new ArrayList<>();
    
    List<User> pendingWorkersList = (List<User>) request.getAttribute("pendingWorkersList");
    if (pendingWorkersList == null) pendingWorkersList = new ArrayList<>();
    
    List<Map<String, Object>> pendingSubmissionsList = (List<Map<String, Object>>) request.getAttribute("pendingSubmissionsList");
    if (pendingSubmissionsList == null) pendingSubmissionsList = new ArrayList<>();
    
    List<User> allWorkers = (List<User>) request.getAttribute("allWorkers");
    if (allWorkers == null) allWorkers = new ArrayList<>();
    
    List<Map<String, Object>> allTasks = (List<Map<String, Object>>) request.getAttribute("allTasks");
    if (allTasks == null) allTasks = new ArrayList<>();
    
    List<Map<String, Object>> wageSummary = (List<Map<String, Object>>) request.getAttribute("wageSummary");
    if (wageSummary == null) wageSummary = new ArrayList<>();

    List<Map<String, Object>> pendingWages = (List<Map<String, Object>>) request.getAttribute("pendingWages");
    if (pendingWages == null) pendingWages = new ArrayList<>();

    List<Map<String, Object>> paidWages = (List<Map<String, Object>>) request.getAttribute("paidWages");
    if (paidWages == null) paidWages = new ArrayList<>();

    // Formatter for currency
    java.text.NumberFormat cur = java.text.NumberFormat.getCurrencyInstance(new Locale("en", "NP"));

    // Search and Sort Parameters
    String taskSearch = (String) request.getAttribute("taskSearch");
    String workerSearch = (String) request.getAttribute("workerSearch");
    String wageSearch = (String) request.getAttribute("wageSearch");
    String paymentSearch = (String) request.getAttribute("paymentSearch");
    if (taskSearch == null) taskSearch = "";
    if (workerSearch == null) workerSearch = "";
    if (wageSearch == null) wageSearch = "";
    if (paymentSearch == null) paymentSearch = "";

    String taskSortBy = (String) request.getAttribute("taskSortBy");
    String taskSortDir = (String) request.getAttribute("taskSortDir");
    String workerSortBy = (String) request.getAttribute("workerSortBy");
    String workerSortDir = (String) request.getAttribute("workerSortDir");
    String wageSortBy = (String) request.getAttribute("wageSortBy");
    String wageSortDir = (String) request.getAttribute("wageSortDir");
    String paymentSortBy = (String) request.getAttribute("paymentSortBy");
    String paymentSortDir = (String) request.getAttribute("paymentSortDir");

    if (taskSortBy == null) taskSortBy = "title";
    if (taskSortDir == null) taskSortDir = "ASC";
    if (workerSortBy == null) workerSortBy = "full_name";
    if (workerSortDir == null) workerSortDir = "ASC";
    if (wageSortBy == null) wageSortBy = "date";
    if (wageSortDir == null) wageSortDir = "DESC";
    if (paymentSortBy == null) paymentSortBy = "date";
    if (paymentSortDir == null) paymentSortDir = "DESC";

    // CMS Settings
    Map<String, String> siteSettings = (Map<String, String>) request.getAttribute("siteSettings");
    if (siteSettings == null) siteSettings = new HashMap<>();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard | Nexus Works</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:opsz,wght@14..32,300;14..32,400;14..32,500;14..32,600;14..32,700;14..32,800&family=JetBrains+Mono:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="${pageContext.request.contextPath}/js/alert.js"></script>
    <script src="${pageContext.request.contextPath}/js/dashboard-utils.js"></script>
    <style>
        /* Custom overrides for dashboard specific elements */
        .admin-main { scroll-behavior: smooth; }
        .nav-badge { background: var(--nexus-accent); color: white; padding: 2px 8px; border-radius: 10px; font-size: 10px; font-weight: 700; margin-left: auto; }
        .stat-card {
            background: white;
            border: 1px solid var(--nexus-border);
            border-radius: var(--radius-lg);
            padding: var(--space-lg);
            transition: all var(--transition-smooth);
            position: relative;
            overflow: hidden;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.02);
        }
        .stat-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 20px rgba(0, 0, 0, 0.05);
            border-color: var(--nexus-accent-glow);
        }
        .stat-card::before { content: ''; position: absolute; left: 0; top: 0; height: 100%; width: 4px; background: var(--nexus-accent); }
        .stat-header { display: flex; align-items: center; gap: 12px; margin-bottom: 12px; }
        .stat-icon { font-size: 24px; }
        .stat-label { font-size: 12px; font-weight: 600; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.05em; }
        .stat-value { font-size: 28px; font-weight: 800; color: var(--text-primary); font-family: 'JetBrains Mono', monospace; }
        
        .page-section { display: none; animation: fadeIn 0.4s ease-out; }
        .page-section.active { display: block; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
        
        .action-card {
            padding: 20px;
            background: var(--nexus-surface);
            border: 1px solid var(--nexus-border);
            border-radius: var(--radius-md);
            display: flex;
            align-items: center;
            gap: 15px;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        .action-card:hover {
            border-color: var(--nexus-accent);
            background: var(--nexus-accent-light);
        }
        .action-icon { font-size: 24px; }
        .action-info h4 { font-weight: 700; margin-bottom: 2px; }
        .action-info p { font-size: 12px; color: var(--text-muted); }

        .submission-card {
            padding: 20px;
            background: white;
            border: 1px solid var(--nexus-border);
            border-radius: var(--radius-md);
            margin-bottom: 15px;
        }
        .submission-card-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 15px; }
        .submission-worker { font-weight: 700; font-size: 16px; }
        .submission-date { font-size: 12px; color: var(--text-muted); }
        .submission-body { font-size: 14px; margin-bottom: 15px; color: var(--text-secondary); }

        /* Reports styling */
        .reports-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 20px; margin-top: 20px; }
        .report-item {
            padding: 25px;
            background: white;
            border: 1px solid var(--nexus-border);
            border-radius: var(--radius-lg);
            display: flex;
            flex-direction: column;
            gap: 15px;
            transition: all 0.3s ease;
        }
        .report-item:hover { border-color: var(--nexus-accent); box-shadow: 0 10px 30px rgba(0,0,0,0.05); }
        .report-icon { font-size: 32px; background: var(--nexus-surface); width: 60px; height: 60px; display: flex; align-items: center; justify-content: center; border-radius: 12px; }
        .report-info h4 { margin-bottom: 5px; font-weight: 700; }
        .report-info p { font-size: 13px; color: var(--text-muted); line-height: 1.5; }

        /* Interactive Rating Stars */
        .rating-stars {
            display: flex;
            gap: 2px;
            cursor: pointer;
        }
        .star {
            font-size: 18px;
            color: var(--nexus-border);
            transition: all 0.2s ease;
        }
        .star.active {
            color: var(--nexus-accent);
        }
        .star:hover, .star:hover ~ .star {
            color: var(--nexus-accent-glow);
        }
        .rating-stars:hover .star {
            color: var(--nexus-accent);
        }
        .star:hover ~ .star {
            color: var(--nexus-border) !important;
        }

        /* Star Input for Approval */
        .star-input {
            font-size: 20px;
            color: #d1d5db;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        .star-input.active {
            color: var(--nexus-accent);
        }
        .star-input:hover, .star-input:hover ~ .star-input {
            color: var(--nexus-accent-glow);
        }
        .rating-stars-input:hover .star-input {
            color: var(--nexus-accent);
        }
        .star-input:hover ~ .star-input {
            color: #d1d5db !important;
        }

        /* Remove internal scroll from settings and create task cards */
        #settingsView .admin-card-body,
        #createTaskView .admin-card-body {
            max-height: none;
            overflow: visible;
        }
    </style>
</head>
<body>
    <!-- Top Navigation Bar -->
    <nav class="navbar">
        <div class="nav-container">
            <a href="${pageContext.request.contextPath}/" class="logo">
                <img src="${pageContext.request.contextPath}<%= siteSettings.getOrDefault("site_logo_url", "/images/Nexuslogo_1.jpg") %>" alt="Nexus Logo" style="height: 40px; width: auto;">
            </a>
            <div class="nav-links">
                <a href="${pageContext.request.contextPath}/">Home</a>
                <a href="${pageContext.request.contextPath}/about">About</a>
                <a href="${pageContext.request.contextPath}/contact">Contact</a>
                <a href="#" class="active">Dashboard</a>
                <div style="display: flex; align-items: center; gap: 10px; margin-left: 10px; padding-left: 10px; border-left: 1px solid var(--nexus-border);">
                    <div class="nav-avatar" style="width: 32px; height: 32px; border-radius: 50%; overflow: hidden; background: var(--nexus-accent-light); display: flex; align-items: center; justify-content: center; font-size: 14px; font-weight: 700; color: var(--nexus-accent);">
                        <% if (currentUser.getProfilePic() != null && !currentUser.getProfilePic().isEmpty()) { %>
                            <img src="${pageContext.request.contextPath}/images/<%= currentUser.getProfilePic() %>" alt="Profile" style="width: 100%; height: 100%; object-fit: cover;">
                        <% } else { %>
                            <%= currentUser.getFullName().substring(0, 1).toUpperCase() %>
                        <% } %>
                    </div>
                    <a href="${pageContext.request.contextPath}/logout" class="btn-login-nav" style="margin-left: 0;">Logout</a>
                </div>
            </div>
        </div>
    </nav>

    <!-- Admin Layout -->
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
                        <p>Administrator</p>
                    </div>
                </div>
            </div>
            
            <nav class="sidebar-nav">
                <div class="nav-section-title">MAIN</div>
                <a href="javascript:void(0)" class="nav-item active" onclick="switchToPage('dashboard')">
                    <span class="nav-icon"><i class="fas fa-chart-line"></i></span>
                    <span class="nav-text">Dashboard</span>
                </a>
                <a href="javascript:void(0)" class="nav-item" onclick="switchToPage('tasks')">
                    <span class="nav-icon"><i class="fas fa-tasks"></i></span>
                    <span class="nav-text">All Tasks</span>
                    <span class="nav-badge"><%= totalTasks %></span>
                </a>
                <a href="javascript:void(0)" class="nav-item" onclick="switchToPage('createTask')">
                    <span class="nav-icon"><i class="fas fa-plus-circle"></i></span>
                    <span class="nav-text">Create Task</span>
                </a>
                
                <div class="nav-section-title">MANAGEMENT</div>
                <a href="javascript:void(0)" class="nav-item" onclick="switchToPage('workers')">
                    <span class="nav-icon"><i class="fas fa-users-cog"></i></span>
                    <span class="nav-text">Workers</span>
                    <span class="nav-badge"><%= activeWorkers %></span>
                </a>
                <a href="javascript:void(0)" class="nav-item" onclick="switchToPage('submissions')">
                    <span class="nav-icon"><i class="fas fa-file-invoice"></i></span>
                    <span class="nav-text">Submissions</span>
                    <span class="nav-badge"><%= pendingSubmissions %></span>
                </a>
                <a href="javascript:void(0)" class="nav-item" onclick="switchToPage('wages')">
                    <span class="nav-icon"><i class="fas fa-wallet"></i></span>
                    <span class="nav-text">Payments</span>
                </a>
                <a href="javascript:void(0)" class="nav-item" onclick="switchToPage('paymentHistory')">
                    <span class="nav-icon"><i class="fas fa-history"></i></span>
                    <span class="nav-text">Payment History</span>
                </a>
                
                <div class="nav-section-title">REPORTS</div>
                <a href="javascript:void(0)" class="nav-item" onclick="switchToPage('analytics')">
                    <span class="nav-icon"><i class="fas fa-chart-bar"></i></span>
                    <span class="nav-text">Analytics</span>
                </a>
                <a href="javascript:void(0)" class="nav-item" onclick="switchToPage('reports')">
                    <span class="nav-icon"><i class="fas fa-file-export"></i></span>
                    <span class="nav-text">Export Reports</span>
                </a>
                
                <div class="nav-section-title">ACCOUNT</div>
                <a href="javascript:void(0)" class="nav-item" onclick="switchToPage('settings')">
                    <span class="nav-icon"><i class="fas fa-user-circle"></i></span>
                    <span class="nav-text">Profile & Settings</span>
                </a>
            </nav>
        </aside>

        <!-- Mobile Toggle -->
        <button class="sidebar-toggle" id="sidebarToggle" style="display: none;">☰</button>

        <!-- Main Content -->
        <main class="admin-main">
            <div id="alertContainer"></div>

            <div class="admin-main-header">
                <div class="page-title">
                    <div>
                        <h1 id="pageTitle">Admin Dashboard</h1>
                        <p id="pageSubtitle">System overview and mission control.</p>
                    </div>
                </div>
            </div>

            <!-- Dashboard View -->
            <div id="dashboardView" class="page-section active">
                <div style="display: flex; justify-content: flex-end; margin-bottom: 15px;">
                    <div class="filter-group" style="display: flex; gap: 10px; background: white; padding: 5px; border-radius: var(--radius-md); border: 1px solid var(--nexus-border);">
                        <button class="btn <%= "my".equals(pageAnalyticsFilter) ? "btn-primary" : "btn-secondary" %>" style="padding: 6px 12px; font-size: 12px;" onclick="applyAnalyticsFilter('my')">My Stats</button>
                        <button class="btn <%= "all".equals(pageAnalyticsFilter) ? "btn-primary" : "btn-secondary" %>" style="padding: 6px 12px; font-size: 12px;" onclick="applyAnalyticsFilter('all')">All Stats</button>
                    </div>
                </div>
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-header">
                            <span class="stat-icon"><i class="fas fa-clipboard-list" style="color: var(--nexus-accent);"></i></span>
                            <span class="stat-label">Total Tasks</span>
                        </div>
                        <div class="stat-value"><%= totalTasks %></div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-header">
                            <span class="stat-icon"><i class="fas fa-users" style="color: var(--nexus-success);"></i></span>
                            <span class="stat-label">Workers</span>
                        </div>
                        <div class="stat-value"><%= activeWorkers %></div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-header">
                            <span class="stat-icon"><i class="fas fa-check-double" style="color: var(--nexus-accent);"></i></span>
                            <span class="stat-label">Completed</span>
                        </div>
                        <div class="stat-value"><%= completedTasks %></div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-header">
                            <span class="stat-icon"><i class="fas fa-money-bill-wave" style="color: #8b5cf6;"></i></span>
                            <span class="stat-label">Disbursed</span>
                        </div>
                        <div class="stat-value">Rs. <%= String.format("%,.1f", wagesDisbursed / 1000) %>K</div>
                    </div>
                </div>

                <div class="dashboard-grid">
                    <div class="admin-card">
                    <div class="admin-card-header">
                        <h3><i class="fas fa-bolt" style="color: var(--nexus-accent); margin-right: 8px;"></i>Quick Actions</h3>
                    </div>
                        <div class="admin-card-body" style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px; padding: 20px;">
                            <div class="action-card" onclick="switchToPage('createTask')">
                                <span class="action-icon"><i class="fas fa-plus-circle" style="color: var(--nexus-accent);"></i></span>
                                <div class="action-info">
                                    <h4>New Task</h4>
                                    <p>Deploy mission</p>
                                </div>
                            </div>
                            <div class="action-card" onclick="switchToPage('submissions')">
                                <span class="action-icon"><i class="fas fa-file-signature" style="color: var(--nexus-warning);"></i></span>
                                <div class="action-info">
                                    <h4>Review Work</h4>
                                    <p><%= pendingSubmissions %> pending</p>
                                </div>
                            </div>
                            <div class="action-card" onclick="switchToPage('workers')">
                                <span class="action-icon"><i class="fas fa-user-friends" style="color: var(--nexus-success);"></i></span>
                                <div class="action-info">
                                    <h4>Manage Talent</h4>
                                    <p><%= activeWorkers %> active</p>
                                </div>
                            </div>
                            <div class="action-card" onclick="switchToPage('wages')">
                                <span class="action-icon"><i class="fas fa-hand-holding-usd" style="color: #8b5cf6;"></i></span>
                                <div class="action-info">
                                    <h4>Process Payouts</h4>
                                    <p>Financial audit</p>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="admin-card">
                        <div class="admin-card-header">
                            <h3><i class="fas fa-hourglass-half" style="color: var(--nexus-accent); margin-right: 8px;"></i>Pending Approvals</h3>
                            <button class="btn-icon" onclick="switchToPage('submissions')">View All →</button>
                        </div>
                        <div class="admin-card-body" style="padding: 0;">
                            <table class="admin-table">
                                <thead>
                                    <tr><th>Type</th><th>Name</th><th>Attachments</th><th>Date</th><th>Action</th></tr>
                                </thead>
                                <tbody>
                                    <% for (Map<String, Object> submission : pendingSubmissionsList) { %>
                                    <tr>
                                        <td><span class="status-badge pending">Submission</span></td>
                                        <td><strong><%= submission.get("worker_name") %></strong></td>
                                        <td>
                                            <% 
                                                String paths = (String) submission.get("attachment_path");
                                                if (paths != null && !paths.isEmpty()) { 
                                                    String[] pathArray = paths.split(",");
                                            %>
                                                <div style="display: flex; flex-direction: column; gap: 2px;">
                                                    <% for (int i = 0; i < pathArray.length; i++) { %>
                                                        <a href="${pageContext.request.contextPath}/submissions/<%= pathArray[i] %>" target="_blank" style="font-size: 10px; color: var(--nexus-accent); text-decoration: none;">📎 File <%= (pathArray.length > 1 ? (i + 1) : "") %></a>
                                                    <% } %>
                                                </div>
                                            <% } else { %>
                                                <span style="font-size: 10px; color: var(--text-muted);">None</span>
                                            <% } %>
                                        </td>
                                        <td style="font-size: 11px;"><%= submission.get("submitted_at") %></td>
                                        <td>
                                            <div style="display: flex; align-items: center; gap: 4px;">
                                                <select id="rating_<%= submission.get("id") %>" style="font-size: 10px; padding: 2px; border: 1px solid var(--nexus-border); border-radius: 4px; background: white;">
                                                    <option value="5">5★</option>
                                                    <option value="4">4★</option>
                                                    <option value="3">3★</option>
                                                    <option value="2">2★</option>
                                                    <option value="1">1★</option>
                                                </select>
                                                <button class="btn btn-primary" style="padding: 2px 6px; font-size: 10px;" onclick="approveSubmission(<%= submission.get("id") %>, this)">Approve</button>
                                            </div>
                                        </td>
                                    </tr>
                                    <% } %>
                                    <% for (User worker : pendingWorkersList) { %>
                                    <tr>
                                        <td><span class="status-badge pending">Registration</span></td>
                                        <td><strong><%= worker.getFullName() %></strong></td>
                                        <td>-</td>
                                        <td style="font-size: 11px;"><%= worker.getCreatedAt() %></td>
                                        <td>
                                            <button class="btn btn-primary" style="padding: 2px 6px; font-size: 10px;" onclick="approveWorker(<%= worker.getId() %>, this)">Approve</button>
                                        </td>
                                    </tr>
                                    <% } %>
                                    <% if (pendingSubmissionsList.isEmpty() && pendingWorkersList.isEmpty()) { %>
                                    <tr><td colspan="5" style="text-align: center; padding: 30px; color: var(--text-muted);">Clear for now.</td></tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Tasks View -->
            <div id="tasksView" class="page-section">
                <div class="admin-card">
                    <div class="admin-card-header" style="display: flex; justify-content: space-between; align-items: center;">
                        <h3><i class="fas fa-clipboard-list" style="color: var(--nexus-accent); margin-right: 8px;"></i>Mission Repository</h3>
                        <div class="filter-group" style="display: flex; gap: 10px;">
                            <button class="btn ${taskFilter == 'my' ? 'btn-primary' : 'btn-secondary'}" style="padding: 6px 12px; font-size: 12px;" onclick="applyTaskFilter('my')">My Posts</button>
                            <button class="btn ${taskFilter == 'all' ? 'btn-primary' : 'btn-secondary'}" style="padding: 6px 12px; font-size: 12px;" onclick="applyTaskFilter('all')">All Posts</button>
                        </div>
                    </div>
                    <div class="search-container">
                        <div class="search-group">
                            <div class="search-wrapper">
                                <span class="search-icon">🔍</span>
                                <input type="text" id="taskSearch" class="search-input" placeholder="Search missions by title, status, or priority..." value="<%= taskSearch %>" onkeypress="if(event.key === 'Enter') serverSideSearch('taskSearch', this.value)">
                            </div>
                            <button class="search-action-btn" onclick="serverSideSearch('taskSearch', document.getElementById('taskSearch').value)">Search</button>
                        </div>
                    </div>
                    <div class="admin-card-body" style="padding: 0;">
                        <table class="admin-table" id="tasksTable">
                            <thead>
                                <tr>
                                    <th class="sortable <%= (taskSortBy != null && taskSortBy.equals("title")) ? (taskSortDir != null && taskSortDir.equals("ASC") ? "sort-asc" : "sort-desc") : "" %>" onclick="serverSideSort('taskSortBy', 'title', 'taskSortDir')">Task Title</th>
                                    <th>Category</th>
                                    <th class="sortable <%= (taskSortBy != null && taskSortBy.equals("priority")) ? (taskSortDir != null && taskSortDir.equals("ASC") ? "sort-asc" : "sort-desc") : "" %>" onclick="serverSideSort('taskSortBy', 'priority', 'taskSortDir')">Priority</th>
                                    <th class="sortable <%= (taskSortBy != null && taskSortBy.equals("status")) ? (taskSortDir != null && taskSortDir.equals("ASC") ? "sort-asc" : "sort-desc") : "" %>" onclick="serverSideSort('taskSortBy', 'status', 'taskSortDir')">Status</th>
                                    <th class="sortable <%= (taskSortBy != null && taskSortBy.equals("wage")) ? (taskSortDir != null && taskSortDir.equals("ASC") ? "sort-asc" : "sort-desc") : "" %>" onclick="serverSideSort('taskSortBy', 'wage', 'taskSortDir')">Wage</th>
                                    <th>Est. Hours</th>
                                    <th class="sortable <%= (taskSortBy != null && taskSortBy.equals("deadline")) ? (taskSortDir != null && taskSortDir.equals("ASC") ? "sort-asc" : "sort-desc") : "" %>" onclick="serverSideSort('taskSortBy', 'deadline', 'taskSortDir')">Deadline</th>
                                    <th>Action</th>
                                 </tr>
                            </thead>
                            <tbody>
                                <% if (allTasks != null) { %>
                                    <% for (Map<String, Object> task : allTasks) { %>
                                        <tr>
                                            <td>
                                                <strong><%= task.get("title") %></strong>
                                                <div style="margin-top: 4px;">
                                                    <a href="javascript:void(0)" 
                                                       onclick="viewTaskDescription('<%= task.get("title").toString().replace("'", "\\'") %>', '<%= task.get("description") != null ? task.get("description").toString().replace("'", "\\'").replace("\n", " ").replace("\r", "") : "No description provided." %>', '<%= task.get("wage_type") != null ? task.get("wage_type").toString().substring(0, 1).toUpperCase() + task.get("wage_type").toString().substring(1) : "Fixed" %>')" 
                                                       style="font-size: 10px; color: var(--nexus-accent); text-decoration: none; display: flex; align-items: center; gap: 4px;">
                                                        <i class="fas fa-eye"></i> View Details
                                                    </a>
                                                </div>
                                             </td>
                                            <td><span class="status-badge" style="background: var(--nexus-surface); color: var(--text-primary); border: 1px solid var(--nexus-border);"><%= task.get("category") %></span></td>
                                            <td><span class="status-badge <%= ((String)task.get("priority")).toLowerCase() %>"><%= task.get("priority") %></span></td>
                                            <td><span class="status-badge <%= ((String)task.get("status")).toLowerCase().replace(" ", "-") %>"><%= task.get("status") %></span></td>
                                            <td style="font-family: 'JetBrains Mono'; font-weight: 700;"><%= cur.format(task.get("wage")) %></td>
                                            <td style="text-align: center;"><%= task.get("estimated_hours") %>h</td>
                                            <td><%= task.get("deadline") %></td>
                                            <td>
                                                <div style="display: flex; gap: 5px;">
                                                    <% 
                                                        String status = (String)task.get("status");
                                                        boolean isCreator = task.get("created_by") != null && (int)task.get("created_by") == currentUser.getId();
                                                        boolean isEditable = isCreator && !"completed".equalsIgnoreCase(status);
                                                        boolean isDeletable = isCreator && !"completed".equalsIgnoreCase(status) && !"in-progress".equalsIgnoreCase(status);
                                                    %>
                                                    
                                                    <% if (isCreator) { %>
                                                        <% if (isEditable) { %>
                                                            <button class="btn btn-primary" style="padding: 4px 8px; font-size: 11px;" 
                                                                onclick="openEditTaskModal('<%= task.get("id") %>', this)"
                                                                data-title="<%= task.get("title") != null ? task.get("title").toString().replace("\"", "&quot;") : "" %>"
                                                                data-category="<%= task.get("category") %>"
                                                                data-description="<%= task.get("description") != null ? task.get("description").toString().replace("\"", "&quot;") : "" %>"
                                                                data-wage="<%= task.get("wage") %>"
                                                                data-wagetype="<%= task.get("wage_type") %>"
                                                                data-deadline="<%= task.get("deadline") %>"
                                                                data-priority="<%= task.get("priority") %>"
                                                                data-estimatedhours="<%= task.get("estimated_hours") != null ? task.get("estimated_hours") : "0" %>">Edit</button>
                                                        <% } %>
                                                        
                                                        <% if (isDeletable) { %>
                                                            <button class="btn btn-secondary" style="padding: 4px 8px; font-size: 11px;" onclick="deleteTask(<%= task.get("id") %>, this)">Delete</button>
                                                        <% } %>
                                                        
                                                        <% if (!isEditable && !isDeletable) { %>
                                                            <span style="font-size: 10px; color: var(--text-muted); font-style: italic;">Locked (Finalized)</span>
                                                        <% } else if (!isDeletable && isEditable) { %>
                                                            <span style="font-size: 10px; color: var(--text-muted); font-style: italic;">Locked (Active)</span>
                                                        <% } %>
                                                    <% } else { %>
                                                        <span style="font-size: 10px; color: var(--text-muted); font-style: italic;">Read-only (Other Admin)</span>
                                                    <% } %>
                                                </div>
                                             </td>
                                         </tr>
                                    <% } %>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Create Task View -->
            <div id="createTaskView" class="page-section">
                <div class="admin-card" style="max-width: 800px; margin: 0 auto;">
                    <div class="admin-card-header">
                        <h3>Deploy New Mission</h3>
                    </div>
                    <div class="admin-card-body">
                        <form id="createTaskForm" onsubmit="deployMission(event)">
                            <div class="form-row">
                                <div class="form-group">
                                    <label class="form-label">Mission Title *</label>
                                    <input type="text" class="input-field" name="title" placeholder="e.g. Neural Engine UI Audit" required>
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Category *</label>
                                    <select class="input-field" name="category" required>
                                        <option value="Development">Development</option>
                                        <option value="Design">Design</option>
                                        <option value="Marketing">Marketing</option>
                                        <option value="Data Entry">Data Entry</option>
                                        <option value="QA">QA</option>
                                        <option value="Administrative">Administrative</option>
                                        <option value="Writing & Translation">Writing & Translation</option>
                                        <option value="Customer Service">Customer Service</option>
                                        <option value="Business & Finance">Business & Finance</option>
                                        <option value="AI & Machine Learning">AI & Machine Learning</option>
                                        <option value="Media & Production">Media & Production</option>
                                        <option value="General">General</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="form-label">Operational Context *</label>
                                <textarea class="textarea-field" name="description" placeholder="Describe the mission objectives..." rows="4" required></textarea>
                            </div>
                            <div class="form-row">
                                <div class="form-group">
                                    <label class="form-label">Contract Value *</label>
                                    <input type="number" step="0.01" class="input-field" name="wage" placeholder="0.00" required>
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Estimated Hours</label>
                                    <input type="number" class="input-field" name="estimatedHours" placeholder="e.g. 10" min="0">
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Payment Type</label>
                                    <select class="select-field" name="wageType">
                                        <option value="fixed">Fixed Rate</option>
                                        <option value="hourly">Hourly Velocity</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-row">
                                <div class="form-group">
                                    <label class="form-label">Operational Deadline *</label>
                                    <input type="date" class="input-field" name="deadline" required>
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Mission Priority</label>
                                    <select class="select-field" name="priority">
                                        <option value="low">Standard</option>
                                        <option value="medium" selected>High</option>
                                        <option value="high">Critical</option>
                                        <option value="urgent">Sovereign Urgent</option>
                                    </select>
                                </div>
                            </div>
                            <div style="display: flex; gap: var(--space-sm); justify-content: flex-end; margin-top: 20px;">
                                <button type="button" class="btn btn-secondary" onclick="switchToPage('dashboard')">Abort</button>
                                <button type="submit" class="btn btn-primary">Deploy Mission</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Workers View -->
            <div id="workersView" class="page-section">
                <div class="admin-card">
                    <div class="admin-card-header">
                        <h3><i class="fas fa-users" style="color: var(--nexus-accent); margin-right: 8px;"></i>Talent Management</h3>
                    </div>
                    <div class="search-container">
                        <div class="search-group">
                            <div class="search-wrapper">
                                <span class="search-icon">🔍</span>
                                <input type="text" id="workerSearch" class="search-input" placeholder="Search talent by name, email, or status..." value="<%= workerSearch %>" onkeypress="if(event.key === 'Enter') serverSideSearch('workerSearch', this.value)">
                            </div>
                            <button class="search-action-btn" onclick="serverSideSearch('workerSearch', document.getElementById('workerSearch').value)">Search</button>
                        </div>
                    </div>
                    <div class="admin-card-body" style="padding: 0;">
                        <table class="admin-table" id="workersTable">
                            <thead>
                                <tr>
                                    <th class="sortable <%= (workerSortBy != null && workerSortBy.equals("full_name")) ? (workerSortDir != null && workerSortDir.equals("ASC") ? "sort-asc" : "sort-desc") : "" %>" onclick="serverSideSort('workerSortBy', 'full_name', 'workerSortDir')">Full Name</th>
                                    <th class="sortable <%= (workerSortBy != null && workerSortBy.equals("tasks")) ? (workerSortDir != null && workerSortDir.equals("ASC") ? "sort-asc" : "sort-desc") : "" %>" onclick="serverSideSort('workerSortBy', 'tasks', 'workerSortDir')">Tasks</th>
                                    <th class="sortable <%= (workerSortBy != null && workerSortBy.equals("rating")) ? (workerSortDir != null && workerSortDir.equals("ASC") ? "sort-asc" : "sort-desc") : "" %>" onclick="serverSideSort('workerSortBy', 'rating', 'workerSortDir')">Rating</th>
                                    <th class="sortable <%= (workerSortBy != null && workerSortBy.equals("earned")) ? (workerSortDir != null && workerSortDir.equals("ASC") ? "sort-asc" : "sort-desc") : "" %>" onclick="serverSideSort('workerSortBy', 'earned', 'workerSortDir')">Total Earned</th>
                                    <th class="sortable <%= (workerSortBy != null && workerSortBy.equals("status")) ? (workerSortDir != null && workerSortDir.equals("ASC") ? "sort-asc" : "sort-desc") : "" %>" onclick="serverSideSort('workerSortBy', 'status', 'workerSortDir')">Status</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (User worker : allWorkers) { %>
                                <tr>
                                    <td><strong><%= worker.getFullName() %></strong><br><small style="color: var(--text-muted);"><%= worker.getEmail() %></small></td>
                                    <td><%= worker.getTasksCompleted() %></td>
                                    <td>
                                        <div class="rating-stars" data-worker-id="<%= worker.getId() %>">
                                            <% 
                                                double currentRating = worker.getRating();
                                                for(int i = 1; i <= 5; i++) { 
                                            %>
                                                <span class="star <%= i <= currentRating ? "active" : "" %>" onclick="rateWorker(<%= worker.getId() %>, <%= i %>, this)">★</span>
                                            <% } %>
                                        </div>
                                    </td>
                                    <td style="font-family: 'JetBrains Mono';"><%= cur.format(worker.getTotalEarned()) %></td>
                                    <td><span class="status-badge <%= worker.getStatus().toLowerCase() %>"><%= worker.getStatus() %></span></td>
                                    <td>
                                        <% if ("pending".equals(worker.getStatus())) { %>
                                            <button class="btn btn-primary" style="padding: 4px 8px; font-size: 11px;" onclick="approveWorker(<%= worker.getId() %>, this)">Approve</button>
                                        <% } else { %>
                                            <button class="btn btn-outline" style="padding: 4px 8px; font-size: 11px;" 
                                                onclick="manageWorker(<%= worker.getId() %>, '<%= worker.getStatus() %>', this)"
                                                data-name="<%= worker.getFullName() %>"
                                                data-email="<%= worker.getEmail() %>"
                                                data-phone="<%= worker.getPhone() != null ? worker.getPhone() : "N/A" %>"
                                                data-skills="<% 
                                                    if (worker.getSkillList() != null && !worker.getSkillList().isEmpty()) {
                                                        StringBuilder sb = new StringBuilder();
                                                        for (int i = 0; i < worker.getSkillList().size(); i++) {
                                                            sb.append(worker.getSkillList().get(i).getSkillName());
                                                            if (i < worker.getSkillList().size() - 1) sb.append(", ");
                                                        }
                                                        out.print(sb.toString());
                                                    } else {
                                                        out.print("No skills listed");
                                                    }
                                                %>"
                                                data-rating="<%= String.format("%.1f", worker.getRating()) %>"
                                                data-earned="<%= cur.format(worker.getTotalEarned()) %>"
                                                data-tasks="<%= worker.getTasksCompleted() %>">Manage</button>
                                        <% } %>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Submissions View -->
            <div id="submissionsView" class="page-section">
                <div class="admin-card">
                    <div class="admin-card-header">
                        <h3><i class="fas fa-file-signature" style="color: var(--nexus-accent); margin-right: 8px;"></i>Pending Work Submissions</h3>
                    </div>
                    <div class="admin-card-body">
                        <% for (Map<String, Object> submission : pendingSubmissionsList) { %>
                        <div class="submission-card">
                            <div class="submission-card-header">
                                <div>
                                    <span class="submission-worker">👤 <%= submission.get("worker_name") %></span>
                                    <p class="submission-date">Submitted: <%= submission.get("submitted_at") %></p>
                                </div>
                                <span class="status-badge pending">Pending Review</span>
                            </div>
                            <div class="submission-body">
                                <strong>Task:</strong> <%= submission.get("task_title") %><br>
                                <strong>Notes:</strong> <%= submission.get("submission_text") %><br>
                                <% 
                                    String paths = (String) submission.get("attachment_path");
                                    if (paths != null && !paths.isEmpty()) { 
                                        String[] pathArray = paths.split(",");
                                %>
                                    <strong>Attachments:</strong><br>
                                    <div style="display: flex; flex-direction: column; gap: 5px; margin-top: 5px;">
                                        <% for (int i = 0; i < pathArray.length; i++) { 
                                            String p = pathArray[i];
                                        %>
                                            <a href="${pageContext.request.contextPath}/submissions/<%= p %>" target="_blank" class="btn-link" style="color: var(--nexus-accent); font-weight: 600;">📎 Download Deliverable <%= (pathArray.length > 1 ? (i + 1) : "") %></a>
                                        <% } %>
                                    </div>
                                <% } %>
                            </div>
                            <div class="rating-input" style="margin-bottom: 15px;">
                                <label class="form-label" style="font-size: 13px; font-weight: 600; color: var(--text-secondary);">Quality Rating:</label>
                                <div class="rating-stars-input" data-submission-id="<%= submission.get("id") %>" style="display: flex; gap: 5px; margin-top: 5px;">
                                    <% for(int i = 1; i <= 5; i++) { %>
                                        <span class="star-input <%= i <= 5 ? "active" : "" %>" data-value="<%= i %>" onclick="setApprovalRating(<%= submission.get("id") %>, <%= i %>)">★</span>
                                    <% } %>
                                    <input type="hidden" id="rating_<%= submission.get("id") %>" value="5">
                                </div>
                            </div>
                            <div style="display: flex; gap: 10px;">
                                <button class="btn btn-primary" style="padding: 8px 16px;" onclick="approveSubmission(<%= submission.get("id") %>, this)">Approve</button>
                                <button class="btn btn-secondary" style="padding: 8px 16px;" onclick="rejectSubmission(<%= submission.get("id") %>, this)">Reject</button>
                            </div>
                        </div>
                        <% } %>
                        <% if (pendingSubmissionsList.isEmpty()) { %>
                        <div style="text-align: center; padding: 100px; color: var(--text-muted);">No submissions awaiting review.</div>
                        <% } %>
                    </div>
                </div>
            </div>

            <!-- Wages View -->
            <div id="wagesView" class="page-section">
                <div class="admin-card">
                    <div class="admin-card-header">
                        <h3>💰 Individual Wage Disbursement</h3>
                    </div>
                    <div class="search-container">
                        <div class="search-group">
                            <div class="search-wrapper">
                                <span class="search-icon">🔍</span>
                                <input type="text" id="wageSearch" class="search-input" placeholder="Search by worker or task..." value="<%= wageSearch %>" onkeypress="if(event.key === 'Enter') serverSideSearch('wageSearch', this.value)">
                            </div>
                            <button class="search-action-btn" onclick="serverSideSearch('wageSearch', document.getElementById('wageSearch').value)">Search</button>
                        </div>
                    </div>
                    <div class="admin-card-body" style="padding: 0;">
                        <table class="admin-table" id="wagesTable">
                            <thead>
                                <tr>
                                    <th class="sortable <%= (wageSortBy != null && wageSortBy.equals("worker")) ? (wageSortDir != null && wageSortDir.equals("ASC") ? "sort-asc" : "sort-desc") : "" %>" onclick="serverSideSort('wageSortBy', 'worker', 'wageSortDir')">Worker</th>
                                    <th class="sortable <%= (wageSortBy != null && wageSortBy.equals("task")) ? (wageSortDir != null && wageSortDir.equals("ASC") ? "sort-asc" : "sort-desc") : "" %>" onclick="serverSideSort('wageSortBy', 'task', 'wageSortDir')">Task Title</th>
                                    <th class="sortable <%= (wageSortBy != null && wageSortBy.equals("amount")) ? (wageSortDir != null && wageSortDir.equals("ASC") ? "sort-asc" : "sort-desc") : "" %>" onclick="serverSideSort('wageSortBy', 'amount', 'wageSortDir')">Amount</th>
                                    <th class="sortable <%= (wageSortBy != null && wageSortBy.equals("date")) ? (wageSortDir != null && wageSortDir.equals("ASC") ? "sort-asc" : "sort-desc") : "" %>" onclick="serverSideSort('wageSortBy', 'date', 'wageSortDir')">Approved Date</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% 
                                    // Use the existing pendingWages variable declared at the top
                                    if (pendingWages != null) {
                                        for (Map<String, Object> wage : pendingWages) { 
                                %>
                                <tr>
                                    <td><strong><%= wage.get("worker_name") %></strong></td>
                                    <td><%= wage.get("task_title") %></td>
                                    <td style="font-family: 'JetBrains Mono'; font-weight: 700; color: var(--nexus-success);"><%= cur.format(wage.get("amount")) %></td>
                                    <td style="font-size: 11px;"><%= wage.get("created_at") %></td>
                                    <td>
                                        <button class="btn btn-primary" style="padding: 4px 12px; font-size: 12px;" onclick="markAsPaid(<%= wage.get("wage_id") %>, this)">Pay Task</button>
                                    </td>
                                </tr>
                                <% 
                                        } 
                                    }
                                %>
                                <% if (pendingWages == null || pendingWages.isEmpty()) { %>
                                <tr><td colspan="5" style="text-align: center; padding: 50px; color: var(--text-muted);">No pending wages to disburse.</td></tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Payment History View -->
            <div id="paymentHistoryView" class="page-section">
                <div class="admin-card">
                    <div class="admin-card-header">
                        <h3><i class="fas fa-history" style="color: var(--nexus-accent); margin-right: 8px;"></i>Operational Payment Ledger</h3>
                    </div>
                    <div class="search-container">
                        <div class="search-group">
                            <div class="search-wrapper">
                                <span class="search-icon">🔍</span>
                                <input type="text" id="paymentSearch" class="search-input" placeholder="Search by worker, task, or transaction ID..." value="<%= paymentSearch %>" onkeypress="if(event.key === 'Enter') serverSideSearch('paymentSearch', this.value)">
                            </div>
                            <button class="search-action-btn" onclick="serverSideSearch('paymentSearch', document.getElementById('paymentSearch').value)">Search</button>
                        </div>
                    </div>
                    <div class="admin-card-body" style="padding: 0;">
                        <table class="admin-table" id="paymentsTable">
                            <thead>
                                <tr>
                                    <th class="sortable <%= (paymentSortBy != null && paymentSortBy.equals("worker")) ? (paymentSortDir != null && paymentSortDir.equals("ASC") ? "sort-asc" : "sort-desc") : "" %>" onclick="serverSideSort('paymentSortBy', 'worker', 'paymentSortDir')">Worker</th>
                                    <th class="sortable <%= (paymentSortBy != null && paymentSortBy.equals("task")) ? (paymentSortDir != null && paymentSortDir.equals("ASC") ? "sort-asc" : "sort-desc") : "" %>" onclick="serverSideSort('paymentSortBy', 'task', 'paymentSortDir')">Task Title</th>
                                    <th class="sortable <%= (paymentSortBy != null && paymentSortBy.equals("amount")) ? (paymentSortDir != null && paymentSortDir.equals("ASC") ? "sort-asc" : "sort-desc") : "" %>" onclick="serverSideSort('paymentSortBy', 'amount', 'paymentSortDir')">Amount</th>
                                    <th class="sortable <%= (paymentSortBy != null && paymentSortBy.equals("method")) ? (paymentSortDir != null && paymentSortDir.equals("ASC") ? "sort-asc" : "sort-desc") : "" %>" onclick="serverSideSort('paymentSortBy', 'method', 'paymentSortDir')">Method</th>
                                    <th class="sortable <%= (paymentSortBy != null && paymentSortBy.equals("date")) ? (paymentSortDir != null && paymentSortDir.equals("ASC") ? "sort-asc" : "sort-desc") : "" %>" onclick="serverSideSort('paymentSortBy', 'date', 'paymentSortDir')">Paid Date</th>
                                    <th>Transaction ID</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% 
                                    // Use the existing paidWages variable declared at the top
                                    if (paidWages != null) {
                                        for (Map<String, Object> payment : paidWages) { 
                                %>
                                <tr>
                                    <td><strong><%= payment.get("worker_name") %></strong></td>
                                    <td><%= payment.get("task_title") %></td>
                                    <td style="font-family: 'JetBrains Mono'; font-weight: 700; color: var(--nexus-success);"><%= cur.format(payment.get("amount")) %></td>
                                    <td><span class="status-badge" style="background: var(--nexus-surface); color: var(--text-primary); border: 1px solid var(--nexus-border);"><%= payment.get("payment_method") != null ? payment.get("payment_method") : "N/A" %></span></td>
                                    <td style="font-size: 11px;"><%= payment.get("paid_at") %></td>
                                    <td><code style="font-size: 10px; background: var(--nexus-surface); padding: 2px 5px; border-radius: 4px;"><%= payment.get("transaction_id") != null ? payment.get("transaction_id") : "N/A" %></code></td>
                                </tr>
                                <% 
                                        } 
                                    }
                                %>
                                <% if (paidWages == null || paidWages.isEmpty()) { %>
                                <tr><td colspan="6" style="text-align: center; padding: 50px; color: var(--text-muted);">No payment history found.</td></tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Analytics View -->
            <div id="analyticsView" class="page-section">
                <div style="display: flex; justify-content: flex-end; margin-bottom: 20px;">
                    <div class="filter-group" style="display: flex; gap: 10px; background: white; padding: 5px; border-radius: var(--radius-md); border: 1px solid var(--nexus-border);">
                        <button class="btn <%= "my".equals(pageAnalyticsFilter) ? "btn-primary" : "btn-secondary" %>" style="padding: 6px 12px; font-size: 12px;" onclick="applyAnalyticsFilter('my')">My Stats</button>
                        <button class="btn <%= "all".equals(pageAnalyticsFilter) ? "btn-primary" : "btn-secondary" %>" style="padding: 6px 12px; font-size: 12px;" onclick="applyAnalyticsFilter('all')">All Stats</button>
                    </div>
                </div>
                <div class="dashboard-grid">
                    <div class="admin-card">
                        <div class="admin-card-header">
                            <h3>📈 Task Velocity & Trends</h3>
                        </div>
                        <div class="admin-card-body" style="padding: 20px;">
                            <canvas id="trendsChart" style="width: 100%; height: 300px;"></canvas>
                        </div>
                    </div>
                </div>
                
                <div class="dashboard-grid" style="margin-top: 20px;">
                    <div class="admin-card">
                        <div class="admin-card-header">
                            <h3><i class="fas fa-layer-group" style="color: var(--nexus-accent); margin-right: 8px;"></i>Mission Distribution (Category)</h3>
                        </div>
                        <div class="admin-card-body" style="padding: 20px;">
                            <canvas id="categoryChart" style="width: 100%; height: 250px;"></canvas>
                        </div>
                    </div>
                    <div class="admin-card">
                        <div class="admin-card-header">
                            <h3><i class="fas fa-flag" style="color: #f59e0b; margin-right: 8px;"></i>Mission Distribution (Priority)</h3>
                        </div>
                        <div class="admin-card-body" style="padding: 20px;">
                            <canvas id="priorityChart" style="width: 100%; height: 250px;"></canvas>
                        </div>
                    </div>
                </div>
                
                <div class="admin-card" style="margin-top: 20px;">
                    <div class="admin-card-header">
                        <h3>⚡ Performance Nodes</h3>
                    </div>
                    <div class="admin-card-body" style="padding: 20px;">
                        <div class="stats-grid" style="grid-template-columns: repeat(4, 1fr);">
                            <div class="stat-card" style="padding: 15px;">
                                <div class="stat-label">System Health</div>
                                <div class="stat-value" style="font-size: 20px; color: var(--nexus-success);"><%= String.format("%.1f", systemHealth) %>%</div>
                            </div>
                            <div class="stat-card" style="padding: 15px;">
                                <div class="stat-label">Avg Quality</div>
                                <div class="stat-value" style="font-size: 20px; color: var(--nexus-accent);"><%= String.format("%.1f", avgRating) %> ★</div>
                            </div>
                            <div class="stat-card" style="padding: 15px;">
                                <div class="stat-label">Task Efficiency</div>
                                <div class="stat-value" style="font-size: 20px; color: #8b5cf6;"><%= (int)taskEfficiency %>%</div>
                            </div>
                            <div class="stat-card" style="padding: 15px;">
                                <div class="stat-label">Network Growth</div>
                                <div class="stat-value" style="font-size: 20px; color: <%= networkGrowth >= 0 ? "var(--nexus-success)" : "var(--nexus-danger)" %>;"><%= networkGrowth >= 0 ? "+" : "" %><%= String.format("%.1f", networkGrowth) %>%</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Reports View -->
            <div id="reportsView" class="page-section">
                <div class="admin-card">
                    <div class="admin-card-header">
                        <h3>📎 Strategic Export Hub</h3>
                    </div>
                    <div class="admin-card-body">
                        <div class="reports-grid">
                            <div class="report-item">
                                <div class="report-icon"><i class="fas fa-clipboard-list" style="color: var(--nexus-accent);"></i></div>
                                <div class="report-info">
                                    <h4>Mission Registry</h4>
                                    <p>Full audit trail of all operational tasks, priorities, and status nodes.</p>
                                </div>
                                <button class="btn btn-primary" onclick="generateReport('tasks')">Export CSV</button>
                            </div>
                            <div class="report-item">
                                <div class="report-icon"><i class="fas fa-users" style="color: var(--nexus-success);"></i></div>
                                <div class="report-info">
                                    <h4>Talent Analytics</h4>
                                    <p>Comprehensive worker profiles, performance metrics, and engagement data.</p>
                                </div>
                                <button class="btn btn-primary" onclick="generateReport('workers')">Export CSV</button>
                            </div>
                            <div class="report-item">
                                <div class="report-icon"><i class="fas fa-wallet" style="color: #8b5cf6;"></i></div>
                                <div class="report-info">
                                    <h4>Financial Ledger</h4>
                                    <p>Consolidated wage summary and disbursement records for fiscal audit.</p>
                                </div>
                                <button class="btn btn-primary" onclick="generateReport('financial')">Export CSV</button>
                            </div>
                            <div class="report-item">
                                <div class="report-icon"><i class="fas fa-chart-line" style="color: var(--nexus-accent);"></i></div>
                                <div class="report-info">
                                    <h4>Trend Analysis</h4>
                                    <p>Historical velocity data and task completion trajectories.</p>
                                </div>
                                <button class="btn btn-primary" onclick="generateReport('trends')">Export CSV</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Settings View -->
            <div id="settingsView" class="page-section">
                <div class="admin-card" style="max-width: 1000px; margin: 0 auto;">
                    <div class="admin-card-header">
                        <h3>⚙️ Administrator Settings</h3>
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

                        <div class="form-group" style="margin-top: 25px;">
                            <label class="form-label">Operational Signature (Full Name)</label>
                            <input type="text" class="input-field" value="<%= currentUser.getFullName() %>" readonly>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Sovereign Email</label>
                            <input type="email" class="input-field" value="<%= currentUser.getEmail() %>" readonly>
                        </div>
                        <div style="margin-top: 30px; padding: 20px; background: var(--nexus-surface); border: 1px dashed var(--nexus-border); border-radius: var(--radius-md);">
                            <p style="font-size: 13px; color: var(--text-muted); text-align: center;">Account management restricted. Contact systems administrator for credential changes.</p>
                        </div>
                    </div>
                </div>

                <!-- Site CMS Management -->
                <div class="admin-card" style="max-width: 1000px; margin: 30px auto 0;">
                    <div class="admin-card-header">
                        <h3>🌐 Site CMS & Content Management</h3>
                    </div>
                    <div class="admin-card-body" style="padding: 25px;">
                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                            <!-- Home Page CMS -->
                            <div style="background: var(--nexus-surface); padding: 20px; border-radius: var(--radius-md); border: 1px solid var(--nexus-border);">
                                <h4 style="margin-bottom: 15px; display: flex; align-items: center; gap: 8px;"><i class="fas fa-home" style="color: var(--nexus-accent);"></i> Home Page</h4>
                                <div class="form-group">
                                    <label class="form-label">Hero Title</label>
                                    <input type="text" id="home_hero_title" class="input-field" value="<%= siteSettings.getOrDefault("home_hero_title", "") %>">
                                    <button onclick="updateSiteSetting('home_hero_title')" class="btn btn-primary" style="margin-top: 10px; width: 100%; padding: 8px;">Update Title</button>
                                </div>
                                <div class="form-group" style="margin-top: 15px;">
                                    <label class="form-label">Hero Subtitle</label>
                                    <textarea id="home_hero_subtitle" class="textarea-field" rows="3"><%= siteSettings.getOrDefault("home_hero_subtitle", "") %></textarea>
                                    <button onclick="updateSiteSetting('home_hero_subtitle')" class="btn btn-primary" style="margin-top: 10px; width: 100%; padding: 8px;">Update Subtitle</button>
                                </div>
                            </div>

                            <!-- About Page CMS -->
                            <div style="background: var(--nexus-surface); padding: 20px; border-radius: var(--radius-md); border: 1px solid var(--nexus-border);">
                                <h4 style="margin-bottom: 15px; display: flex; align-items: center; gap: 8px;"><i class="fas fa-info-circle" style="color: var(--nexus-accent);"></i> About & Vision</h4>
                                <div class="form-group">
                                    <label class="form-label">Vision Title</label>
                                    <input type="text" id="about_title" class="input-field" value="<%= siteSettings.getOrDefault("about_title", "") %>">
                                    <button onclick="updateSiteSetting('about_title')" class="btn btn-primary" style="margin-top: 10px; width: 100%; padding: 8px;">Update Vision Title</button>
                                </div>
                                <div class="form-group" style="margin-top: 15px;">
                                    <label class="form-label">Main Content</label>
                                    <textarea id="about_content" class="textarea-field" rows="3"><%= siteSettings.getOrDefault("about_content", "") %></textarea>
                                    <button onclick="updateSiteSetting('about_content')" class="btn btn-primary" style="margin-top: 10px; width: 100%; padding: 8px;">Update Content</button>
                                </div>
                            </div>

                            <!-- Contact Info CMS -->
                            <div style="background: var(--nexus-surface); padding: 20px; border-radius: var(--radius-md); border: 1px solid var(--nexus-border);">
                                <h4 style="margin-bottom: 15px; display: flex; align-items: center; gap: 8px;"><i class="fas fa-address-book" style="color: var(--nexus-accent);"></i> Contact & Support</h4>
                                <div class="form-group">
                                    <label class="form-label">Support Email</label>
                                    <input type="email" id="contact_email" class="input-field" value="<%= siteSettings.getOrDefault("contact_email", "") %>">
                                    <button onclick="updateSiteSetting('contact_email')" class="btn btn-primary" style="margin-top: 10px; width: 100%; padding: 8px;">Update Email</button>
                                </div>
                                <div class="form-group" style="margin-top: 15px;">
                                    <label class="form-label">Support Phone</label>
                                    <input type="text" id="contact_phone" class="input-field" value="<%= siteSettings.getOrDefault("contact_phone", "") %>">
                                    <button onclick="updateSiteSetting('contact_phone')" class="btn btn-primary" style="margin-top: 10px; width: 100%; padding: 8px;">Update Phone</button>
                                </div>
                                <div class="form-group" style="margin-top: 15px;">
                                    <label class="form-label">HQ Address</label>
                                    <input type="text" id="contact_address" class="input-field" value="<%= siteSettings.getOrDefault("contact_address", "") %>">
                                    <button onclick="updateSiteSetting('contact_address')" class="btn btn-primary" style="margin-top: 10px; width: 100%; padding: 8px;">Update Address</button>
                                </div>
                            </div>

                            <!-- System Controls -->
                            <div style="background: var(--nexus-surface); padding: 20px; border-radius: var(--radius-md); border: 1px solid var(--nexus-border);">
                                <h4 style="margin-bottom: 15px; display: flex; align-items: center; gap: 8px;"><i class="fas fa-shield-alt" style="color: var(--nexus-warning);"></i> System Configuration</h4>
                                <div class="form-group">
                                    <label class="form-label">Maintenance Mode</label>
                                    <select id="maintenance_mode" class="select-field">
                                        <option value="false" <%= "false".equals(siteSettings.get("maintenance_mode")) ? "selected" : "" %>>Operational (Live)</option>
                                        <option value="true" <%= "true".equals(siteSettings.get("maintenance_mode")) ? "selected" : "" %>>Maintenance (Locked)</option>
                                    </select>
                                    <button onclick="updateSiteSetting('maintenance_mode')" class="btn btn-secondary" style="margin-top: 10px; width: 100%; padding: 8px;">Apply Status</button>
                                </div>
                                <div class="form-group" style="margin-top: 15px;">
                                    <label class="form-label">System Announcement</label>
                                    <input type="text" id="system_announcement" class="input-field" placeholder="Broadcasting message..." value="<%= siteSettings.getOrDefault("system_announcement", "") %>">
                                    <button onclick="updateSiteSetting('system_announcement')" class="btn btn-secondary" style="margin-top: 10px; width: 100%; padding: 8px;">Broadcast Message</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Footer -->
            <footer style="margin-top: 40px; padding: 20px 20px; border-top: 1px solid var(--nexus-border);">
                <div class="footer-content" style="max-width: 100%; padding: 0;">
                    <div class="footer-brand">
                        <div class="copyright">NEXUS © 2026 Nexus Works. All rights reserved.</div>
                    </div>
                    <div class="footer-links" style="gap: 20px;">
                        <a href="${pageContext.request.contextPath}/">Home</a>
                        <a href="${pageContext.request.contextPath}/about">About</a>
                        <a href="${pageContext.request.contextPath}/contact">Contact</a>
                    </div>
                    <div class="footer-socials" style="display: flex; gap: 15px; font-size: 1rem;">
                        <a href="<%= siteSettings.getOrDefault("social_facebook", "#") %>" target="_blank" title="Facebook" style="color: var(--text-muted);"><i class="fab fa-facebook"></i></a>
                        <a href="<%= siteSettings.getOrDefault("social_instagram", "#") %>" target="_blank" title="Instagram" style="color: var(--text-muted);"><i class="fab fa-instagram"></i></a>
                        <a href="<%= siteSettings.getOrDefault("social_linkedin", "#") %>" target="_blank" title="LinkedIn" style="color: var(--text-muted);"><i class="fab fa-linkedin"></i></a>
                        <a href="<%= siteSettings.getOrDefault("social_whatsapp", "#") %>" target="_blank" title="WhatsApp" style="color: var(--text-muted);"><i class="fab fa-whatsapp"></i></a>
                    </div>
                </div>
            </footer>
        </main>
    </div>

    <!-- Worker Management Modal -->
    <div id="workerModal" class="modal-overlay">
        <div class="modal-container">
            <div class="modal-header">
                <h3 id="modalWorkerName">Worker Details</h3>
                <button class="modal-close" onclick="closeWorkerModal()">&times;</button>
            </div>
            <div class="modal-body">
                <div class="worker-details-grid" style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                    <div>
                        <label class="form-label">Email Address</label>
                        <p id="modalWorkerEmail" style="margin-bottom: 15px; font-weight: 500;"></p>
                        
                        <label class="form-label">Phone Number</label>
                        <p id="modalWorkerPhone" style="margin-bottom: 15px; font-weight: 500;"></p>
                        
                        <label class="form-label">Status</label>
                        <p style="margin-bottom: 15px;"><span id="modalWorkerStatus" class="status-badge"></span></p>
                    </div>
                    <div>
                        <label class="form-label">Total Earned</label>
                        <p id="modalWorkerEarned" style="margin-bottom: 15px; font-weight: 700; color: var(--nexus-success); font-family: 'JetBrains Mono';"></p>
                        
                        <label class="form-label">Tasks Completed</label>
                        <p id="modalWorkerTasks" style="margin-bottom: 15px; font-weight: 500;"></p>
                        
                        <label class="form-label">Performance Rating</label>
                        <p id="modalWorkerRating" style="margin-bottom: 15px; font-weight: 700; color: var(--nexus-accent);"></p>
                    </div>
                </div>
                <div style="margin-top: 10px;">
                    <label class="form-label">Core Skills</label>
                    <p id="modalWorkerSkills" style="padding: 10px; background: var(--nexus-surface); border: 1px solid var(--nexus-border); border-radius: var(--radius-md); font-size: 13px; color: var(--text-secondary); min-height: 60px;"></p>
                </div>
            </div>
            <div class="modal-footer">
                <input type="hidden" id="modalWorkerId">
                <button type="button" class="btn btn-secondary" onclick="closeWorkerModal()">Close</button>
                <button type="button" id="btnReject" class="btn btn-outline" style="color: var(--nexus-danger); border-color: var(--nexus-danger);" onclick="rejectWorker()">Reject/Block</button>
                <button type="button" class="btn btn-primary" style="background: var(--nexus-danger); border-color: var(--nexus-danger);" onclick="deleteWorker()">Delete Permanently</button>
            </div>
        </div>
    </div>

    <!-- Edit Task Modal -->
    <div id="editTaskModal" class="modal-overlay">
        <div class="modal-container" style="max-width: 700px;">
            <div class="modal-header">
                <h3>Edit Mission Parameters</h3>
                <button class="modal-close" onclick="closeEditTaskModal()">&times;</button>
            </div>
            <div class="modal-body">
                <form id="editTaskForm" onsubmit="submitTaskEdit(event)">
                    <input type="hidden" name="id" id="editTaskId">
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label">Mission Title *</label>
                            <input type="text" class="input-field" name="title" id="editTaskTitle" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Category *</label>
                            <select class="input-field" name="category" id="editTaskCategory" required>
                                <option value="Development">Development</option>
                                <option value="Design">Design</option>
                                <option value="Marketing">Marketing</option>
                                <option value="Data Entry">Data Entry</option>
                                <option value="QA">QA</option>
                                <option value="Administrative">Administrative</option>
                                <option value="Writing & Translation">Writing & Translation</option>
                                <option value="Customer Service">Customer Service</option>
                                <option value="Business & Finance">Business & Finance</option>
                                <option value="AI & Machine Learning">AI & Machine Learning</option>
                                <option value="Media & Production">Media & Production</option>
                                <option value="General">General</option>
                            </select>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Operational Context *</label>
                        <textarea class="textarea-field" name="description" id="editTaskDescription" rows="4" required></textarea>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label">Contract Value *</label>
                            <input type="number" step="0.01" class="input-field" name="wage" id="editTaskWage" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Estimated Hours</label>
                            <input type="number" class="input-field" name="estimatedHours" id="editTaskEstimatedHours" min="0">
                        </div>
                        <div class="form-group">
                            <label class="form-label">Wage Model</label>
                            <select class="select-field" name="wageType" id="editTaskWageType">
                                <option value="fixed">Fixed Rate</option>
                                <option value="hourly">Hourly Velocity</option>
                            </select>
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label">Operational Deadline *</label>
                            <input type="date" class="input-field" name="deadline" id="editTaskDeadline" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Mission Priority</label>
                            <select class="select-field" name="priority" id="editTaskPriority">
                                <option value="low">Standard</option>
                                <option value="medium">High</option>
                                <option value="high">Critical</option>
                                <option value="urgent">Sovereign Urgent</option>
                            </select>
                        </div>
                    </div>
                    <div style="display: flex; gap: var(--space-sm); justify-content: flex-end; margin-top: 20px;">
                        <button type="button" class="btn btn-secondary" onclick="closeEditTaskModal()">Cancel</button>
                        <button type="submit" class="btn btn-primary">Save Changes</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Task Description Modal -->
    <div id="taskDescriptionModal" class="modal-overlay">
        <div class="modal-container" style="max-width: 600px;">
            <div class="modal-header">
                <h3 id="descModalTitle">Mission Context</h3>
                <button class="modal-close" onclick="closeTaskDescriptionModal()">&times;</button>
            </div>
            <div class="modal-body">
                <div id="descModalWageTypeContainer" style="margin-bottom: 15px;">
                    <span class="status-badge" style="background: var(--nexus-accent-light); color: var(--nexus-accent); border: 1px solid rgba(59, 130, 246, 0.2); font-weight: 700;">
                        <i class="fas fa-wallet" style="margin-right: 5px;"></i> Payment Type: <span id="descModalWageType"></span>
                    </span>
                </div>
                <div style="padding: 20px; background: var(--nexus-surface); border: 1px solid var(--nexus-border); border-radius: var(--radius-md); line-height: 1.6; color: var(--text-secondary); white-space: pre-wrap;" id="descModalContent">
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-primary" onclick="closeTaskDescriptionModal()">Acknowledge</button>
            </div>
        </div>
    </div>

    <script>
        function viewTaskDescription(title, description, wageType) {
            document.getElementById('descModalTitle').textContent = title;
            document.getElementById('descModalContent').textContent = description;
            document.getElementById('descModalWageType').textContent = wageType || 'Fixed';
            document.getElementById('taskDescriptionModal').classList.add('active');
        }

        function closeTaskDescriptionModal() {
            document.getElementById('taskDescriptionModal').classList.remove('active');
        }

        function applyTaskFilter(filter) {
            const url = new URL(window.location.href);
            url.searchParams.set('taskFilter', filter);
            window.location.href = url.toString();
        }

        function applyAnalyticsFilter(filter) {
            const url = new URL(window.location.href);
            url.searchParams.set('pageAnalyticsFilter', filter);
            window.location.href = url.toString();
        }

        function openEditTaskModal(id, btn) {
            document.getElementById('editTaskId').value = id;
            document.getElementById('editTaskTitle').value = btn.getAttribute('data-title');
            document.getElementById('editTaskCategory').value = btn.getAttribute('data-category');
            document.getElementById('editTaskDescription').value = btn.getAttribute('data-description');
            document.getElementById('editTaskWage').value = btn.getAttribute('data-wage');
            document.getElementById('editTaskWageType').value = btn.getAttribute('data-wagetype');
            document.getElementById('editTaskDeadline').value = btn.getAttribute('data-deadline');
            document.getElementById('editTaskPriority').value = btn.getAttribute('data-priority');
            document.getElementById('editTaskEstimatedHours').value = btn.getAttribute('data-estimatedhours');
            
            document.getElementById('editTaskModal').classList.add('active');
        }

        function closeEditTaskModal() {
            document.getElementById('editTaskModal').classList.remove('active');
        }

        function submitTaskEdit(event) {
            event.preventDefault();
            const form = event.target;
            const formData = new URLSearchParams(new FormData(form));
            
            fetch('${pageContext.request.contextPath}/UpdateTaskServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: formData.toString()
            }).then(response => response.json())
              .then(result => {
                  if (result.success) {
                      showToast(result.message, 'success');
                      closeEditTaskModal();
                      setTimeout(() => location.reload(), 1000);
                  } else {
                      showToast(result.message, 'error');
                  }
              }).catch(err => showToast('Network error', 'error'));
        }

        function switchToPage(pageId) {
            localStorage.setItem('admin_active_tab', pageId);
            
            document.querySelectorAll('.page-section').forEach(section => {
                section.classList.remove('active');
            });
            
            const targetSection = document.getElementById(pageId + 'View');
            if (targetSection) {
                targetSection.classList.add('active');
                window.scrollTo({ top: 0, behavior: 'smooth' });
            }
            
            document.querySelectorAll('.nav-item').forEach(item => {
                item.classList.remove('active');
            });
            
            const activeItem = document.querySelector(`.nav-item[onclick*="\${pageId}"]`);
            if (activeItem) {
                activeItem.classList.add('active');
            }
            
            const titles = {
                'dashboard': 'Admin Dashboard',
                'tasks': 'Mission Repository',
                'createTask': 'Deploy New Mission',
                'workers': 'Talent Management',
                'submissions': 'Review Submissions',
                'wages': 'Disbursement Center',
                'paymentHistory': 'Payment History',
                'settings': 'Profile & System Settings'
            };
            
            const subtitles = {
                'dashboard': 'System overview and mission control.',
                'tasks': 'Direct oversight of all active and historical missions.',
                'createTask': 'Configure and deploy new operational objectives.',
                'workers': 'Manage the sovereign talent pool and performance nodes.',
                'submissions': 'Audit and validate completed mission objectives.',
                'wages': 'Financial throughput and payroll management.',
                'paymentHistory': 'Comprehensive ledger of all finalized operational disbursements.',
                'settings': 'Manage your administrative identity and system configuration.'
            };
            
            document.getElementById('pageTitle').textContent = titles[pageId] || 'Nexus Control';
            document.getElementById('pageSubtitle').textContent = subtitles[pageId] || 'Mission Command';
        }

        document.getElementById('sidebarToggle').addEventListener('click', function() {
            document.getElementById('sidebar').classList.toggle('open');
        });

        function deployMission(event) {
            event.preventDefault();
            const form = event.target;
            const formData = new URLSearchParams(new FormData(form));
            
            fetch('${pageContext.request.contextPath}/CreateTaskServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: formData.toString()
            }).then(response => response.json())
              .then(result => {
                  if (result.success) {
                      showToast(result.message, 'success');
                      setTimeout(() => location.reload(), 1000);
                  } else {
                      showToast(result.message, 'error');
                  }
              }).catch(err => showToast('Network error', 'error'));
        }

        function showToast(message, type = 'info') {
            let container = document.querySelector('.toast-container');
            if (!container) {
                container = document.createElement('div');
                container.className = 'toast-container';
                document.body.appendChild(container);
            }
            const toast = document.createElement('div');
            toast.className = `alert alert-${type}`;
            toast.innerHTML = `<span>\${type === 'success' ? '✓' : 'ℹ️'}</span><span>\${message}</span>`;
            container.appendChild(toast);
            setTimeout(() => { toast.style.opacity = '0'; setTimeout(() => toast.remove(), 300); }, 3000);
        }

        function approveWorker(id, btn) {
            if (!confirm('Approve this worker registration?')) return;
            fetch('${pageContext.request.contextPath}/ApproveWorkerServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'workerId=' + id + '&action=approve'
            }).then(response => response.json())
              .then(result => {
                  if (result.success) {
                      showToast('Worker approved successfully!', 'success');
                      const row = btn.closest('tr');
                      if (row) {
                          const statusBadge = row.querySelector('.status-badge');
                          if (statusBadge) {
                              statusBadge.className = 'status-badge approved';
                              statusBadge.textContent = 'APPROVED';
                          }
                          btn.remove();
                      }
                      if (btn.closest('#dashboardView')) row.remove();
                  } else {
                      showToast('Error: ' + result.message, 'error');
                  }
              }).catch(err => showToast('Network error', 'error'));
        }

        function approveSubmission(id, btn) {
            // Get rating from input if it exists
            const ratingInput = document.getElementById('rating_' + id);
            const rating = ratingInput ? ratingInput.value : 5;
            const comment = prompt('Feedback for worker (optional):', 'Approved via Admin Dashboard');
            if (comment === null) return; // Cancelled

            if (!confirm('Approve this task submission with ' + rating + ' star rating?')) return;
            fetch('${pageContext.request.contextPath}/ApproveSubmissionServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'submissionId=' + id + '&action=approve&rating=' + rating + '&comment=' + encodeURIComponent(comment)
            }).then(response => response.json())
              .then(result => {
                  if (result.success) {
                      showToast('Submission approved and payment recorded!', 'success');
                      const container = btn.closest('.submission-card') || btn.closest('tr');
                      if (container) container.remove();
                  } else {
                      showToast('Error: ' + result.message, 'error');
                  }
              }).catch(err => showToast('Network error', 'error'));
        }

        function setApprovalRating(id, rating) {
            const container = document.querySelector(`.rating-stars-input[data-submission-id="\${id}"]`);
            if (!container) return;
            
            const stars = container.querySelectorAll('.star-input');
            stars.forEach((s, index) => {
                if (index < rating) {
                    s.classList.add('active');
                } else {
                    s.classList.remove('active');
                }
            });
            
            const input = document.getElementById('rating_' + id);
            if (input) input.value = rating;
        }

        function rejectSubmission(id, btn) {
            const reason = prompt('Reason for rejection:');
            if (reason === null) return;
            fetch('${pageContext.request.contextPath}/ApproveSubmissionServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'submissionId=' + id + '&action=reject&reason=' + encodeURIComponent(reason)
            }).then(response => response.json())
              .then(result => {
                  if (result.success) {
                      showToast('Submission rejected.', 'warning');
                      const container = btn.closest('.submission-card') || btn.closest('tr');
                      if (container) container.remove();
                  }
              });
        }

        function markAsPaid(wageId, btn) {
            if (!confirm('Confirm wage disbursement for this task?')) return;
            fetch('${pageContext.request.contextPath}/MarkAsPaidServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'wageId=' + wageId
            }).then(response => response.json())
              .then(result => {
                  if (result.success) {
                      showToast('Payment marked as disbursed!', 'success');
                      const row = btn.closest('tr');
                      if (row) {
                          row.style.opacity = '0.5';
                          btn.disabled = true;
                          btn.textContent = 'Paid';
                          setTimeout(() => row.remove(), 1000);
                      }
                  } else {
                      showToast(result.message, 'error');
                  }
              });
        }

        function deleteTask(id, btn) {
            if (!confirm('Are you sure you want to delete this mission? This cannot be undone.')) return;
            fetch('${pageContext.request.contextPath}/DeleteTaskServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'taskId=' + id
            }).then(response => response.json())
              .then(result => {
                  if (result.success) {
                      showToast(result.message, 'success');
                      setTimeout(() => location.reload(), 1000);
                  } else {
                      showToast(result.message, 'error');
                  }
              });
        }

        function auditWage(workerId) {
            alert('Opening financial audit for worker ID: ' + workerId + '\nThis feature will display a detailed breakdown of all tasks and payouts in a modal.');
        }

        function manageWorker(id, status, btn) {
            document.getElementById('modalWorkerId').value = id;
            document.getElementById('modalWorkerName').textContent = btn.getAttribute('data-name');
            document.getElementById('modalWorkerEmail').textContent = btn.getAttribute('data-email');
            document.getElementById('modalWorkerPhone').textContent = btn.getAttribute('data-phone');
            document.getElementById('modalWorkerSkills').textContent = btn.getAttribute('data-skills');
            document.getElementById('modalWorkerRating').textContent = btn.getAttribute('data-rating') + ' ★';
            document.getElementById('modalWorkerEarned').textContent = btn.getAttribute('data-earned');
            document.getElementById('modalWorkerTasks').textContent = btn.getAttribute('data-tasks') + ' missions';
            
            const statusBadge = document.getElementById('modalWorkerStatus');
            statusBadge.textContent = status;
            statusBadge.className = 'status-badge ' + status.toLowerCase();
            
            const btnReject = document.getElementById('btnReject');
            if (status === 'blocked') {
                btnReject.textContent = 'Unblock Worker';
                btnReject.style.color = '#059669';
                btnReject.style.borderColor = 'rgba(16, 185, 129, 0.2)';
                btnReject.onclick = function() { updateWorkerStatus(id, 'approved'); };
            } else {
                btnReject.textContent = 'Block Worker';
                btnReject.style.color = '#dc2626';
                btnReject.style.borderColor = 'rgba(239, 68, 68, 0.2)';
                btnReject.onclick = function() { updateWorkerStatus(id, 'blocked'); };
            }
            
            document.getElementById('workerModal').classList.add('active');
        }

        function closeWorkerModal() {
            document.getElementById('workerModal').classList.remove('active');
        }

        function updateWorkerStatus(id, newStatus) {
            const actionText = newStatus === 'blocked' ? 'block' : 'unblock';
            if (!confirm(`Are you sure you want to ${actionText} this worker?`)) return;
            
            fetch('${pageContext.request.contextPath}/ManageWorkerServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'workerId=' + id + '&status=' + newStatus
            }).then(response => response.json())
              .then(result => {
                  if (result.success) {
                      showToast(result.message || 'Operation successful!', 'success');
                      setTimeout(() => location.reload(), 1000);
                  } else {
                      showToast(result.message, 'error');
                  }
              }).catch(err => showToast('Network error', 'error'));
        }

        function rateWorker(workerId, rating, starElem) {
            fetch('${pageContext.request.contextPath}/RateWorkerServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'workerId=' + workerId + '&rating=' + rating
            }).then(response => response.json())
              .then(result => {
                  if (result.success) {
                      showToast('Worker rated: ' + rating + ' stars', 'success');
                      const container = starElem.parentElement;
                      const stars = container.querySelectorAll('.star');
                      stars.forEach((s, index) => {
                          if (index < rating) {
                              s.classList.add('active');
                          } else {
                              s.classList.remove('active');
                          }
                      });
                  } else {
                      showToast(result.message, 'error');
                  }
              }).catch(err => showToast('Network error', 'error'));
        }

        function deleteWorker() {
            const id = document.getElementById('modalWorkerId').value;
            if (!confirm('PERMANENT DELETE: This will remove all history for this worker. Proceed?')) return;
            
            fetch('${pageContext.request.contextPath}/DeleteWorkerServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'workerId=' + id
            }).then(response => response.json())
              .then(result => {
                  if (result.success) {
                      showToast(result.message, 'success');
                      const row = document.querySelector(`button[onclick*="manageWorker(\${id},"]`)?.closest('tr');
                      if (row) row.remove();
                      closeWorkerModal();
                  } else {
                      showToast(result.message, 'error');
                  }
              }).catch(err => showToast('Network error', 'error'));
        }

        function generateReport(type) {
            showToast('Preparing ' + type + ' report...', 'info');
            window.location.href = '${pageContext.request.contextPath}/export-report?type=' + type;
        }

        function uploadProfilePic() {
            const fileInput = document.getElementById('profilePicInput');
            const file = fileInput.files[0];
            
            if (!file) {
                showToast('Please select a file to upload.', 'error');
                return;
            }
            
            if (file.size > 10 * 1024 * 1024) {
                showToast('File is too large. Maximum size is 10MB.', 'error');
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
                      showToast(result.message, 'success');
                      const avatarUrl = '${pageContext.request.contextPath}/images/' + result.profilePic;
                      const avatarHtml = `<img src="\${avatarUrl}" alt="Avatar" style="width: 100%; height: 100%; border-radius: var(--radius-lg); object-fit: cover;">`;
                      
                      document.getElementById('sidebarAvatar').innerHTML = avatarHtml;
                      document.getElementById('settingsAvatar').innerHTML = avatarHtml;
                      
                      fileInput.value = '';
                  } else {
                      showToast(result.message, 'error');
                  }
              }).catch(err => {
                  console.error('Error:', err);
                  showToast('An error occurred during upload.', 'error');
              });
        }

        function updateSiteSetting(key) {
            const value = document.getElementById(key).value;
            fetch('${pageContext.request.contextPath}/admin/update-settings', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'action=updateContent&configKey=' + key + '&configValue=' + encodeURIComponent(value)
            }).then(response => response.json())
              .then(result => {
                  if (result.success) {
                      showToast(result.message, 'success');
                  } else {
                      showToast(result.message, 'error');
                  }
              }).catch(err => showToast('Network error', 'error'));
        }

        function updateSocialSettings() {
            const keys = ['social_facebook', 'social_twitter', 'social_linkedin', 'social_github', 'site_logo_url'];
            keys.forEach(key => {
                updateSiteSetting(key);
            });
        }
        
        function initCharts() {
            <%
                List<Map<String, Object>> trends = (List<Map<String, Object>>) request.getAttribute("taskTrends");
                List<Map<String, Object>> cats = (List<Map<String, Object>>) request.getAttribute("tasksByCategory");
                
                StringBuilder trendLabels = new StringBuilder();
                StringBuilder completedData = new StringBuilder();
                StringBuilder openData = new StringBuilder();
                
                if (trends != null) {
                    for (Map<String, Object> t : trends) {
                        trendLabels.append("'").append(t.get("date")).append("',");
                        completedData.append(t.get("completed")).append(",");
                        openData.append(t.get("open")).append(",");
                    }
                }
                
                StringBuilder catLabels = new StringBuilder();
                StringBuilder catData = new StringBuilder();
                if (cats != null) {
                    for (Map<String, Object> c : cats) {
                        catLabels.append("'").append(c.get("category")).append("',");
                        catData.append(c.get("count")).append(",");
                    }
                }

                List<Map<String, Object>> priorities = (List<Map<String, Object>>) request.getAttribute("tasksByPriority");
                StringBuilder priorityLabels = new StringBuilder();
                StringBuilder priorityData = new StringBuilder();
                if (priorities != null) {
                    for (Map<String, Object> p : priorities) {
                        priorityLabels.append("'").append(p.get("priority")).append("',");
                        priorityData.append(p.get("count")).append(",");
                    }
                }
            %>

            const trendsCtx = document.getElementById('trendsChart').getContext('2d');
            new Chart(trendsCtx, {
                type: 'line',
                data: {
                    labels: [<%= trendLabels.toString() %>],
                    datasets: [{
                        label: 'Completed',
                        data: [<%= completedData.toString() %>],
                        borderColor: '#059669',
                        tension: 0.4,
                        fill: true,
                        backgroundColor: 'rgba(5, 150, 105, 0.1)'
                    }, {
                        label: 'Open',
                        data: [<%= openData.toString() %>],
                        borderColor: '#2563eb',
                        tension: 0.4
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { position: 'bottom' } }
                }
            });

            const catCtx = document.getElementById('categoryChart').getContext('2d');
            new Chart(catCtx, {
                type: 'doughnut',
                data: {
                    labels: [<%= catLabels.toString() %>],
                    datasets: [{
                        data: [<%= catData.toString() %>],
                        backgroundColor: ['#2563eb', '#059669', '#d97706', '#dc2626', '#7c3aed']
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { position: 'bottom' } }
                }
            });

            const priorityCtx = document.getElementById('priorityChart').getContext('2d');
            new Chart(priorityCtx, {
                type: 'pie',
                data: {
                    labels: [<%= priorityLabels.toString() %>],
                    datasets: [{
                        data: [<%= priorityData.toString() %>],
                        backgroundColor: ['#10b981', '#f59e0b', '#ef4444', '#6366f1']
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { position: 'bottom' } }
                }
            });
        }

        window.onload = function() {
            const activeTab = localStorage.getItem('admin_active_tab') || 'dashboard';
            switchToPage(activeTab);
            initCharts();
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