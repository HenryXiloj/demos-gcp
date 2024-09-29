package com.henry.democloudsql.service;

import com.henry.democloudsql.model.publicip.Table1;

public interface Table1Service {

    Table1 save(Table1 obj);
    Iterable<Table1>  findAll();
    Table1 findById(Long id);
}
