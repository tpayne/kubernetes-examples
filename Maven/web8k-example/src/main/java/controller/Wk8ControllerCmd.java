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
@RequestMapping("/cmd")
public class Wk8ControllerCmd {
    private final Wk8Service service = Wk8Service.getInstance();

    @GetMapping("/version")
    public String versionApp() {
        return String.format("<h2>Version 1.0</h2>");
    } 
}