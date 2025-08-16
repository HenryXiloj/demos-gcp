package com.henry.democloudsqlcloudrun.service.impl;

import com.henry.democloudsqlcloudrun.model.Total;
import com.henry.democloudsqlcloudrun.repository.TotalRepository;
import com.henry.democloudsqlcloudrun.service.Batch2Service;
import org.springframework.stereotype.Service;

@Service
public class Batch2ServiceImpl implements Batch2Service {

    private final TotalRepository totalRepository;

    public Batch2ServiceImpl(TotalRepository totalRepository) {
        this.totalRepository = totalRepository;
    }

    @Override
    public Iterable<Total> findAll() {
        return totalRepository.findAll();
    }
}
