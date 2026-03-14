package com.calonuria.backend.dto.catalog;

import lombok.Data;

@Data
public class LibroRespuestaDTO {
    private Long idLibro;
    private String googleBooksId;
    private String titulo;
    private String autor;
    private String isbn;
    private String editorial;
    private String descripcion;
    private String portadaUrl;
    private String genero;
    private String tipoLibro;
    private Integer anioPublicacion;
}