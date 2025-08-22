package com.cput.moduletracker.repo;

import com.cput.moduletracker.domain.UserModule;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface UserModuleRepository extends JpaRepository<UserModule, Integer> {
    List<UserModule> findByUser_UserId(Integer userId);
}
