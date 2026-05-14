package com.nex.model;

import java.sql.Timestamp;

public class Setting {
    private int id;
    private String configKey;
    private String configValue;
    private Timestamp updatedAt;

    public Setting() {}

    public Setting(String configKey, String configValue) {
        this.configKey = configKey;
        this.configValue = configValue;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getConfigKey() { return configKey; }
    public void setConfigKey(String configKey) { this.configKey = configKey; }

    public String getConfigValue() { return configValue; }
    public void setConfigValue(String configValue) { this.configValue = configValue; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}
