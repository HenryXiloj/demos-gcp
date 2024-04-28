package com.henry.democloudsql.service;

import com.henry.democloudsql.repository.Table3Repository;
import org.springframework.stereotype.Service;

@Service
public final class Table3ServiceImpl implements DefaultService {

    private  final Table3Repository table3Repository;

    public Table3ServiceImpl(Table3Repository table3Repository) {
        this.table3Repository = table3Repository;
    }

    @Override
    public Object save(Object obj) {
        return null;
    }

    @Override
    public Iterable findAll() {
        return table3Repository.findAll();
    }

    @Override
    public Object findById(Object id) {
        return null;
    }
}
