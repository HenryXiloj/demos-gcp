package com.henry.democloudsqlcloudrun.controller;


import com.henry.democloudsqlcloudrun.model.Total;
import com.henry.democloudsqlcloudrun.service.TotalService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class TotalController {

    private final TotalService totalService;

    public TotalController(TotalService totalService) {
        this.totalService = totalService;
    }

    @GetMapping("/")
    public ResponseEntity<String> hello() {
        return new ResponseEntity<>("Hello Batches ", HttpStatus.OK);
    }

    @GetMapping("/totals")
    public Iterable<Total> total() {
        totalService.save();
        return totalService.findAll();
    }
}
