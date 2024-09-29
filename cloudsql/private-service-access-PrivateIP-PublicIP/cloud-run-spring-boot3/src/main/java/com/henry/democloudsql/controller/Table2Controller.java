package com.henry.democloudsql.controller;


import com.henry.democloudsql.model.privateipvpc.Table2;
import com.henry.democloudsql.service.Table2Service;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v2")
public class Table2Controller {

    private final Table2Service table2Service;

    public Table2Controller(Table2Service table2Service) {
        this.table2Service = table2Service;
    }

    @GetMapping
    public Iterable<Table2> findAll(){
        return table2Service.findAll();
    }
}
