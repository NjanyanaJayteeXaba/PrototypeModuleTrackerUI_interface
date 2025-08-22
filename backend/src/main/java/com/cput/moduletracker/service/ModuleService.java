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
