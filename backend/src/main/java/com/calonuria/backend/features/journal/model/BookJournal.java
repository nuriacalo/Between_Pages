package com.calonuria.backend.features.journal.model;

import com.calonuria.backend.features.catalog.model.Book;
import io.hypersistence.utils.hibernate.type.json.JsonType;
import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.hibernate.annotations.Type;
import java.util.List;

/**
 * Entidad que representa el diario de lectura de un libro.
 * Mapea la tabla "book_journal" de la base de datos.
 * Extiende de BaseJournal para campos comunes.
 */
@Entity
@Table(name = "book_journal")
@Data
@EqualsAndHashCode(callSuper = true)
public class BookJournal extends BaseJournal {

    /**
     * Libro asociado al diario.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "book_id", nullable = false)
    private Book book;

    /**
     * Página actual de lectura.
     */
    @Column(name = "current_page")
    private Integer currentPage;

    /**
     * Emociones experimentadas durante la lectura (JSON).
     */
    @Type(JsonType.class)
    @Column(columnDefinition = "jsonb")
    private List<String> emotions;

    /**
     * Citas favoritas del libro.
     */
    @Column(name = "favorite_quotes", columnDefinition = "TEXT")
    private String favoriteQuotes;

    /**
     * Nombre de la serie o saga a la que pertenece el libro.
     */
    @Column(name = "series_name", length = 255)
    private String seriesName;

    /**
     * Orden del libro dentro de la serie.
     */
    @Column(name = "series_order")
    private Double seriesOrder;

    /**
     * Persona a la que se ha prestado el libro.
     */
    @Column(name = "loaned_to", length = 100)
    private String loanedTo;
}
