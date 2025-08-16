package com.henry.democloudsqlcloudrun.controller;


import com.henry.democloudsqlcloudrun.service.Batch1Service;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class Batch1Controller {

    private final Batch1Service batch1Service;

    public Batch1Controller(Batch1Service batch1Service) {
        this.batch1Service = batch1Service;
    }

    @GetMapping("/batch1")
    public ResponseEntity<String> batch() {
        return batch1Service.processBatch();
    }
}
