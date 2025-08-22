package com.cput.moduletracker.domain;

import jakarta.persistence.*;

@Entity
@Table(name = "ASSESSMENT")
public class Assessment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer assessmentId;

    @ManyToOne(optional = false)
    @JoinColumn(name = "moduleId")
    private Module module;

    @ManyToOne(optional = false)
    @JoinColumn(name = "assessmentTypeId")
    private AssessmentType assessmentType;

    // Percent: e.g., 20.0 for 20%
    private Double weight;

    public Integer getAssessmentId() { return assessmentId; }
    public Module getModule() { return module; }
    public void setModule(Module module) { this.module = module; }
    public AssessmentType getAssessmentType() { return assessmentType; }
    public void setAssessmentType(AssessmentType assessmentType) { this.assessmentType = assessmentType; }
    public Double getWeight() { return weight; }
    public void setWeight(Double weight) { this.weight = weight; }
}
