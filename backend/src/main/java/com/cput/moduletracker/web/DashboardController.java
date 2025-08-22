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
