package com.calonuria.backend.features.search.controller;

import com.calonuria.backend.features.search.dto.BookResponseDTO;
import com.calonuria.backend.features.search.service.GoogleBooksService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * REST Controller that handles HTTP requests for external book searches.
 * Interacts with the {@link GoogleBooksService} to fetch book data from the Google Books API.
 * 
 * <p>Base path: {@code /api/external/book}</p>
 */
@RestController
@RequestMapping("/api/external/book")
@Tag(name = "External Books", description = "Búsqueda de libros en fuentes externas (Google Books)")
@RequiredArgsConstructor
public class ExternalBookController {

    private final GoogleBooksService googleBooksService;

    /**
     * Searches for books matching the given query string via the Google Books API.
     *
     * @param q the query string (e.g., book title, author, or ISBN)
     * @return a {@link ResponseEntity} containing a list of {@link BookResponseDTO} matching the query,
     *         or a 400 Bad Request if the query is empty.
     */
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