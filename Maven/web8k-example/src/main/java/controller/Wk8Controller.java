package application.controller;

import application.service.Wk8Service;
import application.model.User;

import java.util.HashMap;
import java.util.Map;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/user")
public class Wk8Controller {
    private final Wk8Service service = Wk8Service.getInstance();

    @GetMapping("/add")
    public Map<String, Object> addUser(@RequestParam String name, @RequestParam String surName) {
        User user = new User();

        user.setName(name);
        user.setSurName(surName);

        Map<String, User> resultData = service.addUser(user);
        Map<String,Object> response = new HashMap<String, Object>();

        response.put("Total Data", resultData);

        return response;
    }
}