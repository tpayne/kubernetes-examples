package application.controller;

import application.service.Wk8Service;
import application.model.User;

import java.util.HashMap;
import java.util.Map;

import java.net.URI;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

@RestController
@RequestMapping("/user")
public class Wk8ControllerUser {
    private final Wk8Service service = Wk8Service.getInstance();

    @PostMapping(path= "/create", consumes = "application/json", produces = "application/json")
    public ResponseEntity<Object> addPostUser(
        @RequestHeader(name = "X-COM-PERSIST", required = false) String headerPersist,
        @RequestHeader(name = "X-COM-LOCATION", defaultValue = "USA") String headerLocation,
        @RequestBody User user) 
            throws Exception {

        Map<String, User> resultData = service.addUser(user);

        URI location = ServletUriComponentsBuilder.fromCurrentRequest()
                                    .path("/{name}")
                                    .buildAndExpand(user.getName())
                                    .toUri();
         
        //Send location in response
        return ResponseEntity.created(location).build();
    }

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

    @GetMapping("/version")
    public String versionApp() {
        return String.format("<h2>Version 1.0</h2>");
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

    @GetMapping("/find")
    public String findUsers(@RequestParam String name) {
        Map<String, User> resultData = service.getUsers();
        StringBuilder str = new StringBuilder();

        if (resultData.isEmpty() && !resultData.containsKey(name)) {
            str.append("<p><b>No users are registered against that name!</b>");
        } else {
            str.append("<p><b>The following user is registered...</b>");
            str.append("<br><ul>");
            User v = resultData.get(name);
            str.append("<li>" + v.getName() + " " + v.getSurName() + "</li>");
            str.append("<ul>");
        }
        str.append("</p>");
        return str.toString();
    }   
}