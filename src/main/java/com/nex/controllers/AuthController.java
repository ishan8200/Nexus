package com.nex.controllers;

import java.io.IOException;

import com.nex.dao.UserDAO;
import com.nex.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

/**
 * AuthController handles all authentication-related requests: Login, Registration, and Logout.
 * This satisfies the "Two Controllers" requirement.
 */
@WebServlet({"/login", "/register", "/logout"})
public class AuthController extends HttpServlet {
    
    private static final long serialVersionUID = 1L;
    private UserDAO userDao;

    @Override
    public void init() throws ServletException {
        super.init();
        userDao = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String path = request.getServletPath();
        
        // Routing based on servlet path
        if (path.equals("/login")) {
            // Check if user is already logged in
            HttpSession session = request.getSession(false);
            if (session != null && session.getAttribute("user") != null) {
                User user = (User) session.getAttribute("user");
                if ("admin".equals(user.getRole())) {
                    response.sendRedirect(request.getContextPath() + "/admin");
                } else {
                    response.sendRedirect(request.getContextPath() + "/worker");
                }
                return;
            }
            request.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(request, response);
            
        } else if (path.equals("/register")) {
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
            
        } else if (path.equals("/logout")) {
            handleLogout(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String path = request.getServletPath();
        
        if (path.equals("/login")) {
            handleLogin(request, response);
        } else if (path.equals("/register")) {
            handleRegister(request, response);
        }
    }

    /**
     * Logic for user login: validating credentials, setting session, and cookie.
     * Now uses EMAIL for login instead of username.
     */
    private void handleLogin(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Changed from "username" to "email"
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String rememberMe = request.getParameter("rememberMe");
        
        // Validation
        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Please enter email address");
            request.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(request, response);
            return;
        }
        
        // Email format validation
        if (!email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
            request.setAttribute("error", "Please enter a valid email address");
            request.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(request, response);
            return;
        }
        
        if (password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Please enter password");
            request.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(request, response);
            return;
        }
        
        // Validate user from database using EMAIL
        User user = userDao.loginUser(email, password);
        
        if (user != null) {
            // Check if worker is approved
            if ("worker".equals(user.getRole()) && !"approved".equals(user.getStatus())) {
                request.setAttribute("error", "Your account is pending admin approval. Please wait.");
                request.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(request, response);
                return;
            }
            
            // Check if user is blocked
            if ("blocked".equals(user.getStatus())) {
                request.setAttribute("error", "Your account has been blocked. Please contact support.");
                request.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(request, response);
                return;
            }
            
            // Create session
            HttpSession session = request.getSession();
            session.setAttribute("user", user);
            session.setMaxInactiveInterval(30 * 60); // 30 minutes timeout
            
            // Set persistent cookie for "Remember Me" feature
            if (rememberMe != null && rememberMe.equals("on")) {
                Cookie userCookie = new Cookie("user_email", user.getEmail()); // Changed from user_id to user_email
                userCookie.setMaxAge(60 * 60 * 24 * 7); // 7 days persistent
                userCookie.setPath(request.getContextPath());
                userCookie.setHttpOnly(true);
                response.addCookie(userCookie);
            }
            
            // Redirect based on role
            if ("admin".equals(user.getRole())) {
                response.sendRedirect(request.getContextPath() + "/admin");
            } else {
                response.sendRedirect(request.getContextPath() + "/worker");
            }
        } else {
            request.setAttribute("error", "Invalid email or password");
            request.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(request, response);
        }
    }

    /**
     * Logic for user registration: creating a new user and saving to DB.
     */
    private void handleRegister(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String role = request.getParameter("role");
        
        // Validation
        if (username == null || username.trim().isEmpty()) {
            request.setAttribute("error", "Username is required");
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
            return;
        }
        
        // Username format validation
        if (!username.matches("^[a-zA-Z0-9_]+$")) {
            request.setAttribute("error", "Username can only contain letters, numbers, and underscore");
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
            return;
        }
        
        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Email is required");
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
            return;
        }
        
        // Email format validation
        if (!email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
            request.setAttribute("error", "Please enter a valid email address");
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
            return;
        }
        
        if (password == null || password.length() < 6) {
            request.setAttribute("error", "Password must be at least 6 characters");
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
            return;
        }
        
        // Check if password contains at least one number
        if (!password.matches(".*\\d.*")) {
            request.setAttribute("error", "Password must contain at least one number");
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
            return;
        }
        
        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match");
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
            return;
        }
        
        if (fullName == null || fullName.trim().isEmpty()) {
            request.setAttribute("error", "Full name is required");
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
            return;
        }
        
        // Default role if not selected
        if (role == null || role.isEmpty()) {
            role = "worker";
        }
        
        // Check if username exists
        if (userDao.isUsernameExists(username)) {
            request.setAttribute("error", "Username already taken. Please choose another one.");
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
            return;
        }
        
        // Check if email exists
        if (userDao.isEmailExists(email)) {
            request.setAttribute("error", "Email already registered. Please use another email or login.");
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
            return;
        }
        
        // Create new user
        User newUser = new User();
        newUser.setUsername(username);
        newUser.setEmail(email);
        newUser.setPassword(password); // In production, hash this password
        newUser.setFullName(fullName);
        newUser.setPhone(phone);
        newUser.setRole(role);
        newUser.setStatus("pending"); // Workers need admin approval
        
        // Admins are auto-approved
        if ("admin".equals(role)) {
            newUser.setStatus("approved");
        }
        
        boolean isRegistered = userDao.registerUser(newUser);
        
        if (isRegistered) {
            // Success: Redirect to login page with success message
            String successMsg = "Registration successful! " + 
                ("admin".equals(role) ? "You can now log in." : "Please wait for admin approval before logging in.");
            response.sendRedirect(request.getContextPath() + "/login?success=" + java.net.URLEncoder.encode(successMsg, "UTF-8"));
        } else {
            request.setAttribute("error", "Registration failed. Please try again.");
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
        }
    }

    /**
     * Logic for user logout: invalidating session and removing cookie.
     */
    private void handleLogout(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        // Invalidate session
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        
        // Remove the persistent cookie by setting max age to zero
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if ("user_email".equals(cookie.getName())) {
                    cookie.setMaxAge(0);
                    cookie.setPath(request.getContextPath());
                    response.addCookie(cookie);
                    break;
                }
            }
        }
        
        // Redirect to login page
        response.sendRedirect(request.getContextPath() + "/login");
    }
}