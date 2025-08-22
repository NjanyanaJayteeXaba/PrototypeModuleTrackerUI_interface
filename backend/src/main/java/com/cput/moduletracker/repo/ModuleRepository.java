package com.cput.moduletracker.repo;

import com.cput.moduletracker.domain.Module;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ModuleRepository extends JpaRepository<Module, Integer> { }
