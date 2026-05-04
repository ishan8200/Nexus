package com.nex.controllers;

import java.io.IOException;
import com.nex.dao.SkillDAO;
import com.nex.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/manage-skills")
public class ManageSkillsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private SkillDAO skillDAO;

    @Override
    public void init() throws ServletException {
        skillDAO = new SkillDAO();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null || !"worker".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if ("add".equals(action)) {
            String skillIdStr = request.getParameter("skillId");
            String otherSkill = request.getParameter("otherSkill");
            String proficiencyStr = request.getParameter("proficiency");
            
            int proficiency = 1;
            try {
                if (proficiencyStr != null && !proficiencyStr.isEmpty()) {
                    proficiency = Integer.parseInt(proficiencyStr);
                }
            } catch (NumberFormatException e) {
                proficiency = 1;
            }

            boolean success = false;
            if (otherSkill != null && !otherSkill.trim().isEmpty()) {
                success = skillDAO.addNewSkillAndAssign(user.getId(), otherSkill.trim(), proficiency);
            } else if (skillIdStr != null && !skillIdStr.isEmpty()) {
                try {
                    int skillId = Integer.parseInt(skillIdStr);
                    success = skillDAO.addSkillToWorker(user.getId(), skillId, proficiency);
                } catch (NumberFormatException e) {
                    response.sendRedirect(request.getContextPath() + "/worker?error=Invalid skill ID");
                    return;
                }
            }

            if (success) {
                response.sendRedirect(request.getContextPath() + "/worker?success=Skill updated successfully");
            } else {
                response.sendRedirect(request.getContextPath() + "/worker?error=Could not update skill");
            }
        } else if ("remove".equals(action)) {
            String skillIdStr = request.getParameter("skillId");
            if (skillIdStr != null) {
                try {
                    int skillId = Integer.parseInt(skillIdStr);
                    boolean success = skillDAO.removeSkillFromWorker(user.getId(), skillId);
                    if (success) {
                        response.sendRedirect(request.getContextPath() + "/worker?success=Skill removed");
                    } else {
                        response.sendRedirect(request.getContextPath() + "/worker?error=Could not remove skill");
                    }
                } catch (NumberFormatException e) {
                    response.sendRedirect(request.getContextPath() + "/worker?error=Invalid skill ID");
                }
            }
        }
    }
}
