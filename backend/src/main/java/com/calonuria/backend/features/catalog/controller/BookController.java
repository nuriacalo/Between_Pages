package com.calonuria.backend.features.catalog.controller;

import com.calonuria.backend.features.catalog.model.Book;
import com.calonuria.backend.features.catalog.service.BookService;
import com.calonuria.backend.features.search.dto.BookResponseDTO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * REST Controller that handles HTTP requests related to the Book Catalog.
 * Extends {@link BaseCatalogController} to inherit standard CRUD operations
 * while providing book-specific endpoints.
 * 
 * <p>Base path: {@code /api/book}</p>
 */
@RestController
@RequestMapping("/api/book")
@Tag(name = "Catálogo de Libros", description = "Endpoints para búsqueda y gestión de libros en la base de datos local")
public class BookController extends BaseCatalogController<Book, BookResponseDTO, Long, BookService> {

    /**
     * Constructs a new {@code BookController}.
     *
     * @param bookService the service responsible for book business logic.
     */
    public BookController(BookService bookService) {
        super(bookService);
    }

    @Operation(summary = "Obtener todos los libros del catálogo de un usuario")
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<BookResponseDTO>> getBooksByUserId(@PathVariable Long userId) {
        return ResponseEntity.ok(service.getBooksByUserId(userId));
    }

    /**
     * Searches for books in the local database by title.
     *
     * @param title the search query string (must not be empty)
     * @return a {@link ResponseEntity} containing a list of {@link BookResponseDTO} matching the query,
     *         or a 400 Bad Request if the search string is empty.
     */
    @Operation(summary = "Buscar libros en la base de datos local")
    @GetMapping("/search")
    @Override
    public ResponseEntity<List<BookResponseDTO>> searchByTitle(@RequestParam(value = "q") String title) {
        if (title.trim().isEmpty()) {
            return ResponseEntity.badRequest().build();
        }
        return ResponseEntity.ok(service.searchByTitle(title));
    }

    /**
     * Saves a new book into the local catalog.
     *
     * @param dto the payload containing book details to save
     * @return a {@link ResponseEntity} containing the saved {@link BookResponseDTO}
     */
    @Operation(summary = "Guardar un nuevo libro en el catálogo")
    @PostMapping
    public ResponseEntity<BookResponseDTO> saveBook(@RequestBody BookResponseDTO dto) {
        return ResponseEntity.ok(service.createBook(dto));
    }

    /**
     * Updates an existing book in the local catalog.
     *
     * @param id  the unique identifier of the book to update
     * @param dto the payload containing updated book details
     * @return a {@link ResponseEntity} containing the updated {@link BookResponseDTO},
     *         or 404 Not Found if the book does not exist.
     */
    @Operation(summary = "Actualizar un libro existente")
    @PutMapping("/{id}")
    public ResponseEntity<BookResponseDTO> updateBook(@PathVariable Long id, @RequestBody BookResponseDTO dto) {
        return service.updateBook(id, dto)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
}