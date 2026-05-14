<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.nex.model.User, java.util.*" %>
<%
    // Check if user is logged in
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
    <title>Register | Nexus Works</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:opsz,wght@14..32,300;14..32,400;14..32,500;14..32,600;14..32,700;14..32,800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <script src="${pageContext.request.contextPath}/js/alert.js"></script>
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

    <div class="register-wrapper">
        <div class="register-container">
            <div class="brand-section">
                <div class="brand-icon">
                    <i class="fas fa-microchip"></i>
                </div>
                <h1>Create your account</h1>
                <p>Join Nexus Works as an Admin or Worker</p>
            </div>

            <div class="register-card">
                <div id="alertContainer"></div>

<form id="registerForm" method="post" action="${pageContext.request.contextPath}/register">
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label">Full Name *</label>
                            <div class="input-container">
                                <span class="input-icon"><i class="fas fa-user"></i></span>
                                <input type="text" class="input-field" id="fullName" name="fullName" placeholder="Ishan Maharjan" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Username *</label>
                            <div class="input-container">
                                <input type="text" class="input-field" id="username" name="username" placeholder="johndoe" required>
                            </div>
                            <small class="form-hint">Must be unique (letters, numbers, underscore)</small>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label">Email Address *</label>
                            <div class="input-container">
                                <input type="email" class="input-field" id="email" name="email" placeholder="john@example.com" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Phone Number</label>
                            <div class="input-container">
                                <input type="tel" class="input-field" id="phone" name="phone" placeholder="+1234567890">
                            </div>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label">Password *</label>
                            <div class="input-container">
                                <span class="input-icon"><i class="fas fa-lock"></i></span>
                                <input type="password" class="input-field" id="password" name="password" placeholder="At least 6 characters" required>
                                <button type="button" class="password-toggle" id="togglePassword"><i class="fas fa-eye"></i></button>
                            </div>
                            <small class="form-hint">Minimum 6 characters with at least one number</small>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Confirm Password *</label>
                            <div class="input-container">
                                <span class="input-icon"><i class="fas fa-check"></i></span>
                                <input type="password" class="input-field" id="confirmPassword" name="confirmPassword" placeholder="Retype password" required>
                                <button type="button" class="password-toggle" id="toggleConfirmPassword"><i class="fas fa-eye"></i></button>
                            </div>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">I want to join as *</label>
                        <div class="role-selector">
                            <label class="role-card">
                                <input type="radio" name="role" value="admin" required>
                                <div class="role-content">
                                    <span class="role-icon"><i class="fas fa-building-user"></i></span>
                                    <span class="role-title">Admin</span>
                                    <span class="role-desc">Post tasks, manage workers, track progress</span>
                                </div>
                            </label>
                            <label class="role-card">
                                <input type="radio" name="role" value="worker" required>
                                <div class="role-content">
                                    <span class="role-icon"><i class="fas fa-users-gear"></i></span>
                                    <span class="role-title">Worker</span>
                                    <span class="role-desc">Find tasks, submit work, earn wages</span>
                                </div>
                            </label>
                        </div>
                    </div>

                    <div class="terms-group">
                        <label class="checkbox-label">
                            <input type="checkbox" id="termsCheckbox" required>
                            <span>I agree to the <a href="#" class="terms-link">Terms of Service</a> and <a href="#" class="terms-link">Privacy Policy</a></span>
                        </label>
                    </div>

                    <button type="submit" class="register-btn" id="submitBtn">
                        <span>Create Account</span>
                        <span>→</span>
                    </button>
                </form>

                <div class="divider">
                    <div class="divider-line"></div>
                    <span class="divider-text">Already have an account?</span>
                    <div class="divider-line"></div>
                </div>

                <div class="login-section">
                <a href="${pageContext.request.contextPath}/login" class="login-link">Sign in to your account →</a>
                </div>
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
        // Check for server-side error messages
        window.onload = function() {
            <% if (request.getAttribute("error") != null) { %>
                showAlert('alertContainer', '<%= request.getAttribute("error") %>', 'error');
            <% } %>
        };

        // DOM Elements
        const togglePassword = document.getElementById('togglePassword');
        const toggleConfirmPassword = document.getElementById('toggleConfirmPassword');
        const passwordInput = document.getElementById('password');
        const confirmPasswordInput = document.getElementById('confirmPassword');
        const form = document.getElementById('registerForm');
        const submitBtn = document.getElementById('submitBtn');
        const alertContainer = document.getElementById('alertContainer');

        // Toggle password visibility
        if (togglePassword) {
            togglePassword.addEventListener('click', function() {
                const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
                passwordInput.setAttribute('type', type);
                this.textContent = type === 'password' ? '👁️' : '🙈';
            });
        }

        if (toggleConfirmPassword) {
            toggleConfirmPassword.addEventListener('click', function() {
                const type = confirmPasswordInput.getAttribute('type') === 'password' ? 'text' : 'password';
                confirmPasswordInput.setAttribute('type', type);
                this.textContent = type === 'password' ? '👁️' : '🙈';
            });
        }

        // Real-time validation functions
        function validatePassword() {
            const password = passwordInput.value;
            const hasMinLength = password.length >= 6;
            const hasNumber = /\d/.test(password);
            
            if (password && (!hasMinLength || !hasNumber)) {
                passwordInput.classList.add('invalid');
                passwordInput.classList.remove('valid');
                let errorMsg = hasMinLength ? 'Password must contain at least one number' : 'Password must be at least 6 characters';
                showAlert('alertContainer', errorMsg, 'error');
                return false;
            } else if (password) {
                passwordInput.classList.add('valid');
                passwordInput.classList.remove('invalid');
            }
            return true;
        }

        function validateConfirmPassword() {
            const password = passwordInput.value;
            const confirmPassword = confirmPasswordInput.value;
            if (confirmPassword && password !== confirmPassword) {
                confirmPasswordInput.classList.add('invalid');
                confirmPasswordInput.classList.remove('valid');
                showAlert('alertContainer', 'Passwords do not match', 'error');
                return false;
            } else if (confirmPassword) {
                confirmPasswordInput.classList.add('valid');
                confirmPasswordInput.classList.remove('invalid');
            }
            return true;
        }

        // Add event listeners
        if (passwordInput) passwordInput.addEventListener('input', validatePassword);
        if (confirmPasswordInput) confirmPasswordInput.addEventListener('input', validateConfirmPassword);

        // Form submission
        form.addEventListener('submit', function(e) {
            // Full validation here - preventDefault ONLY on client errors
            const fullName = document.getElementById('fullName').value.trim();
            const username = document.getElementById('username').value.trim();
            const email = document.getElementById('email').value.trim();
            const phone = document.getElementById('phone').value.trim();
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            const role = document.querySelector('input[name="role"]:checked');
            const termsCheckbox = document.getElementById('termsCheckbox').checked;

            // Validation checks
            if (!fullName) { showAlert('alertContainer', 'Full name is required', 'error'); e.preventDefault(); return; }
            if (!username || !/^[a-zA-Z0-9_]+$/.test(username)) { showAlert('alertContainer', 'Valid username required (letters, numbers, _)', 'error'); e.preventDefault(); return; }
            if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) { showAlert('alertContainer', 'Valid email required', 'error'); e.preventDefault(); return; }
            if (password.length < 6 || !/\d/.test(password)) { showAlert('alertContainer', 'Password: 6+ chars with number', 'error'); e.preventDefault(); return; }
            if (password !== confirmPassword) { showAlert('alertContainer', 'Passwords do not match', 'error'); e.preventDefault(); return; }
            if (!role) { showAlert('alertContainer', 'Select role (admin/worker)', 'error'); e.preventDefault(); return; }
            if (!termsCheckbox) { showAlert('alertContainer', 'Accept terms required', 'error'); e.preventDefault(); return; }

            // All good - show loading, submit to server /register servlet
            submitBtn.classList.add('loading');
            submitBtn.disabled = true;
            submitBtn.innerHTML = '<div class="spinner"></div> Creating Account...';
        });

        console.log('Register page loaded');
    </script>
</body>
</html>
