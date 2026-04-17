package com.nex.filters;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * AuthFilter intercepts all requests directed to protected resources like /home.
 * It checks if a session exists and if a user is logged in.
 */
@WebFilter("/home")
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        // Check if an existing session exists for this user
        HttpSession session = req.getSession(false);

        // Checking if session exists and if 'user' attribute is set
        if (session != null && session.getAttribute("user") != null) {
            // User is authenticated, allow access to the next filter/servlet
            chain.doFilter(request, response);
        } else {
            // User is not authenticated, redirect back to login page
            res.sendRedirect("login");
        }
    }

    @Override
    public void destroy() {}
}