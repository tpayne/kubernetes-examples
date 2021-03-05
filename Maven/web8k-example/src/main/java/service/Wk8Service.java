package application.service;

import application.model.User;

import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

public class Wk8Service {
    public static Wk8Service getInstance() {
    return new Wk8Service();
}

private static Map<String, User> STORAGE_MAP = new HashMap<String, User>();         

public Map<String, User> addUser(User user) {
    Objects.nonNull(user.getName());
    STORAGE_MAP.put(user.getName(),user);
    return STORAGE_MAP;
}
}