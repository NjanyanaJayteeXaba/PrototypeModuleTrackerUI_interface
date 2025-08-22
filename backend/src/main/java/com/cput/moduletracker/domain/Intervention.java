package com.cput.moduletracker.domain;

import jakarta.persistence.*;

@Entity
@Table(name = "INTERVENTION")
public class Intervention {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer interventionId;

    @ManyToOne(optional = false)
    @JoinColumn(name = "userModuleId")
    private UserModule userModule;

    private String interventionType;
    private String recommendation;

    public Integer getInterventionId() { return interventionId; }
    public UserModule getUserModule() { return userModule; }
    public void setUserModule(UserModule userModule) { this.userModule = userModule; }
    public String getInterventionType() { return interventionType; }
    public void setInterventionType(String interventionType) { this.interventionType = interventionType; }
    public String getRecommendation() { return recommendation; }
    public void setRecommendation(String recommendation) { this.recommendation = recommendation; }
}
