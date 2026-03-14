package com.calonuria.backend.model.list;

import com.calonuria.backend.model.catalog.Manga;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "lista_manga")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ListaManga {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_lista", nullable = false)
    private Lista lista;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_manga", nullable = false)
    private Manga manga;

    private Integer orden;
}