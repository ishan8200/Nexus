package com.nex.filters;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;
import java.io.IOException;
import com.nex.dao.SettingsDAO;
import com.nex.model.User;

/**
 * AuthFilter intercepts all requests directed to protected resources like /home.
 * It checks if a session exists and if a user is logged in.
 */
@WebFilter({"/home", "/admin", "/worker", "/about", "/contact"})
public class AuthFilter implements Filter {

    private SettingsDAO settingsDao;

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        settingsDao = new SettingsDAO();
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        // 1. Check Maintenance Mode
        String maintenanceMode = settingsDao.getSetting("maintenance_mode", "false");

        // Check if an existing session exists for this user
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if ("true".equalsIgnoreCase(maintenanceMode)) {
            // If maintenance mode is ON, only admins can pass
            if (user == null || !"admin".equals(user.getRole())) {
                // If it's a worker or guest, redirect to a maintenance info page or login with error
                req.setAttribute("error", "SYSTEM DOWN FOR SCHEDULED MAINTENANCE. ACCESS RESTRICTED TO ROOT ADMINISTRATORS.");
                req.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(req, res);
                return;
            }
        }

        // 2. Standard Auth Check
        // Checking if session exists and if 'user' attribute is set
        if (user != null) {
            // User is authenticated, allow access to the next filter/servlet
            chain.doFilter(request, response);
        } else {
            // Public pages are allowed if not in maintenance mode (handled above)
            String path = req.getServletPath();
            if (path.equals("/about") || path.equals("/contact") || path.equals("/home") || path.equals("") || path.equals("/")) {
                chain.doFilter(request, response);
                return;
            }
            // User is not authenticated, redirect back to login page
            res.sendRedirect(req.getContextPath() + "/login");
        }
    }

    @Override
    public void destroy() {}
}