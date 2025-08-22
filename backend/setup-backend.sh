#!/usr/bin/env bash
set -euo pipefail

echo "Creating backend directories..."
mkdir -p backend/src/main/java/com/cput/moduletracker/{config,domain,repo,service,web,bootstrap}
mkdir -p backend/src/main/resources/templates

echo "Writing files..."

cat > backend/pom.xml <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.cput</groupId>
  <artifactId>module-tracker</artifactId>
  <version>0.0.1-SNAPSHOT</version>
  <name>module-tracker</name>
  <description>CPUT Module Tracker - Term 3 minimal implementation</description>

  <properties>
    <java.version>17</java.version>
    <spring-boot.version>3.2.6</spring-boot.version>
  </properties>

  <parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>${spring-boot.version}</version>
    <relativePath/>
  </parent>

  <dependencies>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-thymeleaf</artifactId>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-jdbc</artifactId>
    </dependency>
    <dependency>
      <groupId>com.h2database</groupId>
      <artifactId>h2</artifactId>
      <scope>runtime</scope>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-security</artifactId>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-validation</artifactId>
    </dependency>

    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-test</artifactId>
      <scope>test</scope>
    </dependency>
    <dependency>
      <groupId>org.mockito</groupId>
      <artifactId>mockito-core</artifactId>
      <version>5.11.0</version>
      <scope>test</scope>
    </dependency>
  </dependencies>

  <build>
    <plugins>
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
      </plugin>
    </plugins>
  </build>
</project>
EOF

cat > backend/src/main/resources/application.properties <<'EOF'
# H2 Database
spring.h2.console.enabled=true
spring.h2.console.path=/h2-console
spring.h2.console.settings.web-allow-others=false

# Datasource (in-memory)
spring.datasource.url=jdbc:h2:mem:moduledb;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=password

# JPA
spring.jpa.database-platform=org.hibernate.dialect.H2Dialect
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=false

# Web
spring.thymeleaf.cache=false
server.port=8080

# Session cookie hardening (dev/demo)
server.servlet.session.cookie.http-only=true
server.servlet.session.cookie.same-site=strict
EOF

cat > backend/src/main/java/com/cput/moduletracker/ModuleTrackerApplication.java <<'EOF'
package com.cput.moduletracker;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class ModuleTrackerApplication {
    public static void main(String[] args) {
        SpringApplication.run(ModuleTrackerApplication.class, args);
    }
}
EOF

cat > backend/src/main/java/com/cput/moduletracker/config/SecurityConfig.java <<'EOF'
package com.cput.moduletracker.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
public class SecurityConfig {
    @Bean
    public PasswordEncoder passwordEncoder() { return new BCryptPasswordEncoder(); }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            // CSRF disabled for demo; can enable with Thymeleaf tokens if required.
            .csrf(csrf -> csrf.disable())
            .headers(h -> h.frameOptions(f -> f.sameOrigin()))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/h2-console/**", "/login", "/register", "/assets/**", "/css/**").permitAll()
                .requestMatchers("/dashboard", "/grades/**", "/logout").authenticated()
                .anyRequest().permitAll()
            )
            .httpBasic(Customizer.withDefaults())
            .formLogin(form -> form.disable())
            .logout(logout -> logout.logoutUrl("/logout").logoutSuccessUrl("/login"));
        return http.build();
    }
}
EOF

cat > backend/src/main/java/com/cput/moduletracker/domain/User.java <<'EOF'
package com.cput.moduletracker.domain;

import jakarta.persistence.*;

@Entity
@Table(name = "USER", uniqueConstraints = @UniqueConstraint(columnNames = "studentNumber"))
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer userId;

    @Column(nullable = false, unique = true)
    private String studentNumber;

    @Column(nullable = false)
    private String password; // BCrypt hashed

    private String fullName;

    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }
    public String getStudentNumber() { return studentNumber; }
    public void setStudentNumber(String studentNumber) { this.studentNumber = studentNumber; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
}
EOF

cat > backend/src/main/java/com/cput/moduletracker/domain/Module.java <<'EOF'
package com.cput.moduletracker.domain;

import jakarta.persistence.*;

@Entity
@Table(name = "MODULE")
public class Module {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer moduleId;

    @Column(nullable = false)
    private String moduleCode;

    private String moduleName;

    public Integer getModuleId() { return moduleId; }
    public String getModuleCode() { return moduleCode; }
    public void setModuleCode(String moduleCode) { this.moduleCode = moduleCode; }
    public String getModuleName() { return moduleName; }
    public void setModuleName(String moduleName) { this.moduleName = moduleName; }
}
EOF

cat > backend/src/main/java/com/cput/moduletracker/domain/AssessmentType.java <<'EOF'
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
EOF

cat > backend/src/main/java/com/cput/moduletracker/domain/Assessment.java <<'EOF'
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
EOF

cat > backend/src/main/java/com/cput/moduletracker/domain/UserModule.java <<'EOF'
package com.cput.moduletracker.domain;

import jakarta.persistence.*;

@Entity
@Table(name = "USER_MODULE")
public class UserModule {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer userModuleId;

    @ManyToOne(optional = false)
    @JoinColumn(name = "userId")
    private User user;

    @ManyToOne(optional = false)
    @JoinColumn(name = "moduleId")
    private Module module;

    public Integer getUserModuleId() { return userModuleId; }
    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }
    public Module getModule() { return module; }
    public void setModule(Module module) { this.module = module; }
}
EOF

cat > backend/src/main/java/com/cput/moduletracker/domain/Grade.java <<'EOF'
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
EOF

cat > backend/src/main/java/com/cput/moduletracker/domain/Intervention.java <<'EOF'
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
EOF

cat > backend/src/main/java/com/cput/moduletracker/repo/UserRepository.java <<'EOF'
package com.cput.moduletracker.repo;

import com.cput.moduletracker.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Integer> {
    Optional<User> findByStudentNumber(String studentNumber);
}
EOF

cat > backend/src/main/java/com/cput/moduletracker/repo/ModuleRepository.java <<'EOF'
package com.cput.moduletracker.repo;

import com.cput.moduletracker.domain.Module;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ModuleRepository extends JpaRepository<Module, Integer> { }
EOF

cat > backend/src/main/java/com/cput/moduletracker/repo/AssessmentTypeRepository.java <<'EOF'
package com.cput.moduletracker.repo;

import com.cput.moduletracker.domain.AssessmentType;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AssessmentTypeRepository extends JpaRepository<AssessmentType, Integer> { }
EOF

cat > backend/src/main/java/com/cput/moduletracker/repo/AssessmentRepository.java <<'EOF'
package com.cput.moduletracker.repo;

import com.cput.moduletracker.domain.Assessment;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface AssessmentRepository extends JpaRepository<Assessment, Integer> {
    List<Assessment> findByModule_ModuleId(Integer moduleId);
}
EOF

cat > backend/src/main/java/com/cput/moduletracker/repo/UserModuleRepository.java <<'EOF'
package com.cput.moduletracker.repo;

import com.cput.moduletracker.domain.UserModule;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface UserModuleRepository extends JpaRepository<UserModule, Integer> {
    List<UserModule> findByUser_UserId(Integer userId);
}
EOF

cat > backend/src/main/java/com/cput/moduletracker/repo/GradeRepository.java <<'EOF'
package com.cput.moduletracker.repo;

import com.cput.moduletracker.domain.Grade;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface GradeRepository extends JpaRepository<Grade, Integer> {
    List<Grade> findByUserModule_UserModuleId(Integer userModuleId);
}
EOF

cat > backend/src/main/java/com/cput/moduletracker/repo/InterventionRepository.java <<'EOF'
package com.cput.moduletracker.repo;

import com.cput.moduletracker.domain.Intervention;
import org.springframework.data.jpa.repository.JpaRepository;

public interface InterventionRepository extends JpaRepository<Intervention, Integer> { }
EOF

cat > backend/src/main/java/com/cput/moduletracker/service/UserService.java <<'EOF'
package com.cput.moduletracker.service;

import com.cput.moduletracker.domain.User;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.sql.PreparedStatement;
import java.sql.Statement;
import java.util.Optional;

@Service
public class UserService {

    private final JdbcTemplate jdbc;
    private final PasswordEncoder encoder;

    public UserService(JdbcTemplate jdbc, PasswordEncoder encoder) {
        this.jdbc = jdbc;
        this.encoder = encoder;
    }

    public User registerUser(String studentNumber, String fullName, String rawPassword) {
        Integer count = jdbc.queryForObject(
            "select count(*) from \"USER\" where studentNumber = ?",
            Integer.class, studentNumber
        );
        if (count != null && count > 0) throw new IllegalArgumentException("Student number already exists");

        String hash = encoder.encode(rawPassword);
        KeyHolder kh = new GeneratedKeyHolder();

        jdbc.update(conn -> {
            PreparedStatement ps = conn.prepareStatement(
                "insert into \"USER\" (studentNumber, password, fullName) values (?,?,?)",
                Statement.RETURN_GENERATED_KEYS
            );
            ps.setString(1, studentNumber);
            ps.setString(2, hash);
            ps.setString(3, fullName);
            return ps;
        }, kh);

        Number key = kh.getKey();
        User u = new User();
        u.setStudentNumber(studentNumber);
        u.setFullName(fullName);
        u.setPassword(hash);
        if (key != null) u.setUserId(key.intValue());
        return u;
    }

    public Optional<User> authenticate(String studentNumber, String rawPassword) {
        return jdbc.query(
            "select userId, studentNumber, password, fullName from \"USER\" where studentNumber = ?",
            rs -> {
                if (!rs.next()) return Optional.<User>empty();
                String hash = rs.getString("password");
                if (!encoder.matches(rawPassword, hash)) return Optional.<User>empty();
                User u = new User();
                u.setUserId(rs.getInt("userId"));
                u.setStudentNumber(rs.getString("studentNumber"));
                u.setPassword(hash);
                u.setFullName(rs.getString("fullName"));
                return Optional.of(u);
            },
            studentNumber
        );
    }
}
EOF

cat > backend/src/main/java/com/cput/moduletracker/service/InterventionService.java <<'EOF'
package com.cput.moduletracker.service;

import com.cput.moduletracker.domain.Intervention;
import com.cput.moduletracker.domain.UserModule;
import com.cput.moduletracker.repo.InterventionRepository;
import org.springframework.stereotype.Service;

@Service
public class InterventionService {
    private final InterventionRepository repo;

    public InterventionService(InterventionRepository repo) { this.repo = repo; }

    public Intervention createIntervention(UserModule userModule, String type, String recommendation) {
        Intervention i = new Intervention();
        i.setUserModule(userModule);
        i.setInterventionType(type);
        i.setRecommendation(recommendation);
        return repo.save(i);
    }
}
EOF

cat > backend/src/main/java/com/cput/moduletracker/service/GradeService.java <<'EOF'
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
EOF

cat > backend/src/main/java/com/cput/moduletracker/service/ModuleService.java <<'EOF'
package com.cput.moduletracker.service;

import com.cput.moduletracker.domain.UserModule;
import com.cput.moduletracker.repo.UserModuleRepository;
import org.springframework.stereotype.Service;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
public class ModuleService {
    private final UserModuleRepository userModuleRepository;
    private final GradeService gradeService;

    public ModuleService(UserModuleRepository userModuleRepository, GradeService gradeService) {
        this.userModuleRepository = userModuleRepository;
        this.gradeService = gradeService;
    }

    public Map<UserModule, Double> moduleAveragesForUser(Integer userId) {
        List<UserModule> list = userModuleRepository.findByUser_UserId(userId);
        Map<UserModule, Double> map = new LinkedHashMap<>();
        for (UserModule um : list) {
            map.put(um, gradeService.calculateModuleAverage(um.getUserModuleId()));
        }
        return map;
    }
}
EOF

cat > backend/src/main/java/com/cput/moduletracker/web/AuthController.java <<'EOF'
package com.cput.moduletracker.web;

import com.cput.moduletracker.domain.User;
import com.cput.moduletracker.service.UserService;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@Controller
public class AuthController {
    private final UserService userService;

    public AuthController(UserService userService) { this.userService = userService; }

    @GetMapping({"/", "/login"})
    public String loginPage(@RequestParam(value = "error", required = false) String error,
                            @RequestParam(value = "created", required = false) String created,
                            Model model) {
        model.addAttribute("error", error != null);
        model.addAttribute("created", created != null);
        return "login";
    }

    @PostMapping("/login")
    public String doLogin(@RequestParam String studentNumber,
                          @RequestParam String password,
                          HttpSession session) {
        Optional<User> user = userService.authenticate(studentNumber, password);
        if (user.isPresent()) {
            session.setAttribute("userId", user.get().getUserId());
            session.setAttribute("fullName", user.get().getFullName());
            session.setAttribute("studentNumber", user.get().getStudentNumber());
            return "redirect:/dashboard";
        }
        return "redirect:/login?error=1";
    }

    @GetMapping("/register")
    public String registerPage(@RequestParam(value = "error", required = false) String error,
                               @RequestParam(value = "msg", required = false) String msg,
                               Model model) {
        model.addAttribute("error", error);
        model.addAttribute("msg", msg);
        return "register";
    }

    @PostMapping("/register")
    public String doRegister(@RequestParam String studentNumber,
                             @RequestParam String fullName,
                             @RequestParam String password,
                             @RequestParam String confirmPassword) {
        if (!password.equals(confirmPassword)) {
            return "redirect:/register?error=Passwords+do+not+match";
        }
        try {
            userService.registerUser(studentNumber, fullName, password);
            return "redirect:/login?created=1";
        } catch (IllegalArgumentException ex) {
            return "redirect:/register?error=" + ex.getMessage().replace(" ", "+");
        } catch (Exception ex) {
            return "redirect:/register?error=Registration+failed";
        }
    }

    @GetMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/login";
    }
}
EOF

cat > backend/src/main/java/com/cput/moduletracker/web/DashboardController.java <<'EOF'
package com.cput.moduletracker.web;

import com.cput.moduletracker.domain.UserModule;
import com.cput.moduletracker.service.ModuleService;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.Map;

@Controller
public class DashboardController {
    private final ModuleService moduleService;

    public DashboardController(ModuleService moduleService) { this.moduleService = moduleService; }

    @GetMapping("/dashboard")
    public String showDashboard(HttpSession session, Model model) {
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) return "redirect:/login";
        String fullName = (String) session.getAttribute("fullName");
        Map<UserModule, Double> data = moduleService.moduleAveragesForUser(userId);
        model.addAttribute("fullName", fullName);
        model.addAttribute("moduleAverages", data);
        return "dashboard";
    }
}
EOF

cat > backend/src/main/java/com/cput/moduletracker/bootstrap/DataInitializer.java <<'EOF'
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
EOF

cat > backend/src/main/resources/templates/login.html <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Module Tracker - Login</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 40px; }
    .card { max-width: 400px; margin: 60px auto; padding: 24px; border: 1px solid #ddd; border-radius: 8px; }
    .error { color: #b00020; margin-bottom: 12px; }
    .success { color: #087f23; margin-bottom: 12px; }
    input { width: 100%; padding: 10px; margin: 8px 0; }
    button { width: 100%; padding: 10px; background: #1976d2; color: white; border: none; border-radius: 4px; }
    .links { margin-top: 10px; text-align: center; }
  </style>
</head>
<body>
<div class="card">
  <h2>Login</h2>
  <div th:if="${error}" class="error">Invalid student number or password</div>
  <div th:if="${created}" class="success">Account created. Please sign in.</div>
  <form method="post" action="/login">
    <label>Student Number</label>
    <input type="text" name="studentNumber" placeholder="e.g. S1234567" required>
    <label>Password</label>
    <input type="password" name="password" placeholder="Password" required>
    <button type="submit">Sign in</button>
  </form>
  <div class="links">
    <a href="/register">Create an account</a>
  </div>
</div>
</body>
</html>
EOF

cat > backend/src/main/resources/templates/register.html <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Create Account</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 40px; }
    .card { max-width: 460px; margin: 40px auto; padding: 24px; border: 1px solid #ddd; border-radius: 8px; }
    .error { color: #b00020; margin-bottom: 12px; }
    .msg { color: #333; margin-bottom: 12px; }
    input { width: 100%; padding: 10px; margin: 8px 0; }
    button { width: 100%; padding: 10px; background: #1976d2; color: white; border: none; border-radius: 4px; }
    a { text-decoration: none; color: #1976d2; }
  </style>
</head>
<body>
<div class="card">
  <h2>Create Account</h2>
  <div th:if="${error}" class="error" th:text="${error}">Error</div>
  <div th:if="${msg}" class="msg" th:text="${msg}">Message</div>
  <form method="post" action="/register">
    <label>Student Number</label>
    <input type="text" name="studentNumber" placeholder="e.g. S1234567" required>

    <label>Full Name</label>
    <input type="text" name="fullName" placeholder="Your full name" required>

    <label>Password</label>
    <input type="password" name="password" placeholder="Password" required>

    <label>Confirm Password</label>
    <input type="password" name="confirmPassword" placeholder="Confirm Password" required>

    <button type="submit">Create account</button>
  </form>
  <p style="margin-top: 12px;"><a href="/login">Back to login</a></p>
</div>
</body>
</html>
EOF

cat > backend/src/main/resources/templates/dashboard.html <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Module Tracker - Dashboard</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 24px; }
    .header { display: flex; justify-content: space-between; align-items: center; }
    .modules { margin-top: 24px; display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 16px; }
    .card { border: 1px solid #ddd; border-radius: 8px; padding: 16px; }
    .alert { background: #fff3f3; border: 1px solid #ffb3b3; color: #a30000; padding: 12px; border-radius: 6px; margin-top: 12px; }
  </style>
</head>
<body>
<div class="header">
  <h2 th:text="'Welcome, ' + ${fullName} + '!'">Welcome</h2>
  <div>
    <a href="/h2-console" target="_blank">H2 Console</a> |
    <a href="/logout">Logout</a>
  </div>
</div>

<h3>Your Modules</h3>
<div class="modules">
  <div class="card" th:each="entry : ${moduleAverages}">
    <h4 th:text="${entry.key.module.moduleCode} + ' - ' + ${entry.key.module.moduleName}">Module</h4>
    <p>Average:
      <b th:text="${#numbers.formatDecimal(entry.value, 1, 'POINT', 1, 'POINT')}">0.0</b>%
    </p>
    <div class="alert" th:if="${entry.value} &lt; 50.0">
      Your average in <span th:text="${entry.key.module.moduleName}">Module</span> is below 50%. Tutoring is recommended.
    </div>
  </div>
</div>
</body>
</html>
EOF

cat > backend/.gitignore <<'EOF'
/target
!.mvn/wrapper/maven-wrapper.jar
.mvn/
.idea/
.project
.classpath
.settings/
.DS_Store
*.log
EOF

cat > backend/README.md <<'EOF'
# CPUT Module Tracker (Term 3 Minimal)

Spring Boot + H2 + JDBC registration/login + weighted averages and intervention.

## Run

```bash
mvn -f backend/pom.xml spring-boot:run
