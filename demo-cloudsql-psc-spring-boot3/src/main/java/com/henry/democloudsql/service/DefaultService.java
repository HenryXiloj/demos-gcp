package com.henry.democloudsql.service;

public sealed  interface DefaultService<T, G> permits Table3ServiceImpl {
    T save(T obj);
    Iterable<T>  findAll();
    T findById(G id);
}
