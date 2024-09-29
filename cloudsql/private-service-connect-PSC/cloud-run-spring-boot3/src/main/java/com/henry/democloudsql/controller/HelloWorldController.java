package com.henry.democloudsql.controller;


import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
public class HelloWorldController {

    @GetMapping
    public Map<String,String> helloWorld(){
        Map<String,String> map = new HashMap<>();
        map.put("msg", "Hello Private Service Connect (PSC) ");
        return map;
    }
}
