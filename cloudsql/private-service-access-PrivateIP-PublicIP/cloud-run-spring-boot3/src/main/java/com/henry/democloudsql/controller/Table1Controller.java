package com.henry.democloudsql.controller;


import com.henry.democloudsql.model.publicip.Table1;
import com.henry.democloudsql.service.Table1Service;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
public class Table1Controller {

   private final Table1Service table1Service;

    public Table1Controller(Table1Service table1Service) {
        this.table1Service = table1Service;
    }

    @GetMapping
    public Iterable<Table1> findAll(){
        return table1Service.findAll();
    }
}
