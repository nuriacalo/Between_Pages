package com.calonuria.backend.dto.list;

import com.calonuria.backend.dto.catalog.LibroRespuestaDTO;
import com.calonuria.backend.dto.catalog.FanfictionRespuestaDTO;
import com.calonuria.backend.dto.catalog.MangaRespuestaDTO;
import lombok.AllArgsConstructor;
import lombok.Data;
import java.util.List;

@Data
@AllArgsConstructor
public class ListaDetalleRespuestaDTO {
    private Long idLista;
    private String nombre;
    private List<LibroRespuestaDTO>       libros;
    private List<FanfictionRespuestaDTO>  fanfics;
    private List<MangaRespuestaDTO>       mangas;
}