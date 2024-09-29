package com.henry.democloudsql.service;


import com.henry.democloudsql.model.privateipvpc.Table2;

public interface Table2Service {

    Table2 save(Table2 obj);
    Iterable<Table2>  findAll();
    Table2 findById(Long id);
}
