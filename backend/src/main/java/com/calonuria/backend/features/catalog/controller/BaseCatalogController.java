package com.calonuria.backend.features.catalog.controller;

import com.calonuria.backend.shared.service.BaseCatalogService;
import io.swagger.v3.oas.annotations.Operation;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

/**
 * Abstract base REST controller providing standard read operations for catalog entities.
 * Designed to be extended by specific catalog controllers (e.g., Book, Manga, Fanfiction).
 *
 * @param <T>  the persistent entity type (e.g., Book)
 * @param <D>  the data transfer object type used for responses (e.g., BookResponseDTO)
 * @param <ID> the type of the primary key for the entity (e.g., Long)
 * @param <S>  the corresponding service extending {@link BaseCatalogService}
 */
public abstract class BaseCatalogController<
        T, // Entity Type
        D, // DTO Type
        ID, // ID Type
        S extends BaseCatalogService<T, D, ID>> {

    /**
     * The business logic service layer associated with this controller.
     */
    protected final S service;

    /**
     * Constructs a new base controller with the given service.
     *
     * @param service the service implementing catalog business logic
     */
    protected BaseCatalogController(S service) {
        this.service = service;
    }

    /**
     * Retrieves all items currently stored in the catalog.
     *
     * @return a {@link ResponseEntity} containing a list of all items mapped to their DTOs
     */
    @Operation(summary = "Obtener todos los items del catálogo")
    @GetMapping
    public ResponseEntity<List<D>> getAll() {
        return ResponseEntity.ok(service.findAll());
    }

    /**
     * Retrieves a single catalog item by its unique identifier.
     *
     * @param id the unique identifier of the item
     * @return a {@link ResponseEntity} containing the item DTO if found, or 404 Not Found otherwise
     */
    @Operation(summary = "Obtener un item por su ID")
    @GetMapping("/{id}")
    public ResponseEntity<D> getById(@PathVariable ID id) {
        return service.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    /**
     * Searches for catalog items whose titles match the given query string.
     *
     * @param title the search query string
     * @return a {@link ResponseEntity} containing a list of matching items
     */
    @Operation(summary = "Buscar items por título")
    @GetMapping("/search")
    public ResponseEntity<List<D>> searchByTitle(@RequestParam String title) {
        return ResponseEntity.ok(service.searchByTitle(title));
    }
}
