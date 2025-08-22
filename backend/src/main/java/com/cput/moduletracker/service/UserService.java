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
