package com.henry.democloudsqlcloudrun.service.impl;

import com.henry.democloudsqlcloudrun.model.Total;
import com.henry.democloudsqlcloudrun.repository.TotalRepository;
import com.henry.democloudsqlcloudrun.service.Batch1Service;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;


@Service
public class Batch1ServiceImpl implements Batch1Service {

    private int counter;
    private final TotalRepository totalRepository;

    public Batch1ServiceImpl(TotalRepository totalRepository) {
        this.totalRepository = totalRepository;
    }

    @Override
    public Iterable<Total> findAll() {
        return totalRepository.findAll();
    }

    @Override
    public ResponseEntity<String> processBatch() {
        return null;
    }
}
