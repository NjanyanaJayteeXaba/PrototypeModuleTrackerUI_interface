package com.cput.moduletracker.web;

import com.cput.moduletracker.domain.User;
import com.cput.moduletracker.service.UserService;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@Controller
public class AuthController {
    private final UserService userService;

    public AuthController(UserService userService) { this.userService = userService; }

    @GetMapping({"/", "/login"})
    public String loginPage(@RequestParam(value = "error", required = false) String error,
                            @RequestParam(value = "created", required = false) String created,
                            Model model) {
        model.addAttribute("error", error != null);
        model.addAttribute("created", created != null);
        return "login";
    }

    @PostMapping("/login")
    public String doLogin(@RequestParam String studentNumber,
                          @RequestParam String password,
                          HttpSession session) {
        Optional<User> user = userService.authenticate(studentNumber, password);
        if (user.isPresent()) {
            session.setAttribute("userId", user.get().getUserId());
            session.setAttribute("fullName", user.get().getFullName());
            session.setAttribute("studentNumber", user.get().getStudentNumber());
            return "redirect:/dashboard";
        }
        return "redirect:/login?error=1";
    }

    @GetMapping("/register")
    public String registerPage(@RequestParam(value = "error", required = false) String error,
                               @RequestParam(value = "msg", required = false) String msg,
                               Model model) {
        model.addAttribute("error", error);
        model.addAttribute("msg", msg);
        return "register";
    }

    @PostMapping("/register")
    public String doRegister(@RequestParam String studentNumber,
                             @RequestParam String fullName,
                             @RequestParam String password,
                             @RequestParam String confirmPassword) {
        if (!password.equals(confirmPassword)) {
            return "redirect:/register?error=Passwords+do+not+match";
        }
        try {
            userService.registerUser(studentNumber, fullName, password);
            return "redirect:/login?created=1";
        } catch (IllegalArgumentException ex) {
            return "redirect:/register?error=" + ex.getMessage().replace(" ", "+");
        } catch (Exception ex) {
            return "redirect:/register?error=Registration+failed";
        }
    }

    @GetMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/login";
    }
}
