package com.calonuria.backend.model.catalog;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "libro")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Libro {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_libro")
    private Long idLibro;

    @Column(name = "google_books_id", unique = true, length = 50)
    private String googleBooksId;

    @Column(nullable = false)
    private String titulo;

    @Column(nullable = false)
    private String autor;

    @Column(length = 20)
    private String isbn;

    @Column(length = 150)
    private String editorial;

    @Column(columnDefinition = "TEXT")
    private String descripcion;

    @Column(name = "portada_url")
    private String portadaUrl;

    @Column(length = 100)
    private String genero;

    @Column(name = "tipo_libro", length = 50)
    private String tipoLibro;

    @Column(name = "anio_publicacion")
    private Integer anioPublicacion;
}