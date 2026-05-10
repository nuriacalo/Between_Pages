package com.calonuria.backend.features.catalog.controller;

import com.calonuria.backend.features.catalog.dto.BookResponseDTO;
import com.calonuria.backend.features.catalog.service.external.GoogleBooksService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/external/book")
@Tag(name = "External Books", description = "Búsqueda de libros en fuentes externas (Google Books)")
@RequiredArgsConstructor
public class ExternalBookController {

    private final GoogleBooksService googleBooksService;

    @GetMapping("/search")
    @Operation(summary = "Buscar libros en Google Books",
               description = "Busca libros por título usando la API de Google Books")
    public ResponseEntity<List<BookResponseDTO>> searchBooks(@RequestParam String q) {
        if (q.trim().isEmpty()) {
            return ResponseEntity.badRequest().build();
        }
        List<BookResponseDTO> results = googleBooksService.searchBooks(q);
        return ResponseEntity.ok(results);
    }
}
