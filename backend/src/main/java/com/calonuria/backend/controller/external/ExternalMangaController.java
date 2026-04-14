package com.calonuria.backend.controller.external;

import com.calonuria.backend.dto.catalog.MangaResponseDTO;
import com.calonuria.backend.service.external.JikanService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controlador para búsqueda de manga en fuentes externas.
 * Actualmente integrado con Jikan API (MyAnimeList).
 */
@RestController
@RequestMapping("/api/external/manga")
@Tag(name = "External Manga", description = "Búsqueda de manga en fuentes externas (MyAnimeList)")
public class ExternalMangaController {

    @Autowired
    private JikanService jikanService;

    /**
     * Busca manga en MyAnimeList vía Jikan API.
     * @param query título a buscar
     * @param page página de resultados (default: 1)
     * @param limit resultados por página (max: 25, default: 10)
     * @return lista de manga encontrado
     */
    @GetMapping("/search")
    @Operation(summary = "Buscar manga en MyAnimeList", 
               description = "Busca manga por título usando la API de Jikan (MyAnimeList)")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Búsqueda exitosa"),
        @ApiResponse(responseCode = "429", description = "Rate limit excedido por Jikan")
    })
    public ResponseEntity<List<MangaResponseDTO>> searchManga(
            @Parameter(description = "Título del manga a buscar") 
            @RequestParam String query,
            @Parameter(description = "Página de resultados (default: 1)")
            @RequestParam(defaultValue = "1") int page,
            @Parameter(description = "Resultados por página (max: 25)")
            @RequestParam(defaultValue = "10") int limit) {
        
        List<MangaResponseDTO> results = jikanService.searchManga(query, page, limit);
        return ResponseEntity.ok(results);
    }

    /**
     * Obtiene detalles de un manga específico de MyAnimeList.
     * @param malId ID de MyAnimeList
     * @return detalles del manga
     */
    @GetMapping("/{malId}")
    @Operation(summary = "Obtener manga de MyAnimeList", 
               description = "Obtiene detalles de un manga por su ID de MyAnimeList")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Manga encontrado"),
        @ApiResponse(responseCode = "404", description = "Manga no encontrado")
    })
    public ResponseEntity<MangaResponseDTO> getMangaById(
            @Parameter(description = "ID de MyAnimeList")
            @PathVariable int malId) {
        
        MangaResponseDTO manga = jikanService.getMangaById(malId);
        
        if (manga == null) {
            return ResponseEntity.notFound().build();
        }
        
        return ResponseEntity.ok(manga);
    }
}
