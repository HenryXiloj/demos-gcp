package com.henry.democloudsqlcloudrun.service.impl;

import com.henry.democloudsqlcloudrun.model.Total;
import com.henry.democloudsqlcloudrun.repository.TotalRepository;
import com.henry.democloudsqlcloudrun.service.TotalService;
import com.henry.democloudsqlcloudrun.util.SSHFileReader;
import org.springframework.stereotype.Service;

@Service
public class TotalServiceImpl implements TotalService {

    private final TotalRepository totalRepository;

    public TotalServiceImpl(TotalRepository totalRepository) {
        this.totalRepository = totalRepository;
    }

    @Override
    public Iterable<Total> save() {
        var total = totalRepository
                .save(Total.builder().candidate("ABC").numVotes(1).build());
        return totalRepository.findAll();
    }

    @Override
    public Iterable<Total> findAll() {

        try {
            String content  = SSHFileReader.readFile("10.10.1.8", "henry1", "hxi123","/home/henry1/test.txt");
            System.out.println("content: "+content);
            return totalRepository.findAll();
        }
        catch (Exception e){
            e.printStackTrace();
            return null;
        }

    }
}
