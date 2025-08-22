package com.cput.moduletracker.domain;

import jakarta.persistence.*;

@Entity
@Table(name = "ASSESSMENT_TYPE")
public class AssessmentType {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer assessmentTypeId;

    private String typeName;

    public Integer getAssessmentTypeId() { return assessmentTypeId; }
    public String getTypeName() { return typeName; }
    public void setTypeName(String typeName) { this.typeName = typeName; }
}
