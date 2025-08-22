package com.cput.moduletracker.repo;

import com.cput.moduletracker.domain.Intervention;
import org.springframework.data.jpa.repository.JpaRepository;

public interface InterventionRepository extends JpaRepository<Intervention, Integer> { }
