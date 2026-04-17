package com.nex.controllers;

import java.io.IOException;

import com.nex.dao.UserDao;
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
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private final UserDao userDao = new UserDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getServletPath();
        
        // Routing based on servlet path
        if (path.equals("/login")) {
            request.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(request, response);
        } else if (path.equals("/register")) {
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
        } else if (path.equals("/logout")) {
            handleLogout(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getServletPath();
        
        if (path.equals("/login")) {
            handleLogin(request, response);
        } else if (path.equals("/register")) {
            handleRegister(request, response);
        }
    }

    /**
     * Logic for user login: validating credentials, setting session, and cookie.
     */
    private void handleLogin(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        User user = userDao.validateUser(username, password);

        if (user != null) {
            // Setting session attribute as requested
            HttpSession session = request.getSession();
            session.setAttribute("user", user);

            // Setting persistent cookie as requested (e.g., to remember username)
            Cookie userCookie = new Cookie("user_id", String.valueOf(user.getId()));
            userCookie.setMaxAge(60 * 60 * 24); // Persistent for 24 hours
            response.addCookie(userCookie);

            // Redirect to home after successful login
            response.sendRedirect("home");
        } else {
            // Forward back to login page with error message using request attribute
            request.setAttribute("error", "Invalid username or password.");
            request.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(request, response);
        }
    }

    /**
     * Logic for user registration: creating a new user and saving to DB.
     */
    private void handleRegister(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String email = request.getParameter("email");
        String role = "Contractor"; // Default role for new registrations

        User user = new User(username, password, email, role);
        boolean isRegistered = userDao.registerUser(user);

        if (isRegistered) {
            // Success: Redirect to login page
            response.sendRedirect("login?success=true");
        } else {
            // Failure: Stay on register page with error
            request.setAttribute("error", "Username already exists or database error.");
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
        }
    }

    /**
     * Logic for user logout: invalidating session and removing cookie.
     */
    private void handleLogout(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate(); // End the session
        }
        
        // Remove the persistent cookie by setting max age to zero
        Cookie cookie = new Cookie("user_id", "");
        cookie.setMaxAge(0);
        response.addCookie(cookie);

        // Redirect back to login
        response.sendRedirect("login");
    }
}
