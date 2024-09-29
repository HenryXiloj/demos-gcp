package com.henry.democloudsql.service.impl;

import com.henry.democloudsql.model.privateipvpc.Table2;
import com.henry.democloudsql.repository.privateipvpc.Table2Repository;
import com.henry.democloudsql.service.Table2Service;
import org.springframework.stereotype.Service;

@Service
public class Table2ServiceImpl implements Table2Service {

    private final Table2Repository table2Repository;

    public Table2ServiceImpl(Table2Repository table2Repository) {
        this.table2Repository = table2Repository;
    }

    @Override
    public Table2 save(Table2 obj) {
        return null;
    }

    @Override
    public Iterable<Table2> findAll() {
        return table2Repository.findAll();
    }

    @Override
    public Table2 findById(Long id) {
        return null;
    }
}
