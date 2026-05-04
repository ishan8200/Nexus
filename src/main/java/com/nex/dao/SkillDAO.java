package com.nex.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.nex.config.DBConnection;

public class SkillDAO {

    public List<Map<String, Object>> getAllSkills() {
        List<Map<String, Object>> skills = new ArrayList<>();
        String sql = "SELECT * FROM skills ORDER BY skill_name ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> skill = new HashMap<>();
                skill.put("id", rs.getInt("id"));
                skill.put("skill_name", rs.getString("skill_name"));
                skill.put("category", rs.getString("category"));
                skills.add(skill);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return skills;
    }

    public List<Map<String, Object>> getWorkerSkills(int workerId) {
        List<Map<String, Object>> skills = new ArrayList<>();
        String sql = "SELECT s.*, ws.proficiency_level FROM skills s " +
                     "JOIN worker_skills ws ON s.id = ws.skill_id " +
                     "WHERE ws.worker_id = ? ORDER BY s.skill_name ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, workerId);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> skill = new HashMap<>();
                skill.put("id", rs.getInt("id"));
                skill.put("skill_name", rs.getString("skill_name"));
                skill.put("category", rs.getString("category"));
                skill.put("proficiency_level", rs.getInt("proficiency_level"));
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
            return pstmt.executeUpdate() > 0;
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
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
