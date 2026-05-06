package com.calonuria.backend.model.journal;

import com.calonuria.backend.model.catalog.Book;
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
     * Formato de lectura: PHYSICAL, DIGITAL, AUDIOBOOK.
     */
    @Column(name = "reading_format", length = 50)
    private String readingFormat;

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
     * Tipo de propiedad del libro: DIGITAL, PHYSICAL, NONE, BORROWED.
     */
    @Column(length = 20)
    private String ownership;

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
