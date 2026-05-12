<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.nex.model.User" %>
<%
    // Check if user is logged in
    HttpSession sessionObj = request.getSession(false);
    User currentUser = (sessionObj != null) ? (User) sessionObj.getAttribute("user") : null;
%>
	
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nexus Works | Next-Gen Operational Platform</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:opsz,wght@14..32,300;14..32,400;14..32,500;14..32,600;14..32,700;14..32,800&family=JetBrains+Mono:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <style>
        /* Home page additional styles */
        .hero {
            min-height: 90vh;
            display: flex;
            align-items: center;
            padding: 80px 0;
            position: relative;
        }
        
        .hero-content {
            max-width: 800px;
        }
        
        .hero-badge {
            display: inline-block;
            background: rgba(59, 130, 246, 0.1);
            border: 1px solid rgba(59, 130, 246, 0.2);
            border-radius: 6px;
            padding: 4px 12px;
            font-size: 0.75rem;
            font-weight: 500;
            color: #3b82f6;
            margin-bottom: 24px;
            letter-spacing: 0.02em;
        }
        
        .hero h1 {
            font-size: clamp(2.5rem, 5vw, 4rem);
            line-height: 1.2;
            background: linear-gradient(135deg, #1a1a1a 0%, #4a4a4a 100%);
            background-clip: text;
            -webkit-background-clip: text;
            color: transparent;
            margin-bottom: 24px;
        }
        
        .hero p {
            font-size: 1.25rem;
            color: #4a4a4a;
            margin-bottom: 32px;
            line-height: 1.6;
        }
        
        .section {
            padding: 80px 0;
            border-bottom: 1px solid #e2e2dc;
        }
        
        .section:last-child {
            border-bottom: none;
        }
        
        .section h2 {
            font-size: clamp(1.75rem, 4vw, 2.5rem);
            color: #1a1a1a;
            margin-bottom: 16px;
            position: relative;
            display: inline-block;
        }
        
        .section h2::after {
            content: '';
            position: absolute;
            bottom: -8px;
            left: 0;
            width: 60px;
            height: 3px;
            background: linear-gradient(90deg, #3b82f6, transparent);
            border-radius: 6px;
        }
        
        .grid-2 {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
            gap: 32px;
            margin: 48px 0;
        }
        
        .card {
            background: #fafaf8;
            border: 1px solid #e2e2dc;
            border-radius: 16px;
            padding: 32px;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }
        
        .card:hover {
            border-color: #cbd5e1;
            transform: translateY(-4px);
            box-shadow: 0 20px 35px -15px rgba(0, 0, 0, 0.1);
        }
        
        .card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 2px;
            background: linear-gradient(90deg, transparent, #3b82f6, transparent);
            transform: scaleX(0);
            transition: transform 0.3s ease;
        }
        
        .card:hover::before {
            transform: scaleX(1);
        }
        
        .card-icon {
            font-size: 2rem;
            margin-bottom: 16px;
        }
        
        .card h3 {
            font-size: 1.5rem;
            margin-bottom: 16px;
            color: #1a1a1a;
        }
        
        .card p {
            color: #4a4a4a;
            margin-bottom: 16px;
            line-height: 1.6;
        }
        
        .feature-list {
            list-style: none;
            margin-top: 16px;
        }
        
        .feature-list li {
            color: #4a4a4a;
            padding: 8px 0;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .feature-list li::before {
            content: '▹';
            color: #3b82f6;
            font-weight: 600;
        }
        
        .btn-group {
            display: flex;
            gap: 16px;
            flex-wrap: wrap;
        }
        
        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            padding: 12px 28px;
            font-weight: 600;
            font-size: 0.9375rem;
            border-radius: 8px;
            text-decoration: none;
            transition: all 0.15s ease;
            cursor: pointer;
            border: 1px solid transparent;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #3b82f6, #2563eb);
            color: white;
            border-color: #60a5fa;
            box-shadow: 0 0 5px rgba(59, 130, 246, 0.3);
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 0 15px rgba(59, 130, 246, 0.4);
        }
        
        .btn-secondary {
            background: transparent;
            border-color: #e2e2dc;
            color: #1a1a1a;
        }
        
        .btn-secondary:hover {
            border-color: #3b82f6;
            background: rgba(59, 130, 246, 0.05);
        }
        
        .btn-outline {
            background: transparent;
            border-color: #3b82f6;
            color: #3b82f6;
        }
        
        .btn-outline:hover {
            background: rgba(59, 130, 246, 0.1);
        }
        
        .architectural-section {
            background: linear-gradient(180deg, transparent 0%, rgba(59, 130, 246, 0.03) 100%);
        }
        
        .architectural-content {
            text-align: center;
            max-width: 800px;
            margin: 0 auto;
        }
        
        .architectural-text {
            font-size: 1.125rem;
            color: #4a4a4a;
            margin: 32px 0;
            line-height: 1.7;
        }
        
        .media-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 32px;
            margin: 48px 0;
        }
        
        .media-card {
            background: #fafaf8;
            border: 1px solid #e2e2dc;
            border-radius: 16px;
            overflow: hidden;
            transition: all 0.3s ease;
        }
        
        .media-card:hover {
            transform: translateY(-4px);
            border-color: #cbd5e1;
        }
        
        .media-placeholder {
            background: linear-gradient(135deg, #ffffff 0%, #fafaf8 100%);
            aspect-ratio: 16 / 9;
            display: flex;
            align-items: center;
            justify-content: center;
            border-bottom: 1px solid #e2e2dc;
        }
        
        .video-badge::before {
            content: '▶';
            color: #3b82f6;
            margin-right: 8px;
        }
        
        .map-badge::before {
            content: '📍';
            margin-right: 8px;
        }
        
        .chart-badge::before {
            content: '📊';
            margin-right: 8px;
        }
        
        .video-badge, .map-badge, .chart-badge {
            display: flex;
            align-items: center;
            font-weight: 500;
            color: #4a4a4a;
        }
        
        .media-caption {
            padding: 16px;
            color: #4a4a4a;
            font-size: 0.875rem;
            text-align: center;
        }
        
        .tutorial-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
            gap: 32px;
            margin-top: 32px;
        }
        
        .tutorial-item {
            background: #ffffff;
            border-radius: 12px;
            padding: 24px;
            border-left: 3px solid #3b82f6;
            transition: all 0.15s ease;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
        }
        
        .tutorial-item:hover {
            background: #fafaf8;
            transform: translateX(5px);
        }
        
        .tutorial-item h4 {
            margin-bottom: 8px;
            font-size: 1.125rem;
            color: #1a1a1a;
        }
        
        .tutorial-item p {
            color: #7a7a7a;
            font-size: 0.875rem;
        }
        
        .nodes-container {
            background: #fafaf8;
            border-radius: 16px;
            border: 1px solid #e2e2dc;
            padding: 32px;
            margin-top: 16px;
        }
        
        .node-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 16px 0;
            border-bottom: 1px solid #e2e2dc;
            flex-wrap: wrap;
            gap: 8px;
        }
        
        .node-row:last-child {
            border-bottom: none;
        }
        
        .node-location {
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 8px;
            color: #1a1a1a;
        }
        
        .node-location::before {
            content: '●';
            color: #3b82f6;
            font-size: 0.75rem;
        }
        
        .latency {
            font-family: 'JetBrains Mono', monospace;
            font-size: 0.875rem;
            color: #4a4a4a;
            background: #ffffff;
            padding: 4px 12px;
            border-radius: 8px;
        }
        
        .latency-indicator {
            display: inline-block;
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: #10b981;
            margin-right: 8px;
            animation: pulse 2s infinite;
        }
        
        @keyframes pulse {
            0%, 100% { opacity: 1; transform: scale(1); }
            50% { opacity: 0.5; transform: scale(1.2); }
        }
        
        .metrics-panel {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 24px;
            margin-top: 16px;
        }
        
        .metric-card {
            background: #ffffff;
            border-radius: 12px;
            padding: 24px;
            border: 1px solid #e2e2dc;
            transition: all 0.15s ease;
        }
        
        .metric-card:hover {
            border-color: #cbd5e1;
            transform: translateY(-2px);
        }
        
        .metric-label {
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            color: #7a7a7a;
            margin-bottom: 8px;
        }
        
        .metric-value {
            font-size: 2rem;
            font-weight: 700;
            font-family: 'JetBrains Mono', monospace;
            background: linear-gradient(135deg, #1a1a1a, #4a4a4a);
            background-clip: text;
            -webkit-background-clip: text;
            color: transparent;
        }
        
        .metric-trend {
            font-size: 0.75rem;
            color: #10b981;
            margin-top: 8px;
            display: flex;
            align-items: center;
            gap: 4px;
        }
        
        footer {
            background: #fafaf8;
            border-top: 1px solid #e2e2dc;
            padding: 48px 0;
            margin-top: 80px;
        }
        
        .footer-content {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 24px;
            color: #7a7a7a;
            font-size: 0.875rem;
            max-width: 1400px;
            margin: 0 auto;
            padding: 0 32px;
        }
        
        .footer-links {
            display: flex;
            gap: 32px;
        }
        
        .footer-links a {
            color: #7a7a7a;
            text-decoration: none;
            transition: color 0.15s ease;
        }
        
        .footer-links a:hover {
            color: #3b82f6;
        }
        
        @media (max-width: 768px) {
            .section {
                padding: 48px 0;
            }
            .hero {
                text-align: center;
            }
            .hero-content {
                margin: 0 auto;
            }
            .btn-group {
                justify-content: center;
            }
            .section h2::after {
                left: 50%;
                transform: translateX(-50%);
            }
            .section h2 {
                text-align: center;
                display: block;
            }
            .grid-2 {
                grid-template-columns: 1fr;
            }
            .media-grid {
                grid-template-columns: 1fr;
            }
            .footer-content {
                flex-direction: column;
                text-align: center;
            }
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 0 32px;
        }
        
        .section-subtitle {
            color: #4a4a4a;
            margin-bottom: 32px;
            max-width: 600px;
        }
        
        /* Welcome banner for logged in users */
        .welcome-banner {
            background: linear-gradient(135deg, #3b82f6, #2563eb);
            border-radius: 16px;
            padding: 24px 32px;
            margin-bottom: 48px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 20px;
            color: white;
        }
        
        .welcome-banner h2 {
            color: white;
            margin-bottom: 8px;
        }
        
        .welcome-banner h2::after {
            background: rgba(255,255,255,0.3);
        }
        
        .welcome-banner p {
            opacity: 0.9;
        }
        
        .dashboard-link {
            background: rgba(255,255,255,0.2);
            color: white;
            padding: 10px 24px;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
        }
        
        .dashboard-link:hover {
            background: rgba(255,255,255,0.3);
            transform: translateY(-2px);
        }
    </style>
</head>
<body>
    <!-- Navigation Bar -->
    <nav class="navbar">
        <div class="nav-container">
            <a href="${pageContext.request.contextPath}/" class="logo">
                <img src="${pageContext.request.contextPath}/images/Nexuslogo_1.jpg" alt="Nexus Logo" style="height: 40px; width: auto;">
            </a>
            <div class="nav-links">
                <a href="${pageContext.request.contextPath}/" class="active">Home</a>
                <a href="${pageContext.request.contextPath}/about">About</a>
                <a href="${pageContext.request.contextPath}/contact">Contact</a>
                <% if (currentUser != null) { %>
                    <% if ("admin".equals(currentUser.getRole())) { %>
                        <a href="${pageContext.request.contextPath}/admin" class="btn-login-nav">Dashboard</a>
                    <% } else { %>
                        <a href="${pageContext.request.contextPath}/worker" class="btn-login-nav">Dashboard</a>
                    <% } %>
                    <a href="${pageContext.request.contextPath}/logout" class="btn-login-nav">Logout</a>
                <% } else { %>
                    <a href="${pageContext.request.contextPath}/login" class="btn-login-nav">Login</a>
                <% } %>
            </div>
        </div>
    </nav>

    <!-- Hero Section -->
    <section class="hero">
        <div class="container hero-content">
            <span class="hero-badge">v3.0 — STRUCTURAL RELEASE</span>
            <h1>NEXT-GEN OPERATIONAL NEXUS FOR MODERN TEAMS</h1>
            <p>A raw, structural platform designed for high-velocity project management. No fluff, just pure architectural logic for builders.</p>
            <div class="btn-group">
                <% if (currentUser == null) { %>
                    <a href="${pageContext.request.contextPath}/register" class="btn btn-primary">GET STARTED →</a>
                <% } else if ("admin".equals(currentUser.getRole())) { %>
                    <a href="${pageContext.request.contextPath}/admin" class="btn btn-primary">GO TO DASHBOARD →</a>
                <% } else { %>
                    <a href="${pageContext.request.contextPath}/worker" class="btn btn-primary">GO TO DASHBOARD →</a>
                <% } %>
            </div>
        </div>
    </section>

    <!-- Welcome Banner for Logged In Users -->
    <% if (currentUser != null) { %>
    <div class="container">
        <div class="welcome-banner">
            <div>
                <h2>Welcome back, <%= currentUser.getFullName() %>!</h2>
                <p>You're logged in as <%= "admin".equals(currentUser.getRole()) ? "Administrator" : "Worker" %>. Ready to get things done?</p>
            </div>
            <% if ("admin".equals(currentUser.getRole())) { %>
                <a href="${pageContext.request.contextPath}/admin" class="dashboard-link">Go to Admin Dashboard →</a>
            <% } else { %>
                <a href="${pageContext.request.contextPath}/worker" class="dashboard-link">Go to Worker Dashboard →</a>
            <% } %>
        </div>
    </div>
    <% } %>

    <!-- Core Capabilities Section -->
    <section class="section" id="features">
        <div class="container">
            <h2>CORE CAPABILITIES</h2>
            <div class="grid-2">
                <!-- Admin Control Card -->
                <div class="card">
                    <div class="card-icon"><i class="fas fa-user-shield" style="color: var(--nexus-accent);"></i></div>
                    <h3>ADMIN CONTROL</h3>
                    <p>Full-spectrum governance with granular permission layers and real-time oversight of every project node.</p>
                    <ul class="feature-list">
                        <li>Node Architecture</li>
                        <li>Security Protocols</li>
                        <li>Worker Management</li>
                        <li>Analytics Dashboard</li>
                    </ul>
                </div>
                
                <!-- Worker Velocity Card -->
                <div class="card">
                    <div class="card-icon"><i class="fas fa-bolt-lightning" style="color: var(--nexus-warning);"></i></div>
                    <h3>WORKER VELOCITY</h3>
                    <p>Streamlined execution workflows that eliminate friction. Focused views for high-impact task delivery.</p>
                    <ul class="feature-list">
                        <li>Active Task Queues</li>
                        <li>Resource Linking</li>
                        <li>Earnings Tracking</li>
                        <li>Performance Metrics</li>
                    </ul>
                </div>
            </div>
        </div>
    </section>

    <!-- Architectural Integrity Section -->
    <section class="section architectural-section">
        <div class="container">
            <div class="architectural-content">
                <h2>ARCHITECTURAL INTEGRITY</h2>
                <p class="architectural-text">Our platform isn't just about managing tasks; it's about building systems. Leverage our structural components to create a workspace that mirrors your organization's logic perfectly.</p>
                <a href="#tutorials" class="btn btn-outline">EXPLORE SCHEMA →</a>
            </div>
        </div>
    </section>

    <!-- Media Elements Grid -->
    <section class="section">
        <div class="container">
            <div class="media-grid">
                <div class="media-card">
                    <div class="media-placeholder">
                        <div class="video-badge"><i class="fas fa-circle-play" style="margin-right: 8px;"></i> VIDEO PREVIEW</div>
                    </div>
                    <div class="media-caption">Walkthrough: Nexus Core Architecture</div>
                </div>
                <div class="media-card">
                    <div class="media-placeholder">
                        <div class="map-badge"><i class="fas fa-earth-americas" style="margin-right: 8px;"></i> GLOBAL NODE MAP</div>
                    </div>
                    <div class="media-caption">Real-time Geographic Distribution</div>
                </div>
                <div class="media-card">
                    <div class="media-placeholder">
                        <div class="chart-badge"><i class="fas fa-chart-area" style="margin-right: 8px;"></i> METRIC FLOW</div>
                    </div>
                    <div class="media-caption">Project Velocity Analytics</div>
                </div>
            </div>
        </div>
    </section>

    <!-- Tutorial Hub -->
    <section class="section" id="tutorials">
        <div class="container">
            <h2>TUTORIAL HUB</h2>
            <p class="section-subtitle">Learn the mechanics of the Nexus ecosystem through raw technical walkthroughs.</p>
            <div class="tutorial-grid">
                <div class="tutorial-item">
                    <h4>01. Node Initialization</h4>
                    <p>Configure your first operational node with CLI tools.</p>
                </div>
                <div class="tutorial-item">
                    <h4>02. Permission Layers</h4>
                    <p>Implement granular access control structures.</p>
                </div>
                <div class="tutorial-item">
                    <h4>03. Task Queues</h4>
                    <p>Optimize worker velocity with advanced routing.</p>
                </div>
                <div class="tutorial-item">
                    <h4>04. Real-time Metrics</h4>
                    <p>Connect telemetry streams to your dashboard.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Global Nodes + Metric Flow Combined Section -->
    <section class="section">
        <div class="container">
            <div class="grid-2">
                <!-- Global Nodes -->
                <div>
                    <h2>GLOBAL NODES</h2>
                    <p class="section-subtitle">Track your team across geographic coordinates with real-time latency indicators.</p>
                    <div class="nodes-container">
                        <div class="node-row">
                            <span class="node-location">North America (NA-01)</span>
                            <span class="latency"><span class="latency-indicator"></span>24ms</span>
                        </div>
                        <div class="node-row">
                            <span class="node-location">Europe (EU-02)</span>
                            <span class="latency"><span class="latency-indicator"></span>47ms</span>
                        </div>
                        <div class="node-row">
                            <span class="node-location">Asia-Pacific (AP-03)</span>
                            <span class="latency"><span class="latency-indicator"></span>89ms</span>
                        </div>
                        <div class="node-row">
                            <span class="node-location">South America (SA-04)</span>
                            <span class="latency"><span class="latency-indicator"></span>112ms</span>
                        </div>
                    </div>
                </div>

                <!-- Metric Flow -->
                <div>
                    <h2>METRIC FLOW</h2>
                    <p class="section-subtitle">Direct observation of project velocity and resource allocation efficiency.</p>
                    <div class="metrics-panel">
                        <div class="metric-card">
                            <div class="metric-label">Project Velocity</div>
                            <div class="metric-value">284</div>
                            <div class="metric-trend">↑ +12.4%</div>
                        </div>
                        <div class="metric-card">
                            <div class="metric-label">Resource Efficiency</div>
                            <div class="metric-value">94.2%</div>
                            <div class="metric-trend">↑ +3.1%</div>
                        </div>
                        <div class="metric-card">
                            <div class="metric-label">Active Nodes</div>
                            <div class="metric-value">47</div>
                            <div class="metric-trend">Online</div>
                        </div>
                        <div class="metric-card">
                            <div class="metric-label">Throughput</div>
                            <div class="metric-value">1.2M</div>
                            <div class="metric-trend">ops/sec</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Footer -->
    <footer>
        <div class="footer-content">
            <div class="copyright">NEXUS © 2025 Nexus Works. All rights reserved.</div>
            <div class="footer-links">
                <a href="#">Privacy</a>
                <a href="#">Security</a>
                <a href="#">Status</a>
                <a href="#">API Docs</a>
                <a href="#">Support</a>
            </div>
        </div>
    </footer>

    <script>
        // Smooth scroll for anchor links
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({ behavior: 'smooth', block: 'start' });
                }
            });
        });
        
        // Add animation on scroll
        const observerOptions = {
            threshold: 0.1,
            rootMargin: '0px 0px -50px 0px'
        };
        
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.style.opacity = '1';
                    entry.target.style.transform = 'translateY(0)';
                }
            });
        }, observerOptions);
        
        document.querySelectorAll('.card, .media-card, .tutorial-item').forEach(el => {
            el.style.opacity = '0';
            el.style.transform = 'translateY(20px)';
            el.style.transition = 'all 0.5s ease';
            observer.observe(el);
        });
    </script>
</body>
</html>