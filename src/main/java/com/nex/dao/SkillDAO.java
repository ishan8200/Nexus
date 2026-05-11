package com.nex.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.nex.config.DBConnection;
import com.nex.model.Skill;

public class SkillDAO {

    public List<Skill> getAllSkills() {
        List<Skill> skills = new ArrayList<>();
        String sql = "SELECT * FROM skills ORDER BY skill_name ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                Skill skill = new Skill();
                skill.setId(rs.getInt("id"));
                skill.setSkillName(rs.getString("skill_name"));
                skill.setCategory(rs.getString("category"));
                skill.setCreatedAt(rs.getTimestamp("created_at"));
                skills.add(skill);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return skills;
    }

    public List<Skill> getWorkerSkills(int workerId) {
        List<Skill> skills = new ArrayList<>();
        String sql = "SELECT s.*, ws.proficiency_level FROM skills s " +
                     "JOIN worker_skills ws ON s.id = ws.skill_id " +
                     "WHERE ws.worker_id = ? ORDER BY s.skill_name ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, workerId);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                Skill skill = new Skill();
                skill.setId(rs.getInt("id"));
                skill.setSkillName(rs.getString("skill_name"));
                skill.setCategory(rs.getString("category"));
                skill.setProficiencyLevel(rs.getInt("proficiency_level"));
                skill.setCreatedAt(rs.getTimestamp("created_at"));
                skills.add(skill);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return skills;
    }

    public boolean addSkillToWorker(int workerId, int skillId, int proficiency) {
        String sql = "INSERT INTO worker_skills (worker_id, skill_id, proficiency_level) VALUES (?, ?, ?) " +
                     "ON DUPLICATE KEY UPDATE proficiency_level = VALUES(proficiency_level)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, workerId);
            pstmt.setInt(2, skillId);
            pstmt.setInt(3, proficiency);
            boolean success = pstmt.executeUpdate() > 0;
            if (success) {
                updateUserSkillsColumn(workerId);
            }
            return success;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean addNewSkillAndAssign(int workerId, String skillName, int proficiency) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Check if skill already exists
            int skillId = -1;
            String checkSql = "SELECT id FROM skills WHERE LOWER(skill_name) = LOWER(?)";
            try (PreparedStatement pstmt = conn.prepareStatement(checkSql)) {
                pstmt.setString(1, skillName);
                ResultSet rs = pstmt.executeQuery();
                if (rs.next()) {
                    skillId = rs.getInt("id");
                }
            }

            // 2. If not exists, insert it
            if (skillId == -1) {
                String insertSkillSql = "INSERT INTO skills (skill_name) VALUES (?)";
                try (PreparedStatement pstmt = conn.prepareStatement(insertSkillSql, Statement.RETURN_GENERATED_KEYS)) {
                    pstmt.setString(1, skillName);
                    pstmt.executeUpdate();
                    ResultSet rs = pstmt.getGeneratedKeys();
                    if (rs.next()) {
                        skillId = rs.getInt(1);
                    }
                }
            }

            // 3. Assign to worker
            if (skillId != -1) {
                String assignSql = "INSERT INTO worker_skills (worker_id, skill_id, proficiency_level) VALUES (?, ?, ?) " +
                                   "ON DUPLICATE KEY UPDATE proficiency_level = VALUES(proficiency_level)";
                try (PreparedStatement pstmt = conn.prepareStatement(assignSql)) {
                    pstmt.setInt(1, workerId);
                    pstmt.setInt(2, skillId);
                    pstmt.setInt(3, proficiency);
                    pstmt.executeUpdate();
                }
            }

            conn.commit();
            updateUserSkillsColumn(workerId);
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }

    public boolean removeSkillFromWorker(int workerId, int skillId) {
        String sql = "DELETE FROM worker_skills WHERE worker_id = ? AND skill_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, workerId);
            pstmt.setInt(2, skillId);
            boolean success = pstmt.executeUpdate() > 0;
            if (success) {
                updateUserSkillsColumn(workerId);
            }
            return success;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Helper method to keep the legacy 'skills' column in users table in sync
     * with the worker_skills table. This allows existing views and logic to 
     * still function correctly while we transition to a normalized structure.
     */
    private void updateUserSkillsColumn(int workerId) {
        List<Skill> skills = getWorkerSkills(workerId);
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < skills.size(); i++) {
            sb.append(skills.get(i).getSkillName());
            if (i < skills.size() - 1) {
                sb.append(", ");
            }
        }
        
        String sql = "UPDATE users SET skills = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, sb.toString());
            pstmt.setInt(2, workerId);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
