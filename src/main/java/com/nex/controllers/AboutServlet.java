package com.nex.controllers;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.nex.dao.SettingsDAO;

@WebServlet("/about")
public class AboutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private SettingsDAO settingsDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        settingsDAO = new SettingsDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setAttribute("siteSettings", settingsDAO.getAllSettings());
        request.getRequestDispatcher("/WEB-INF/pages/aboutUs.jsp").forward(request, response);
    }
}
