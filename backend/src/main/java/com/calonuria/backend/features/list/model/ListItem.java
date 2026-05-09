package com.calonuria.backend.model.list;

import com.calonuria.backend.model.catalog.Book;
import com.calonuria.backend.model.catalog.Fanfiction;
import com.calonuria.backend.model.catalog.Manga;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Entidad que representa un elemento de una lista de lectura.
 * Mapea la tabla "list_item" de la base de datos.
 * Esta entidad utiliza una relación polimórfica que puede referenciar
 * un libro, un manga o un fanfiction.
 */
@Entity
@Table(name = "list_item")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ListItem {

    /**
     * Identificador único del elemento.
     */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * Lista a la que pertenece el elemento.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "list_id", nullable = false)
    private ReadingList list;

    /**
     * Tipo de elemento: BOOK, MANGA, FANFIC.
     */
    @Column(name = "item_type", nullable = false, length = 20)
    private String itemType;

    /**
     * Libro asociado (solo si item_type = BOOK).
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "book_id")
    private Book book;

    /**
     * Manga asociado (solo si item_type = MANGA).
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "manga_id")
    private Manga manga;

    /**
     * Fanfiction asociado (solo si item_type = FANFIC).
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "fanfic_id")
    private Fanfiction fanfic;

    /**
     * Posición del elemento en la lista.
     */
    @Column
    private Integer position;
}
