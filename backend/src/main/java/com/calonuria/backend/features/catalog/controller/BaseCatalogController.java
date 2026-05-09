package com.calonuria.backend.features.catalog.controller;

import com.calonuria.backend.shared.service.BaseCatalogService;
import io.swagger.v3.oas.annotations.Operation;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

public abstract class BaseCatalogController<
        T, // Entity Type
        D, // DTO Type
        ID, // ID Type
        S extends BaseCatalogService<T, D, ID>> {

    protected final S service;

    protected BaseCatalogController(S service) {
        this.service = service;
    }

    @Operation(summary = "Obtener todos los items del catálogo")
    @GetMapping
    public ResponseEntity<List<D>> getAll() {
        return ResponseEntity.ok(service.findAll());
    }

    @Operation(summary = "Obtener un item por su ID")
    @GetMapping("/{id}")
    public ResponseEntity<D> getById(@PathVariable ID id) {
        return service.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @Operation(summary = "Buscar items por título")
    @GetMapping("/search")
    public ResponseEntity<List<D>> searchByTitle(@RequestParam String title) {
        return ResponseEntity.ok(service.searchByTitle(title));
    }
}
