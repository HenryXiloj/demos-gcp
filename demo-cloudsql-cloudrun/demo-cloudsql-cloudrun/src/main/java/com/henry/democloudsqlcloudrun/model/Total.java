package com.henry.democloudsqlcloudrun.model;

import jakarta.persistence.*;
import lombok.*;


@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(name = "totals")
public class Total {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "total_id")
    private Long totalId;

    @Column(name = "candidate")
    private String candidate;

    @Column(name = "num_votes")
    private int numVotes = 0;
}
