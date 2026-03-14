package com.calonuria.backend.dto.catalog;

import lombok.Data;

@Data
public class MangaRespuestaDTO {
    private Long idManga;
    private String mangadexId;
    private String titulo;
    private String mangaka;
    private String demografia;
    private String genero;
    private String descripcion;
    private String portadaUrl;
    private Integer totalCapitulos;
    private Integer totalVolumenes;
    private String estadoPublicacion;
}