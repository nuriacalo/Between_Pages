package com.calonuria.backend.dto.list;

import com.calonuria.backend.dto.catalog.BookResponseDTO;
import com.calonuria.backend.dto.catalog.FanfictionResponseDTO;
import com.calonuria.backend.dto.catalog.MangaResponseDTO;
import lombok.AllArgsConstructor;
import lombok.Data;
import java.util.List;

/**
 * DTO para la respuesta con detalle de una lista de lectura incluyendo sus elementos.
 */
@Data
@AllArgsConstructor
public class ReadingListDetailResponseDTO {

    private Long id;
    private String name;
    private List<BookResponseDTO> books;
    private List<FanfictionResponseDTO> fanfics;
    private List<MangaResponseDTO> mangas;
}