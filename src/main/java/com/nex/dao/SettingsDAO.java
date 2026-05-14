package com.nex.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

import com.nex.config.DBConnection;

public class SettingsDAO {

    public Map<String, String> getAllSettings() {
        Map<String, String> settings = new HashMap<>();
        String sql = "SELECT config_key, config_value FROM site_settings";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                settings.put(rs.getString("config_key"), rs.getString("config_value"));
            }
        } catch (SQLException e) {
            // Table might not exist yet, return empty or defaults
            System.err.println("Warning: Could not fetch settings. Table 'site_settings' may be missing.");
        }
        return settings;
    }

    public String getSetting(String key, String defaultValue) {
        String sql = "SELECT config_value FROM site_settings WHERE config_key = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, key);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getString("config_value");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return defaultValue;
    }

    public boolean updateSetting(String key, String value) {
        String sql = "INSERT INTO site_settings (config_key, config_value) VALUES (?, ?) " +
                     "ON DUPLICATE KEY UPDATE config_value = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, key);
            pstmt.setString(2, value);
            pstmt.setString(3, value);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteSetting(String key) {
        String sql = "DELETE FROM site_settings WHERE config_key = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, key);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public void initializeDefaults() {
        String[][] defaults = {
            {"home_hero_title", "NEXT-GEN OPERATIONAL NEXUS FOR MODERN TEAMS"},
            {"home_hero_subtitle", "A raw, structural platform designed for high-velocity project management. No fluff, just pure architectural logic for builders."},
            {"about_title", "THE NEXUS VISION"},
            {"about_content", "Nexus was engineered to bridge the gap between abstract strategy and concrete execution. We believe in high-fidelity operational transparency."},
            {"contact_email", "ops@nexus-works.io"},
            {"contact_phone", "+977 1 4445556"},
            {"contact_address", "Node 01, Sector 7, Kathmandu, Nepal"},
            {"maintenance_mode", "false"},
            {"registration_enabled", "true"},
            {"system_announcement", ""},
            {"social_facebook", "https://facebook.com/nexus"},
            {"social_instagram", "https://instagram.com/nexus"},
            {"social_linkedin", "https://linkedin.com/company/nexus"},
            {"social_whatsapp", "https://wa.me/9779800000000"},
            {"site_logo_url", "/images/Nexuslogo_1.jpg"}
        };

        for (String[] def : defaults) {
            updateSetting(def[0], def[1]);
        }
    }
}
