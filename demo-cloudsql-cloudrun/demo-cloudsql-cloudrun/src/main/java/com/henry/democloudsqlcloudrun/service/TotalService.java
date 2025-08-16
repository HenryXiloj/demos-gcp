package com.henry.democloudsqlcloudrun.service;

import com.henry.democloudsqlcloudrun.model.Total;

public interface TotalService {

    Iterable<Total> save();

    Iterable<Total> findAll();
}
