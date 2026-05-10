package com.calonuria.backend.features.catalog.controller;

import com.calonuria.backend.features.catalog.dto.BookResponseDTO;
import com.calonuria.backend.features.catalog.model.Book;
import com.calonuria.backend.features.catalog.service.BookService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/book")
@Tag(name = "Catálogo de Libros", description = "Endpoints para búsqueda y gestión de libros en la base de datos local")
public class BookController extends BaseCatalogController<Book, BookResponseDTO, Long, BookService> {

    public BookController(BookService bookService) {
        super(bookService);
    }

    @Operation(summary = "Buscar libros en la base de datos local")
    @GetMapping("/search")
    @Override
    public ResponseEntity<List<BookResponseDTO>> searchByTitle(@RequestParam(value = "q") String title) {
        if (title.trim().isEmpty()) {
            return ResponseEntity.badRequest().build();
        }
        return ResponseEntity.ok(service.searchByTitle(title));
    }

    @Operation(summary = "Guardar un nuevo libro en el catálogo")
    @PostMapping
    public ResponseEntity<BookResponseDTO> saveBook(@RequestBody BookResponseDTO dto) {
        return ResponseEntity.ok(service.createBook(dto));
    }

    @Operation(summary = "Actualizar un libro existente")
    @PutMapping("/{id}")
    public ResponseEntity<BookResponseDTO> updateBook(@PathVariable Long id, @RequestBody BookResponseDTO dto) {
        return service.updateBook(id, dto)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
}
