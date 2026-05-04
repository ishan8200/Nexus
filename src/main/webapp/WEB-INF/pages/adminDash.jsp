<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, com.nex.model.User" %>
<%
    // Check if user is logged in and is admin
    User currentUser = (User) request.getAttribute("currentUser");
    if (currentUser == null || !"admin".equals(currentUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    // Dashboard data from controller
    int totalTasks = (int) request.getAttribute("totalTasks");
    int completedTasks = (int) request.getAttribute("completedTasks");
    int activeWorkers = (int) request.getAttribute("activeWorkers");
    double wagesDisbursed = (double) request.getAttribute("wagesDisbursed");
    int pendingSubmissions = (int) request.getAttribute("pendingSubmissions");
    
    List<Map<String, Object>> recentTasks = (List<Map<String, Object>>) request.getAttribute("recentTasks");
    List<Map<String, Object>> pendingWorkersList = (List<Map<String, Object>>) request.getAttribute("pendingWorkersList");
    List<Map<String, Object>> pendingSubmissionsList = (List<Map<String, Object>>) request.getAttribute("pendingSubmissionsList");
    List<Map<String, Object>> allWorkers = (List<Map<String, Object>>) request.getAttribute("allWorkers");
    List<Map<String, Object>> allTasks = (List<Map<String, Object>>) request.getAttribute("allTasks");
    List<Map<String, Object>> wageSummary = (List<Map<String, Object>>) request.getAttribute("wageSummary");
    
    // Formatter for currency
    java.text.NumberFormat cur = java.text.NumberFormat.getCurrencyInstance(Locale.US);
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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <script src="${pageContext.request.contextPath}/js/alert.js"></script>
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

    <!-- Admin Layout -->
    <div class="admin-layout">
        <!-- Sidebar -->
        <aside class="admin-sidebar" id="sidebar">
            <div class="sidebar-header">
                <h3>Navigation</h3>
                <div class="admin-profile">
                    <div class="admin-avatar"><%= currentUser.getFullName().substring(0, 1).toUpperCase() %></div>
                    <div class="admin-info">
                        <h4><%= currentUser.getFullName() %></h4>
                        <p>Administrator</p>
                    </div>
                </div>
            </div>
            
            <nav class="sidebar-nav">
                <div class="nav-section-title">MAIN</div>
                <a href="javascript:void(0)" class="nav-item active" onclick="switchToPage('dashboard')">
                    <span class="nav-icon">📊</span>
                    <span class="nav-text">Dashboard</span>
                </a>
                <a href="javascript:void(0)" class="nav-item" onclick="switchToPage('tasks')">
                    <span class="nav-icon">📋</span>
                    <span class="nav-text">All Tasks</span>
                    <span class="nav-badge"><%= totalTasks %></span>
                </a>
                <a href="javascript:void(0)" class="nav-item" onclick="switchToPage('createTask')">
                    <span class="nav-icon">➕</span>
                    <span class="nav-text">Create Task</span>
                </a>
                
                <div class="nav-section-title">MANAGEMENT</div>
                <a href="javascript:void(0)" class="nav-item" onclick="switchToPage('workers')">
                    <span class="nav-icon">👥</span>
                    <span class="nav-text">Workers</span>
                    <span class="nav-badge"><%= activeWorkers %></span>
                </a>
                <a href="javascript:void(0)" class="nav-item" onclick="switchToPage('submissions')">
                    <span class="nav-icon">📝</span>
                    <span class="nav-text">Submissions</span>
                    <span class="nav-badge"><%= pendingSubmissions %></span>
                </a>
                <a href="javascript:void(0)" class="nav-item" onclick="switchToPage('wages')">
                    <span class="nav-icon">💰</span>
                    <span class="nav-text">Wages</span>
                </a>
                
                <div class="nav-section-title">ACCOUNT</div>
                <a href="javascript:void(0)" class="nav-item" onclick="switchToPage('settings')">
                    <span class="nav-icon">⚙️</span>
                    <span class="nav-text">Settings</span>
                </a>
            </nav>
        </aside>

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
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-header">
                            <span class="stat-icon">📋</span>
                            <span class="stat-label">Total Tasks</span>
                        </div>
                        <div class="stat-value"><%= totalTasks %></div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-header">
                            <span class="stat-icon">👥</span>
                            <span class="stat-label">Workers</span>
                        </div>
                        <div class="stat-value"><%= activeWorkers %></div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-header">
                            <span class="stat-icon">✅</span>
                            <span class="stat-label">Completed</span>
                        </div>
                        <div class="stat-value"><%= completedTasks %></div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-header">
                            <span class="stat-icon">💰</span>
                            <span class="stat-label">Disbursed</span>
                        </div>
                        <div class="stat-value">$<%= String.format("%,.1f", wagesDisbursed / 1000) %>K</div>
                    </div>
                </div>

                <div class="dashboard-grid">
                    <div class="admin-card">
                        <div class="admin-card-header">
                            <h3>📌 Quick Actions</h3>
                        </div>
                        <div class="admin-card-body" style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px; padding: 20px;">
                            <div class="action-card" onclick="switchToPage('createTask')">
                                <span class="action-icon">➕</span>
                                <div class="action-info">
                                    <h4>New Task</h4>
                                    <p>Deploy mission</p>
                                </div>
                            </div>
                            <div class="action-card" onclick="switchToPage('submissions')">
                                <span class="action-icon">📝</span>
                                <div class="action-info">
                                    <h4>Review Work</h4>
                                    <p><%= pendingSubmissions %> pending</p>
                                </div>
                            </div>
                            <div class="action-card" onclick="switchToPage('workers')">
                                <span class="action-icon">👥</span>
                                <div class="action-info">
                                    <h4>Manage Talent</h4>
                                    <p><%= activeWorkers %> active</p>
                                </div>
                            </div>
                            <div class="action-card" onclick="switchToPage('wages')">
                                <span class="action-icon">💰</span>
                                <div class="action-info">
                                    <h4>Process Payouts</h4>
                                    <p>Financial audit</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="admin-card">
                        <div class="admin-card-header">
                            <h3>⏳ Pending Approvals</h3>
                            <button class="btn-icon" onclick="switchToPage('submissions')">View All →</button>
                        </div>
                        <div class="admin-card-body" style="padding: 0;">
                            <table class="admin-table">
                                <thead>
                                    <tr><th>Type</th><th>Name</th><th>Date</th><th>Action</th></tr>
                                </thead>
                                <tbody>
                                    <% for (Map<String, Object> submission : pendingSubmissionsList) { %>
                                    <tr>
                                        <td><span class="status-badge pending">Submission</span></td>
                                        <td><strong><%= submission.get("worker_name") %></strong></td>
                                        <td style="font-size: 11px;"><%= submission.get("submitted_at") %></td>
                                        <td>
                                            <button class="btn btn-primary" style="padding: 2px 6px; font-size: 10px;" onclick="approveSubmission(<%= submission.get("id") %>, this)">Approve</button>
                                        </td>
                                    </tr>
                                    <% } %>
                                    <% for (Map<String, Object> worker : pendingWorkersList) { %>
                                    <tr>
                                        <td><span class="status-badge pending">Registration</span></td>
                                        <td><strong><%= worker.get("full_name") %></strong></td>
                                        <td style="font-size: 11px;"><%= worker.get("created_at") %></td>
                                        <td>
                                            <button class="btn btn-primary" style="padding: 2px 6px; font-size: 10px;" onclick="approveWorker(<%= worker.get("id") %>, this)">Approve</button>
                                        </td>
                                    </tr>
                                    <% } %>
                                    <% if (pendingSubmissionsList.isEmpty() && pendingWorkersList.isEmpty()) { %>
                                    <tr><td colspan="4" style="text-align: center; padding: 30px; color: var(--text-muted);">Clear for now.</td></tr>
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
                    <div class="admin-card-header">
                        <h3>📋 Mission Repository</h3>
                    </div>
                    <div class="admin-card-body" style="padding: 0;">
                        <table class="admin-table">
                            <thead>
                                <tr><th>Task Title</th><th>Priority</th><th>Status</th><th>Wage</th><th>Deadline</th><th>Action</th></tr>
                            </thead>
                            <tbody>
                                <% if (allTasks != null) { %>
                                    <% for (Map<String, Object> task : allTasks) { %>
                                        <tr>
                                            <td><strong><%= task.get("title") %></strong></td>
                                            <td><span class="status-badge <%= ((String)task.get("priority")).toLowerCase() %>"><%= task.get("priority") %></span></td>
                                            <td><span class="status-badge <%= ((String)task.get("status")).toLowerCase().replace(" ", "-") %>"><%= task.get("status") %></span></td>
                                            <td style="font-family: 'JetBrains Mono'; font-weight: 700;"><%= cur.format(task.get("wage")) %></td>
                                            <td><%= task.get("deadline") %></td>
                                            <td>
                                                <button class="btn btn-secondary" style="padding: 4px 8px; font-size: 11px;" onclick="deleteTask(<%= task.get("id") %>, this)">Delete</button>
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
                        <form id="createTaskForm" action="${pageContext.request.contextPath}/CreateTaskServlet" method="POST">
                            <div class="form-group">
                                <label class="form-label">Mission Title *</label>
                                <input type="text" class="input-field" name="title" placeholder="e.g. Neural Engine UI Audit" required>
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
                                    <label class="form-label">Wage Model</label>
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
                        <h3>👥 Talent Management</h3>
                    </div>
                    <div class="admin-card-body" style="padding: 0;">
                        <table class="admin-table">
                            <thead>
                                <tr><th>Full Name</th><th>Tasks</th><th>Rating</th><th>Total Earned</th><th>Status</th><th>Action</th></tr>
                            </thead>
                            <tbody>
                                <% for (Map<String, Object> worker : allWorkers) { %>
                                <tr>
                                    <td><strong><%= worker.get("full_name") %></strong><br><small style="color: var(--text-muted);"><%= worker.get("email") %></small></td>
                                    <td><%= worker.get("tasks_completed") %></td>
                                    <td>
                                        <div class="rating-stars" data-worker-id="<%= worker.get("id") %>">
                                            <% 
                                                double currentRating = (double) worker.get("rating");
                                                for(int i = 1; i <= 5; i++) { 
                                            %>
                                                <span class="star <%= i <= currentRating ? "active" : "" %>" onclick="rateWorker(<%= worker.get("id") %>, <%= i %>, this)">★</span>
                                            <% } %>
                                        </div>
                                    </td>
                                    <td style="font-family: 'JetBrains Mono';"><%= cur.format(worker.get("total_earned")) %></td>
                                    <td><span class="status-badge <%= ((String)worker.get("status")).toLowerCase() %>"><%= worker.get("status") %></span></td>
                                    <td>
                                        <% if ("pending".equals(worker.get("status"))) { %>
                                            <button class="btn btn-primary" style="padding: 4px 8px; font-size: 11px;" onclick="approveWorker(<%= worker.get("id") %>, this)">Approve</button>
                                        <% } else { %>
                                            <button class="btn btn-outline" style="padding: 4px 8px; font-size: 11px;" 
                                                onclick="manageWorker(<%= worker.get("id") %>, '<%= worker.get("status") %>', this)"
                                                data-name="<%= worker.get("full_name") %>"
                                                data-email="<%= worker.get("email") %>"
                                                data-phone="<%= worker.get("phone") != null ? worker.get("phone") : "N/A" %>"
                                                data-skills="<%= worker.get("skills") != null ? worker.get("skills") : "No skills listed" %>"
                                                data-rating="<%= String.format("%.1f", worker.get("rating")) %>"
                                                data-earned="<%= cur.format(worker.get("total_earned")) %>"
                                                data-tasks="<%= worker.get("tasks_completed") %>">Manage</button>
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
                        <h3>📝 Pending Work Submissions</h3>
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
                                <strong>Notes:</strong> <%= submission.get("submission_text") %>
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
                        <h3>💰 Wage Disbursement Center</h3>
                    </div>
                    <div class="admin-card-body" style="padding: 0;">
                        <table class="admin-table">
                            <thead>
                                <tr><th>Worker</th><th>Completed Tasks</th><th>Net Earnings</th><th>Action</th></tr>
                            </thead>
                            <tbody>
                                <% for (Map<String, Object> wage : wageSummary) { %>
                                <tr>
                                    <td><strong><%= wage.get("full_name") %></strong></td>
                                    <td><%= wage.get("tasks_completed") %></td>
                                    <td style="font-family: 'JetBrains Mono'; font-weight: 700; color: var(--nexus-success);"><%= cur.format(wage.get("total_earned")) %></td>
                                    <td>
                                        <button class="btn btn-primary" style="padding: 4px 12px; font-size: 12px;" onclick="markAsPaid(<%= wage.get("worker_id") %>, this)">Pay Worker</button>
                                        <button class="btn btn-outline" style="padding: 4px 12px; font-size: 12px;">Audit</button>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Settings View -->
            <div id="settingsView" class="page-section">
                <div class="admin-card" style="max-width: 600px; margin: 0 auto;">
                    <div class="admin-card-header">
                        <h3>⚙️ Administrator Security</h3>
                    </div>
                    <div class="admin-card-body">
                        <div class="form-group">
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
            </div>
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
                'dashboard': 'Admin Dashboard',
                'tasks': 'Mission Repository',
                'createTask': 'Deploy New Mission',
                'workers': 'Talent Management',
                'submissions': 'Review Submissions',
                'wages': 'Disbursement Center',
                'settings': 'Security Protocols'
            };
            
            const subtitles = {
                'dashboard': 'System overview and mission control.',
                'tasks': 'Direct oversight of all active and historical missions.',
                'createTask': 'Configure and deploy new operational objectives.',
                'workers': 'Manage the sovereign talent pool and performance nodes.',
                'submissions': 'Audit and validate completed mission objectives.',
                'wages': 'Financial throughput and payroll management.',
                'settings': 'Configure administrative security and identity signature.'
            };
            
            document.getElementById('pageTitle').textContent = titles[pageId] || 'Nexus Control';
            document.getElementById('pageSubtitle').textContent = subtitles[pageId] || 'Mission Command';
        }

        // Handle mobile toggle
        document.getElementById('sidebarToggle').addEventListener('click', function() {
            document.getElementById('sidebar').classList.toggle('open');
        });

        // --- Functional Handlers (Restored) ---

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
                      setTimeout(() => location.reload(), 1000);
                  } else {
                      showToast('Error: ' + result.message, 'error');
                  }
              }).catch(err => showToast('Network error', 'error'));
        }

        function approveSubmission(id, btn) {
            if (!confirm('Approve this task submission?')) return;
            fetch('${pageContext.request.contextPath}/ApproveSubmissionServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'submissionId=' + id + '&action=approve'
            }).then(response => response.json())
              .then(result => {
                  if (result.success) {
                      showToast('Submission approved and payment recorded!', 'success');
                      setTimeout(() => location.reload(), 1000);
                  } else {
                      showToast('Error: ' + result.message, 'error');
                  }
              }).catch(err => showToast('Network error', 'error'));
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
                      setTimeout(() => location.reload(), 1000);
                  }
              });
        }

        function markAsPaid(workerId, btn) {
            if (!confirm('Confirm wage disbursement for this worker?')) return;
            fetch('${pageContext.request.contextPath}/MarkAsPaidServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'workerId=' + workerId
            }).then(response => response.json())
              .then(result => {
                  if (result.success) {
                      showToast('Payment marked as disbursed!', 'success');
                      setTimeout(() => location.reload(), 1000);
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
                      showToast('Mission deleted successfully', 'success');
                      btn.closest('tr').remove();
                  } else {
                      showToast(result.message, 'error');
                  }
              });
        }

        function auditWage(workerId) {
            alert('Opening financial audit for worker ID: ' + workerId + '\nThis feature will display a detailed breakdown of all tasks and payouts in a modal.');
            // Implementation for a real audit modal can go here
        }

        // --- Worker Management Modal Functions ---

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
                btnReject.style.color = '#059669'; // success color
                btnReject.style.borderColor = 'rgba(16, 185, 129, 0.2)';
                btnReject.onclick = function() { updateWorkerStatus(id, 'approved'); };
            } else {
                btnReject.textContent = 'Block Worker';
                btnReject.style.color = '#dc2626'; // danger color
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
            if (!confirm(`Are you sure you want to \${actionText} this worker?`)) return;
            
            fetch('${pageContext.request.contextPath}/ManageWorkerServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'workerId=' + id + '&status=' + newStatus
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

        function rateWorker(workerId, rating, starElem) {
            fetch('${pageContext.request.contextPath}/RateWorkerServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'workerId=' + workerId + '&rating=' + rating
            }).then(response => response.json())
              .then(result => {
                  if (result.success) {
                      showToast('Worker rated: ' + rating + ' stars', 'success');
                      // Update stars UI
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
                      setTimeout(() => location.reload(), 1000);
                  } else {
                      showToast(result.message, 'error');
                  }
              }).catch(err => showToast('Network error', 'error'));
        }

        // Handle URL parameters for alerts
        window.onload = function() {
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
