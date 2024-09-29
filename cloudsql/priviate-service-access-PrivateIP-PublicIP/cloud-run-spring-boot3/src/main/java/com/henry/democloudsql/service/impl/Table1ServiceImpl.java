package com.henry.democloudsql.service.impl;

import com.henry.democloudsql.model.publicip.Table1;
import com.henry.democloudsql.repository.publicip.Table1Repository;
import com.henry.democloudsql.service.Table1Service;
import org.springframework.stereotype.Service;

@Service
public final class Table1ServiceImpl implements Table1Service {

    private final Table1Repository table1Repository;

    public Table1ServiceImpl(Table1Repository table1Repository) {
        this.table1Repository = table1Repository;
    }

    @Override
    public Table1 save(Table1 obj) {
        return null;
    }

    @Override
    public Iterable<Table1> findAll() {
        return table1Repository.findAll();
    }

    @Override
    public Table1 findById(Long id) {
        return null;
    }
}
