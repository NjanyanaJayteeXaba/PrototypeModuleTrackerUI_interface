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
