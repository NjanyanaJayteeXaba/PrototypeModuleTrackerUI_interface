package com.cput.moduletracker.repo;

import com.cput.moduletracker.domain.Assessment;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface AssessmentRepository extends JpaRepository<Assessment, Integer> {
    List<Assessment> findByModule_ModuleId(Integer moduleId);
}
