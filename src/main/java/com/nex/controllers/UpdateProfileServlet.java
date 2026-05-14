package com.nex.controllers;

import java.io.IOException;
import java.io.PrintWriter;

import com.nex.dao.UserDAO;
import com.nex.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.File;
import java.util.UUID;

@WebServlet("/update-profile")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1, // 1 MB
    maxFileSize = 1024 * 1024 * 10,      // 10 MB
    maxRequestSize = 1024 * 1024 * 15    // 15 MB
)
public class UpdateProfileServlet extends HttpServlet {
    
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO;
    
    @Override
    public void init() throws ServletException {
        super.init();
        userDAO = new UserDAO();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("user") : null;
        
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String action = request.getParameter("action");
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        
        if ("uploadPicture".equals(action)) {
            try {
                Part filePart = request.getPart("profilePicFile");
                if (filePart != null && filePart.getSize() > 0) {
                    String fileName = filePart.getSubmittedFileName();
                    if (fileName == null || fileName.isEmpty()) {
                        out.print("{\"success\": false, \"message\": \"Invalid file name.\"}");
                        return;
                    }
                    
                    String extension = "";
                    int i = fileName.lastIndexOf('.');
                    if (i > 0) {
                        extension = fileName.substring(i);
                    }
                    
                    // Generate a unique filename
                    String newFileName = UUID.randomUUID().toString() + extension;
                    
                    // Save file to webapp/images directory
                    String uploadPath = getServletContext().getRealPath("") + File.separator + "images";
                    File uploadDir = new File(uploadPath);
                    if (!uploadDir.exists()) {
                        uploadDir.mkdirs();
                    }
                    
                    filePart.write(uploadPath + File.separator + newFileName);
                    
                    // Update database
                    boolean success = userDAO.updateProfilePicture(currentUser.getId(), newFileName);
                    if (success) {
                        // Update user in session
                        currentUser.setProfilePic(newFileName);
                        session.setAttribute("user", currentUser);
                        out.print("{\"success\": true, \"message\": \"Profile picture uploaded successfully!\", \"profilePic\": \"" + newFileName + "\"}");
                    } else {
                        out.print("{\"success\": false, \"message\": \"Failed to update profile in database.\"}");
                    }
                } else {
                    out.print("{\"success\": false, \"message\": \"No file selected or file is empty.\"}");
                }
            } catch (Exception e) {
                e.printStackTrace();
                out.print("{\"success\": false, \"message\": \"Upload error: " + e.getMessage() + "\"}");
            }
        } else if ("updatePicture".equals(action)) {
            String profilePic = request.getParameter("profilePic");
            
            if (profilePic != null && !profilePic.isEmpty()) {
                boolean success = userDAO.updateProfilePicture(currentUser.getId(), profilePic);
                if (success) {
                    // Update user in session
                    currentUser.setProfilePic(profilePic);
                    session.setAttribute("user", currentUser);
                    out.print("{\"success\": true, \"message\": \"Profile picture updated successfully!\", \"profilePic\": \"" + profilePic + "\"}");
                } else {
                    out.print("{\"success\": false, \"message\": \"Failed to update profile picture in database.\"}");
                }
            } else {
                out.print("{\"success\": false, \"message\": \"No profile picture selected.\"}");
            }
        } else {
            out.print("{\"success\": false, \"message\": \"Invalid action.\"}");
        }
        out.flush();
    }
}
