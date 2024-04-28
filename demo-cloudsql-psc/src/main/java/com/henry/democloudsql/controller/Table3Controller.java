package com.henry.democloudsql.controller;


import com.henry.democloudsql.model.Table3;
import com.henry.democloudsql.service.DefaultService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v3")
public class Table3Controller {

    private final DefaultService<Table3, Long> defaultService;

    public Table3Controller(DefaultService<Table3, Long> defaultService) {
        this.defaultService = defaultService;
    }

    @GetMapping
    public Iterable<Table3> findAll(){
        return defaultService.findAll();
    }
}
