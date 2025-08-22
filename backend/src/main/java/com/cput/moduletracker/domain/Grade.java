package com.cput.moduletracker.domain;

import jakarta.persistence.*;

@Entity
@Table(name = "GRADE")
public class Grade {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer gradeId;

    @ManyToOne(optional = false)
    @JoinColumn(name = "userModuleId")
    private UserModule userModule;

    @ManyToOne(optional = false)
    @JoinColumn(name = "assessmentId")
    private Assessment assessment;

    private Double score; // 0-100

    public Integer getGradeId() { return gradeId; }
    public UserModule getUserModule() { return userModule; }
    public void setUserModule(UserModule userModule) { this.userModule = userModule; }
    public Assessment getAssessment() { return assessment; }
    public void setAssessment(Assessment assessment) { this.assessment = assessment; }
    public Double getScore() { return score; }
    public void setScore(Double score) { this.score = score; }
}
