package com.calonuria.backend.model.catalog;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "fanfic_tag")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class FanficTag {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_tag")
    private Long idTag;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_fanfic", nullable = false)
    private Fanfiction fanfic;

    @Column(nullable = false, length = 100)
    private String tag;
}