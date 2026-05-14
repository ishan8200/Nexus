<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.nex.model.User, java.util.*" %>
<%
    User currentUser = (User) session.getAttribute("user");
    Map<String, String> siteSettings = (Map<String, String>) request.getAttribute("siteSettings");
    if (siteSettings == null) siteSettings = new HashMap<>();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Contact Us | Nexus Works</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:opsz,wght@14..32,300;14..32,400;14..32,500;14..32,600;14..32,700;14..32,800&family=JetBrains+Mono:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <script src="${pageContext.request.contextPath}/js/alert.js"></script>
    <style>
        .contact-section {
            padding: 100px 0;
            background: linear-gradient(180deg, var(--nexus-bg) 0%, var(--nexus-surface) 100%);
            min-height: calc(100vh - 80px);
        }
        .contact-container {
            max-width: 1100px;
            margin: 0 auto;
            padding: 0 20px;
            display: grid;
            grid-template-columns: 1fr 1.5fr;
            gap: 80px;
        }
        .contact-info h1 {
            font-size: 3rem;
            font-weight: 800;
            letter-spacing: -0.04em;
            margin-bottom: 20px;
            color: var(--text-primary);
        }
        .contact-info p {
            font-size: 1.125rem;
            color: var(--text-secondary);
            margin-bottom: 40px;
            line-height: 1.6;
        }
        .contact-methods {
            display: flex;
            flex-direction: column;
            gap: 30px;
        }
        .method-item {
            display: flex;
            gap: 20px;
            align-items: center;
        }
        .method-icon {
            width: 50px;
            height: 50px;
            background: white;
            border: 1px solid var(--nexus-border);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
        }
        .method-text h4 {
            font-weight: 700;
            margin-bottom: 2px;
            color: var(--text-primary);
        }
        .method-text p {
            margin-bottom: 0;
            font-size: 0.9375rem;
            color: var(--text-muted);
        }
        .contact-card {
            background: white;
            padding: 40px;
            border-radius: var(--radius-xl);
            border: 1px solid var(--nexus-border);
            box-shadow: 0 20px 40px rgba(0,0,0,0.03);
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="nav-container">
            <a href="${pageContext.request.contextPath}/" class="logo">
                <img src="${pageContext.request.contextPath}<%= siteSettings.getOrDefault("site_logo_url", "/images/Nexuslogo_1.jpg") %>" alt="Nexus Logo" style="height: 40px; width: auto;">
            </a>
            <div class="nav-links">
                <a href="${pageContext.request.contextPath}/">Home</a>
                <a href="${pageContext.request.contextPath}/about">About</a>
                <a href="${pageContext.request.contextPath}/contact" class="active">Contact</a>
                <% if (currentUser != null) { %>
                    <a href="${pageContext.request.contextPath}/<%= currentUser.getRole().equals("admin") ? "admin" : "worker" %>">Dashboard</a>
                    <a href="${pageContext.request.contextPath}/logout" class="btn-login-nav">Logout</a>
                <% } else { %>
                    <a href="${pageContext.request.contextPath}/login" class="btn-login-nav">Login</a>
                <% } %>
            </div>
        </div>
    </nav>

    <main class="contact-section">
        <div id="alertContainer" style="max-width: 1100px; margin: 0 auto 20px; padding: 0 20px;"></div>
        
        <div class="contact-container">
            <div class="contact-info">
                <h1>Let's scale together.</h1>
                <p>Have questions about the Nexus ecosystem or need technical support? Our operational team is standing by.</p>
                
                <div class="contact-methods">
                    <div class="method-item">
                        <div class="method-icon"><i class="fas fa-envelope" style="color: var(--nexus-accent);"></i></div>
                        <div class="method-text">
                            <h4>Email Transmission</h4>
                            <p><%= siteSettings.getOrDefault("contact_email", "ops@nexusworks.io") %></p>
                        </div>
                    </div>
                    <div class="method-item">
                        <div class="method-icon"><i class="fas fa-phone-volume" style="color: var(--nexus-success);"></i></div>
                        <div class="method-text">
                            <h4>Direct Uplink</h4>
                            <p><%= siteSettings.getOrDefault("contact_phone", "+1 (555) 010-9988") %></p>
                        </div>
                    </div>
                    <div class="method-item">
                        <div class="method-icon"><i class="fas fa-location-dot" style="color: var(--nexus-danger);"></i></div>
                        <div class="method-text">
                            <h4>Operations Base</h4>
                            <p><%= siteSettings.getOrDefault("contact_address", "Global Decentralized Network") %></p>
                        </div>
                    </div>
                </div>
            </div>

            <div class="contact-card">
                <h3 style="margin-bottom: 30px; font-weight: 700;">Transmit Message</h3>
                <form id="contactForm" onsubmit="handleContact(event)">
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label">Name</label>
                            <input type="text" class="input-field" required placeholder="Your full name">
                        </div>
                        <div class="form-group">
                            <label class="form-label">Email</label>
                            <input type="email" class="input-field" required placeholder="your@email.com">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Subject</label>
                        <select class="input-field">
                            <option>Technical Support</option>
                            <option>Partnership Inquiry</option>
                            <option>Account Verification</option>
                            <option>Other</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Message</label>
                        <textarea class="textarea-field" required placeholder="Describe your inquiry..." style="height: 150px;"></textarea>
                    </div>
                    <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 20px;">Transmit Secure Message</button>
                </form>
            </div>
        </div>
    </main>

    <!-- Footer -->
    <footer>
        <div class="footer-content">
            <div class="footer-brand">
                <div class="copyright">NEXUS © 2026 Nexus Works. All rights reserved.</div>
            </div>
            <div class="footer-links">
                <a href="${pageContext.request.contextPath}/home">Home</a>
                <a href="${pageContext.request.contextPath}/about">About</a>
                <a href="${pageContext.request.contextPath}/contact">Contact</a>
            </div>
            <div class="footer-socials" style="display: flex; gap: 20px; font-size: 1.25rem; margin-top: 10px;">
                <a href="<%= siteSettings.getOrDefault("social_facebook", "#") %>" target="_blank" title="Facebook" style="color: #7a7a7a; transition: all 0.3s ease;"><i class="fab fa-facebook"></i></a>
                <a href="<%= siteSettings.getOrDefault("social_instagram", "#") %>" target="_blank" title="Instagram" style="color: #7a7a7a; transition: all 0.3s ease;"><i class="fab fa-instagram"></i></a>
                <a href="<%= siteSettings.getOrDefault("social_linkedin", "#") %>" target="_blank" title="LinkedIn" style="color: #7a7a7a; transition: all 0.3s ease;"><i class="fab fa-linkedin"></i></a>
                <a href="<%= siteSettings.getOrDefault("social_whatsapp", "#") %>" target="_blank" title="WhatsApp" style="color: #7a7a7a; transition: all 0.3s ease;"><i class="fab fa-whatsapp"></i></a>
            </div>
        </div>
    </footer>

    <style>
        /* Consistent Footer Styles */
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
        
        .footer-socials a:hover {
            color: #3b82f6 !important;
            transform: translateY(-3px);
        }
    </style>

    <script>
        function handleContact(e) {
            e.preventDefault();
            showAlert('alertContainer', 'Message transmitted successfully. Our team will contact you shortly.', 'success');
            e.target.reset();
        }
    </script>
</body>
</html>
