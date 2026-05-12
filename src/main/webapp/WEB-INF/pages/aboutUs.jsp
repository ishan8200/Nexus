<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.nex.model.User" %>
<%
    User currentUser = (User) session.getAttribute("user");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>About Us | Nexus Works</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:opsz,wght@14..32,300;14..32,400;14..32,500;14..32,600;14..32,700;14..32,800&family=JetBrains+Mono:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <style>
        .about-section {
            padding: 100px 0;
            background: linear-gradient(180deg, var(--nexus-bg) 0%, var(--nexus-surface) 100%);
        }
        .about-container {
            max-width: 1000px;
            margin: 0 auto;
            padding: 0 20px;
        }
        .about-header {
            text-align: center;
            margin-bottom: 60px;
        }
        .about-header h1 {
            font-size: 3.5rem;
            font-weight: 800;
            letter-spacing: -0.04em;
            margin-bottom: 20px;
            background: linear-gradient(135deg, var(--text-primary) 0%, var(--nexus-accent) 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        .about-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 60px;
            align-items: center;
        }
        .about-content p {
            font-size: 1.125rem;
            line-height: 1.7;
            color: var(--text-secondary);
            margin-bottom: 20px;
        }
        .about-stats {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }
        .stat-card {
            background: white;
            padding: 30px;
            border-radius: var(--radius-lg);
            border: 1px solid var(--nexus-border);
            text-align: center;
            transition: transform 0.3s ease;
        }
        .stat-card:hover {
            transform: translateY(-5px);
            border-color: var(--nexus-accent);
        }
        .stat-value {
            font-size: 2.5rem;
            font-weight: 800;
            color: var(--nexus-accent);
            font-family: 'JetBrains Mono', monospace;
            display: block;
            margin-bottom: 5px;
        }
        .stat-label {
            font-size: 0.875rem;
            font-weight: 600;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="nav-container">
            <a href="${pageContext.request.contextPath}/" class="logo">
                <img src="${pageContext.request.contextPath}/images/Nexuslogo_1.jpg" alt="Nexus Logo" style="height: 40px; width: auto;">
            </a>
            <div class="nav-links">
                <a href="${pageContext.request.contextPath}/">Home</a>
                <a href="${pageContext.request.contextPath}/about" class="active">About</a>
                <a href="${pageContext.request.contextPath}/contact">Contact</a>
                <% if (currentUser != null) { %>
                    <a href="${pageContext.request.contextPath}/<%= currentUser.getRole().equals("admin") ? "admin" : "worker" %>">Dashboard</a>
                    <a href="${pageContext.request.contextPath}/logout" class="btn-login-nav">Logout</a>
                <% } else { %>
                    <a href="${pageContext.request.contextPath}/login" class="btn-login-nav">Login</a>
                <% } %>
            </div>
        </div>
    </nav>

    <main class="about-section">
        <div class="about-container">
            <div class="about-header">
                <h1>Redefining Global Work.</h1>
                <p class="text-muted" style="font-size: 1.25rem;">Nexus is the high-velocity platform connecting elite talent with critical operational nodes.</p>
            </div>

            <div class="about-grid">
                <div class="about-content">
                    <h2 style="margin-bottom: 20px; font-weight: 700;">Our Mission</h2>
                    <p>At Nexus, we believe that the future of work is decentralized, meritocratic, and efficient. We've built a sovereignty-focused ecosystem that eliminates traditional friction in the workforce.</p>
                    <p>Our platform enables administrators to deploy complex tasks across a global network of verified experts, ensuring rapid delivery and uncompromising quality.</p>
                    <p>Whether you are a specialist looking for high-impact projects or an organization needing scalable talent, Nexus is your operational backbone.</p>
                </div>
                <div class="about-stats">
                    <div class="stat-card">
                        <span class="stat-value">5k+</span>
                        <span class="stat-label">Verified Experts</span>
                    </div>
                    <div class="stat-card">
                        <span class="stat-value">12k+</span>
                        <span class="stat-label">Tasks Completed</span>
                    </div>
                    <div class="stat-card">
                        <span class="stat-value">98%</span>
                        <span class="stat-label">Success Rate</span>
                    </div>
                    <div class="stat-card">
                        <span class="stat-value">24/7</span>
                        <span class="stat-label">Operational</span>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <footer style="padding: 60px 0; border-top: 1px solid var(--nexus-border); text-align: center; background: white;">
        <div class="nav-container">
            <p style="color: var(--text-muted); font-size: 0.875rem;">&copy; 2026 Nexus Works Operational Portal. All rights reserved.</p>
        </div>
    </footer>
</body>
</html>
