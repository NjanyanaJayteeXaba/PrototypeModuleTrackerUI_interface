package com.cput.moduletracker.repo;

import com.cput.moduletracker.domain.Grade;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface GradeRepository extends JpaRepository<Grade, Integer> {
    List<Grade> findByUserModule_UserModuleId(Integer userModuleId);
}
