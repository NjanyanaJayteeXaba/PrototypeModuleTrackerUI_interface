package com.cput.moduletracker.bootstrap;

import com.cput.moduletracker.domain.*;
import com.cput.moduletracker.repo.*;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
public class DataInitializer implements CommandLineRunner {

    private final UserRepository userRepo;
    private final ModuleRepository moduleRepo;
    private final AssessmentTypeRepository typeRepo;
    private final AssessmentRepository assessRepo;
    private final UserModuleRepository userModuleRepo;
    private final GradeRepository gradeRepo;
    private final PasswordEncoder encoder;

    public DataInitializer(UserRepository userRepo,
                           ModuleRepository moduleRepo,
                           AssessmentTypeRepository typeRepo,
                           AssessmentRepository assessRepo,
                           UserModuleRepository userModuleRepo,
                           GradeRepository gradeRepo,
                           PasswordEncoder encoder) {
        this.userRepo = userRepo;
        this.moduleRepo = moduleRepo;
        this.typeRepo = typeRepo;
        this.assessRepo = assessRepo;
        this.userModuleRepo = userModuleRepo;
        this.gradeRepo = gradeRepo;
        this.encoder = encoder;
    }

    @Override
    public void run(String... args) {
        // Seed a demo user only if not exists
        User u = userRepo.findByStudentNumber("S1234567").orElseGet(() -> {
            User nu = new User();
            nu.setStudentNumber("S1234567");
            nu.setFullName("Demo Student");
            nu.setPassword(encoder.encode("password"));
            return userRepo.save(nu);
        });

        // Module
        Module m = new Module();
        m.setModuleCode("ADF2");
        m.setModuleName("Applications Development Fundamentals 2");
        m = moduleRepo.save(m);

        // Enrollment
        UserModule um = new UserModule();
        um.setUser(u);
        um.setModule(m);
        um = userModuleRepo.save(um);

        // Assessment types
        AssessmentType test = new AssessmentType(); test.setTypeName("Test"); test = typeRepo.save(test);
        AssessmentType exam = new AssessmentType(); exam.setTypeName("Exam"); exam = typeRepo.save(exam);
        AssessmentType project = new AssessmentType(); project.setTypeName("Project"); project = typeRepo.save(project);

        // Assessments (weights sum to 100)
        Assessment a1 = new Assessment(); a1.setModule(m); a1.setAssessmentType(test); a1.setWeight(20.0); a1 = assessRepo.save(a1);
        Assessment a2 = new Assessment(); a2.setModule(m); a2.setAssessmentType(project); a2.setWeight(30.0); a2 = assessRepo.save(a2);
        Assessment a3 = new Assessment(); a3.setModule(m); a3.setAssessmentType(exam); a3.setWeight(50.0); a3 = assessRepo.save(a3);

        // Initial Grades
        Grade g1 = new Grade(); g1.setUserModule(um); g1.setAssessment(a1); g1.setScore(80.0); gradeRepo.save(g1);
        Grade g2 = new Grade(); g2.setUserModule(um); g2.setAssessment(a2); g2.setScore(70.0); gradeRepo.save(g2);
        Grade g3 = new Grade(); g3.setUserModule(um); g3.setAssessment(a3); g3.setScore(90.0); gradeRepo.save(g3);
    }
}
