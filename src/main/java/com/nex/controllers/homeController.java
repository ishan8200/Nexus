package com.nex.controllers;

import java.io.IOException;

import com.nex.model.User;
import com.nex.dao.SettingsDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet({"/home", ""})
public class HomeController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private SettingsDAO settingsDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        settingsDAO = new SettingsDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Fetch site settings
        java.util.Map<String, String> siteSettings = settingsDAO.getAllSettings();
        request.setAttribute("siteSettings", siteSettings);

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("user") : null;

        request.getRequestDispatcher("/WEB-INF/pages/home.jsp").forward(request, response);
    }
}