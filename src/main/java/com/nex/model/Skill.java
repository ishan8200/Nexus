package com.nex.model;

import java.sql.Timestamp;

public class Skill {
    private int id;
    private String skillName;
    private String category;
    private Timestamp createdAt;
    
    // Optional field for worker-skill relationship
    private Integer proficiencyLevel;

    public Skill() {}

    public Skill(int id, String skillName, String category) {
        this.id = id;
        this.skillName = skillName;
        this.category = category;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getSkillName() {
        return skillName;
    }

    public void setSkillName(String skillName) {
        this.skillName = skillName;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Integer getProficiencyLevel() {
        return proficiencyLevel;
    }

    public void setProficiencyLevel(Integer proficiencyLevel) {
        this.proficiencyLevel = proficiencyLevel;
    }
}
