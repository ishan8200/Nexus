<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.nex.model.User, java.util.*" %>
    <%
    // Get user from session
    User currentUser = (User) session.getAttribute("user");
    
    // CMS Settings
    Map<String, String> siteSettings = (Map<String, String>) request.getAttribute("siteSettings");
    if (siteSettings == null) siteSettings = new HashMap<>();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nexus | Authentication Portal</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:opsz,wght@14..32,300;14..32,400;14..32,500;14..32,600;14..32,700;14..32,800&family=JetBrains+Mono:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <script src="${pageContext.request.contextPath}/js/alert.js"></script>
</head>
<body class="login-body">
    <!-- Navigation Bar - IDENTICAL to Home Page -->
    <nav class="navbar">
        <div class="nav-container">
            <a href="${pageContext.request.contextPath}/" class="logo">
                <img src="${pageContext.request.contextPath}<%= siteSettings.getOrDefault("site_logo_url", "/images/Nexuslogo_1.jpg") %>" alt="Nexus Logo" style="height: 40px; width: auto;">
            </a>
            <div class="nav-links">
                <a href="${pageContext.request.contextPath}/">Home</a>
                <a href="${pageContext.request.contextPath}/about">About</a>
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

    <!-- Login Wrapper -->
    <div class="login-wrapper">
        <div class="login-container">
            <!-- Brand Section -->
            <div class="brand-section">
                <div class="brand-icon">
                </div>
                <h1>Welcome back</h1>
                <p>Sign in to access your operational dashboard</p>
            </div>

            <!-- Login Card -->
            <div class="login-card">
                <div id="alertContainer"></div>

                <form id="loginForm" method="post" action="${pageContext.request.contextPath}/login">
                    <div class="form-group">
                        <label class="form-label">Email</label>
                        <div class="input-container">
                            <input type="email" class="input-field" id="email" name="email" placeholder="ishan123@nexus.com" required>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Password</label>
                        <div class="input-container">
                            <input type="password" class="input-field" id="password" name="password" placeholder="Enter your password" required>
                            <button type="button" class="password-toggle" id="togglePassword">Show</button>
                        </div>
                    </div>

                    <div class="form-options">
                        <label class="checkbox">
                            <input type="checkbox" name="rememberMe" checked>
                            <span>Remember me</span>
                        </label>
                        <a href="javascript:void(0)" class="forgot-link" onclick="openForgotModal()">Forgot password?</a>
                    </div>

                    <button type="submit" class="login-btn" id="submitBtn">
                        <span>Sign in</span>
                        <span>→</span>
                    </button>
                </form>
                <div class="divider">
                    <div class="divider-line"></div>
                    
                    <div class="divider-line"></div>
                </div>
                <div class="signup-section">
                    <p>New Here?<a href="${pageContext.request.contextPath}/register" class="signup-link">Sign Up</a></p>
                </div>
            </div>
        </div>
    </div>

    <!-- Forgot Password Modal -->
    <div id="forgotModal" class="modal-overlay">
        <div class="modal-container" style="max-width: 450px;">
            <div class="modal-header">
                <h3><i class="fas fa-key" style="margin-right: 10px; color: var(--nexus-accent);"></i>Reset Password</h3>
                <button class="modal-close" onclick="closeForgotModal()">&times;</button>
            </div>
            <div class="modal-body">
                <p style="margin-bottom: 20px; font-size: 14px; color: var(--text-muted);">
                    Enter your registered email and a new password to reset your account.
                </p>
                <form id="forgotForm" method="post" action="${pageContext.request.contextPath}/forgot-password">
                    <div class="form-group">
                        <label class="form-label">Email Address</label>
                        <input type="email" class="input-field" name="email" id="forgotEmail" placeholder="your@email.com" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">New Password</label>
                        <div class="input-container">
                            <input type="password" class="input-field" name="newPassword" id="newPassword" placeholder="Min 6 characters" required>
                            <button type="button" class="password-toggle" onclick="togglePass('newPassword')">Show</button>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Confirm New Password</label>
                        <div class="input-container">
                            <input type="password" class="input-field" name="confirmPassword" id="confirmPassword" placeholder="Confirm your password" required>
                            <button type="button" class="password-toggle" onclick="togglePass('confirmPassword')">Show</button>
                        </div>
                    </div>
                    <div style="margin-top: 25px; display: flex; gap: 10px; justify-content: flex-end;">
                        <button type="button" class="btn btn-secondary" onclick="closeForgotModal()">Cancel</button>
                        <button type="submit" class="btn btn-primary" style="background: var(--nexus-accent); border-color: var(--nexus-accent);">Update Password</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

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

    <script>
        // Check for server-side error or success messages
        window.onload = function() {
            const urlParams = new URLSearchParams(window.location.search);
            
            <% if (request.getAttribute("error") != null) { %>
                showAlert('alertContainer', '<%= request.getAttribute("error") %>', 'error');
            <% } else if (request.getParameter("error") != null) { %>
                showAlert('alertContainer', urlParams.get('error'), 'error');
            <% } %>
            
            <% if (request.getParameter("success") != null) { %>
                showAlert('alertContainer', urlParams.get('success'), 'success');
            <% } %>
        };

        function openForgotModal() {
            document.getElementById('forgotModal').classList.add('active');
        }

        function closeForgotModal() {
            document.getElementById('forgotModal').classList.remove('active');
        }

        function togglePass(id) {
            const input = document.getElementById(id);
            const type = input.getAttribute('type') === 'password' ? 'text' : 'password';
            input.setAttribute('type', type);
            event.target.textContent = type === 'password' ? 'Show' : 'Hide';
        }

        // Toggle password visibility for login
        const togglePassword = document.getElementById('togglePassword');
        const passwordInput = document.getElementById('password');

        if (togglePassword) {
            togglePassword.addEventListener('click', function() {
                const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
                passwordInput.setAttribute('type', type);
                this.textContent = type === 'password' ? 'Show' : 'Hide';
            });
        }

        // Form submission
        const form = document.getElementById('loginForm');
        const submitBtn = document.getElementById('submitBtn');

            form.addEventListener('submit', function(e) {
            const email = document.getElementById('email').value.trim();
            const password = document.getElementById('password').value;
            
            if (!email) {
                showAlert('alertContainer', 'Please enter your email address', 'error');
                document.getElementById('email').focus();
                e.preventDefault();
                return;
            }
            
            if (!password) {
                showAlert('alertContainer', 'Please enter your password', 'error');
                document.getElementById('password').focus();
                e.preventDefault();
                return;
            }
            
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(email)) {
                showAlert('alertContainer', 'Please enter a valid email address', 'error');
                e.preventDefault();
                return;
            }
            
            // Client validation passed - allow form submit to server
            submitBtn.classList.add('loading');
            submitBtn.disabled = true;
            submitBtn.innerHTML = '<div class="spinner"></div><span>Authenticating...</span>';
        });

        document.getElementById('forgotForm').addEventListener('submit', function(e) {
            const pass = document.getElementById('newPassword').value;
            const confirm = document.getElementById('confirmPassword').value;
            
            if (pass.length < 6) {
                alert('Password must be at least 6 characters');
                e.preventDefault();
                return;
            }
            
            if (pass !== confirm) {
                alert('Passwords do not match');
                e.preventDefault();
                return;
            }
        });

        console.log('Login form will now submit to server at /login servlet');

        console.log('Demo credentials: demo@nexus.io / demo123');
    </script>
</body>
</html>
