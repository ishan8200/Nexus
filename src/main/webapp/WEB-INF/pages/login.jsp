<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.nex.model.User" %>
    <%
    // Get user from session
    User currentUser = (User) session.getAttribute("user");
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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <script src="${pageContext.request.contextPath}/js/alert.js"></script>
</head>
<body class="login-body">
    <!-- Navigation Bar - IDENTICAL to Home Page -->
    <nav class="navbar">
        <div class="nav-container">
            <a href="${pageContext.request.contextPath}/" class="logo">
                <span class="logo-mark">⌘</span>
                <span class="logo-text">NEXUS</span>
            </a>
            <div class="nav-links">
                <a href="${pageContext.request.contextPath}/" class="active">Home</a>
                <a href="#">Platform</a>
                <a href="#">Documentation</a>
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
                        <a href="#" class="forgot-link">Forgot password?</a>
                    </div>

                    <button type="submit" class="login-btn" id="submitBtn">
                        <span>Sign in</span>
                        <span>→</span>
                    </button>
                </form>
                <div class="divider">
                    <div class="divider-line"></div>
                    <span class="divider-text">Or continue with</span>
                    <div class="divider-line"></div>
                </div>
                <div class="signup-section">
                    <p>New Here?<a href="${pageContext.request.contextPath}/register" class="signup-link">Sign Up</a></p>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Check for server-side error or success messages
        window.onload = function() {
            <% if (request.getAttribute("error") != null) { %>
                showAlert('alertContainer', '<%= request.getAttribute("error") %>', 'error');
            <% } %>
            
            <% if (request.getParameter("success") != null) { %>
                showAlert('alertContainer', '<%= request.getParameter("success") %>', 'success');
            <% } %>
        };

        // Toggle password visibility
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

        console.log('Login form will now submit to server at /login servlet');

        console.log('Demo credentials: demo@nexus.io / demo123');
    </script>
</body>
</html>
