package com.calonuria.backend.dto.catalog;

import lombok.Data;
import java.util.List;

@Data
public class FanfictionRespuestaDTO {
    private Long idFanfic;
    private String ao3Id;
    private String titulo;
    private String autor;
    private String historiaBase;
    private String descripcion;
    private String portadaUrl;
    private String genero;
    private String shipPrincipal;
    private String tematica;
    private Integer capituloActual;
    private Integer totalCapitulos;
    private String estadoPublicacion;
    private List<String> tags;
}