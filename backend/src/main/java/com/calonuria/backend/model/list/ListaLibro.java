package com.calonuria.backend.model.list;

import com.calonuria.backend.model.catalog.Libro;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "lista_libro")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ListaLibro {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_lista", nullable = false)
    private Lista lista;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_libro", nullable = false)
    private Libro libro;

    private Integer orden;
}