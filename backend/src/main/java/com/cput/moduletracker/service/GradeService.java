package com.cput.moduletracker.service;

import com.cput.moduletracker.domain.*;
import com.cput.moduletracker.repo.AssessmentRepository;
import com.cput.moduletracker.repo.GradeRepository;
import com.cput.moduletracker.repo.UserModuleRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.DoubleSummaryStatistics;
import java.util.List;

@Service
public class GradeService {
    private final GradeRepository gradeRepository;
    private final AssessmentRepository assessmentRepository;
    private final UserModuleRepository userModuleRepository;
    private final InterventionService interventionService;

    public GradeService(GradeRepository gradeRepository,
                        AssessmentRepository assessmentRepository,
                        UserModuleRepository userModuleRepository,
                        InterventionService interventionService) {
        this.gradeRepository = gradeRepository;
        this.assessmentRepository = assessmentRepository;
        this.userModuleRepository = userModuleRepository;
        this.interventionService = interventionService;
    }

    @Transactional
    public Grade saveGrade(Integer userModuleId, Integer assessmentId, Double score) {
        UserModule um = userModuleRepository.findById(userModuleId).orElseThrow();
        Assessment a = assessmentRepository.findById(assessmentId).orElseThrow();

        Grade g = new Grade();
        g.setUserModule(um);
        g.setAssessment(a);
        g.setScore(score);
        Grade saved = gradeRepository.save(g);

        double avg = calculateModuleAverage(userModuleId);
        if (avg < 50.0) {
            interventionService.createIntervention(um,
                "Tutoring Recommended",
                "Your average is below 50%. Tutoring is recommended.");
        }
        return saved;
    }

    public double calculateModuleAverage(Integer userModuleId) {
        List<Grade> grades = gradeRepository.findByUserModule_UserModuleId(userModuleId);
        if (grades.isEmpty()) return 0.0;

        double weightedSum = 0.0;
        double weightTotal = 0.0;

        for (Grade g : grades) {
            Double weight = g.getAssessment().getWeight();
            double w = weight == null ? 0.0 : weight;
            weightedSum += g.getScore() * w;
            weightTotal += w;
        }
        if (weightTotal <= 0.0) {
            DoubleSummaryStatistics stats = grades.stream().mapToDouble(Grade::getScore).summaryStatistics();
            return stats.getAverage();
        }
        return weightedSum / weightTotal;
    }
}
