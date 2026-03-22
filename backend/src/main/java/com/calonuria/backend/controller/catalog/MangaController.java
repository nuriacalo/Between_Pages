package com.calonuria.backend.controller.catalog;

import com.calonuria.backend.dto.catalog.MangaRespuestaDTO;
import com.calonuria.backend.model.catalog.Manga;
import com.calonuria.backend.service.catalog.MangaService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/manga")
@Tag(name = "Catálogo de Manga", description = "Endpoints para búsqueda en MangaDex y base de datos local")
public class MangaController {

    @Autowired
    private MangaService mangaService;

    @Operation(summary = "Buscar mangas en MangaDex")
    @GetMapping("/buscar")
    public ResponseEntity<List<MangaRespuestaDTO>> buscarEnMangaDex(@RequestParam("q") String titulo) {
        return ResponseEntity.ok(mangaService.buscarEnMangaDex(titulo));
    }

    @Operation(summary = "Buscar mangas en base de datos local")
    @GetMapping("/buscar/local")
    public ResponseEntity<List<MangaRespuestaDTO>> buscarEnBD(@RequestParam("q") String titulo) {
        return ResponseEntity.ok(mangaService.buscarEnBD(titulo));
    }

    @Operation(summary = "Obtener manga por ID")
    @GetMapping("/{id}")
    public ResponseEntity<MangaRespuestaDTO> obtenerPorId(@PathVariable Long id) {
        return mangaService.obtenerMangaPorId(id)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    // Añadir en MangaController
    @Operation(summary = "Guardar manga en base de datos local")
    @PostMapping
    public ResponseEntity<MangaRespuestaDTO> guardarManga(@RequestBody MangaRespuestaDTO dto) {
        Manga manga = new Manga();
        manga.setMangadexId(dto.getMangadexId());
        manga.setFuente("MangaDex");
        manga.setTitulo(dto.getTitulo());
        manga.setMangaka(dto.getMangaka());
        manga.setDemografia(dto.getDemografia());
        manga.setGenero(dto.getGenero());
        manga.setDescripcion(dto.getDescripcion());
        manga.setPortadaUrl(dto.getPortadaUrl());
        manga.setTotalCapitulos(dto.getTotalCapitulos());
        manga.setTotalVolumenes(dto.getTotalVolumenes());
        manga.setEstadoPublicacion(dto.getEstadoPublicacion());
        return ResponseEntity.ok(mangaService.guardarSiNoExiste(manga));
    }
}