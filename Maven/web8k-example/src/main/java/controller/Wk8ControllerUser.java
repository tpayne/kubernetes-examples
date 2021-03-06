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
public class Wk8ControllerUser {
    private final Wk8Service service = Wk8Service.getInstance();

    @GetMapping("/add")
    public Map<String, Object> addUser(@RequestParam String name, @RequestParam String surName) {
        User user = new User();

        user.setName(name);
        user.setSurName(surName);

        Map<String, User> resultData = service.addUser(user);
        Map<String,Object> response = new HashMap<String, Object>();

        response.put("Submitted Data", resultData);

        return response;
    }

    @GetMapping("/hello")
    public String helloUser(@RequestParam String name, @RequestParam String surName) {
        return String.format("<h2>Hello - \"%s %s\"!</h2>", name, surName);
    }   

    @GetMapping("/list")
    public String listUsers() {
        Map<String, User> resultData = service.getUsers();
        StringBuilder str = new StringBuilder();

        if (resultData.isEmpty()) {
            str.append("<p><b>No users are registered!</b>");
        } else {
            str.append("<p><b>The following users are registered...</b>");
            str.append("<br><ol>");
            resultData.forEach(
                (k, v) -> str.append("<li>" + v.getName() + " " + v.getSurName() + "</li>")
            );
            str.append("<ol>");
        }
        str.append("</p>");
        return str.toString();
    }   
}