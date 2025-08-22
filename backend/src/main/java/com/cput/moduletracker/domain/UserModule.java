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
