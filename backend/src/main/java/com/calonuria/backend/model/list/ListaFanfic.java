package com.calonuria.backend.model.list;

import com.calonuria.backend.model.catalog.Fanfiction;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "lista_fanfic")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ListaFanfic {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_lista", nullable = false)
    private Lista lista;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_fanfic", nullable = false)
    private Fanfiction fanfic;

    private Integer orden;
}