package com.nex.controllers;

import java.io.IOException;
import com.nex.dao.TaskDAO;
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

@WebServlet("/submit-task")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1, // 1 MB
    maxFileSize = 1024 * 1024 * 50,      // 50 MB
    maxRequestSize = 1024 * 1024 * 100   // 100 MB
)
public class SubmitTaskServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private TaskDAO taskDAO;

    @Override
    public void init() throws ServletException {
        taskDAO = new TaskDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null || !"worker".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String assignmentIdStr = request.getParameter("assignmentId");
        String submissionText = request.getParameter("submissionText");
        String hoursWorkedStr = request.getParameter("hoursWorked");
        
        if (assignmentIdStr == null || submissionText == null || submissionText.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/worker?error=Missing submission details");
            return;
        }

        try {
            int assignmentId = Integer.parseInt(assignmentIdStr);
            double hoursWorked = 0.0;
            if (hoursWorkedStr != null && !hoursWorkedStr.isEmpty()) {
                hoursWorked = Double.parseDouble(hoursWorkedStr);
            }

            StringBuilder attachmentPaths = new StringBuilder();
            String realPath = getServletContext().getRealPath("");
            String uploadPath = null;
            if (realPath != null) {
                uploadPath = realPath + File.separator + "submissions";
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }
            }

            for (Part part : request.getParts()) {
                if (part.getName().equals("attachment") && part.getSize() > 0) {
                    String fileName = getFileName(part);
                    if (fileName != null && !fileName.isEmpty()) {
                        String extension = "";
                        int i = fileName.lastIndexOf('.');
                        if (i > 0) {
                            extension = fileName.substring(i);
                        }
                        
                        String newFileName = UUID.randomUUID().toString() + extension;
                        
                        if (uploadPath != null) {
                            part.write(uploadPath + File.separator + newFileName);
                            if (attachmentPaths.length() > 0) attachmentPaths.append(",");
                            attachmentPaths.append(newFileName);
                        }
                    }
                }
            }

            String finalPath = attachmentPaths.length() > 0 ? attachmentPaths.toString() : null;
            boolean success = taskDAO.submitTaskWork(assignmentId, submissionText, finalPath, hoursWorked);
            
            if (success) {
                response.sendRedirect(request.getContextPath() + "/worker?success=Work submitted successfully! Awaiting review.");
            } else {
                response.sendRedirect(request.getContextPath() + "/worker?error=Failed to submit work");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/worker?error=Invalid assignment ID");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/worker?error=Upload error: " + e.getMessage());
        }
    }

    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] tokens = contentDisp.split(";");
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return "";
    }
}