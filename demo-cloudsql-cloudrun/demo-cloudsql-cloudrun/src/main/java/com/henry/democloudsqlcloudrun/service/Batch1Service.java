package com.henry.democloudsqlcloudrun.service;

import com.henry.democloudsqlcloudrun.model.Total;
import org.springframework.http.ResponseEntity;

public interface Batch1Service {

    Iterable<Total> findAll();
    ResponseEntity<String> processBatch();
}
