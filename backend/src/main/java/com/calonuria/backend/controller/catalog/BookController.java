package com.calonuria.backend.controller.catalog;

import com.calonuria.backend.dto.catalog.BookResponseDTO;
import com.calonuria.backend.model.catalog.Book;
import com.calonuria.backend.service.catalog.BookService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

/**
 * Controlador para la gestión del catálogo de libros.
 */
@RestController
@RequestMapping("/api/book")
@Tag(name = "Catálogo de Libros", description = "Endpoints para búsqueda en Google Books y base de datos local")
public class BookController {

    @Autowired
    private BookService bookService;

    @Operation(summary = "Buscar libros en Google Books")
    @GetMapping("/search")
    public ResponseEntity<List<BookResponseDTO>> searchInGoogleBooks(@RequestParam(value = "q", required = false) String title) {
        if (title == null || title.trim().isEmpty()) {
            return ResponseEntity.badRequest().build();
        }
        return ResponseEntity.ok(bookService.searchInGoogleBooks(title));
    }

    @Operation(summary = "Buscar libros en base de datos local")
    @GetMapping("/search/local")
    public ResponseEntity<List<BookResponseDTO>> searchInDatabase(@RequestParam(value = "q", required = false) String title) {
        if (title == null || title.trim().isEmpty()) {
            return ResponseEntity.badRequest().build();
        }
        return ResponseEntity.ok(bookService.searchInDatabase(title));
    }

    @Operation(summary = "Obtener libro por ID")
    @GetMapping("/{id}")
    public ResponseEntity<BookResponseDTO> getById(@PathVariable Long id) {
        return bookService.getBookById(id)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @Operation(summary = "Obtener todos los libros de la base de datos")
    @GetMapping
    public ResponseEntity<List<BookResponseDTO>> getAll() {
        return ResponseEntity.ok(bookService.getAllBooks());
    }

    @Operation(summary = "Guardar libro en base de datos local")
    @PostMapping
    public ResponseEntity<BookResponseDTO> saveBook(@RequestBody BookResponseDTO dto) {
        Book book = new Book();
        book.setGoogleBooksId(dto.getGoogleBooksId());
        book.setTitle(dto.getTitle());
        book.setAuthor(dto.getAuthor());
        book.setIsbn(dto.getIsbn());
        book.setPublisher(dto.getPublisher());
        book.setDescription(dto.getDescription());
        book.setCoverUrl(dto.getCoverUrl());
        book.setGenre(dto.getGenre());
        book.setBookType(dto.getBookType());
        book.setPublicationYear(dto.getPublicationYear());
        return ResponseEntity.ok(bookService.saveIfNotExists(book));
    }
}
