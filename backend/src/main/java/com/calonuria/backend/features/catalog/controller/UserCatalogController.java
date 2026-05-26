package com.calonuria.backend.features.catalog.controller;

import com.calonuria.backend.features.catalog.dto.UserCatalogEntryDTO;
import com.calonuria.backend.features.catalog.service.UserCatalogService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/catalog/user")
@RequiredArgsConstructor
@Tag(name = "Catálogo de Usuario", description = "Endpoints para gestionar el catálogo personal de cada usuario")
public class UserCatalogController {

    private final UserCatalogService userCatalogService;

    @Operation(summary = "Añadir un item al catálogo de un usuario")
    @PostMapping
    public ResponseEntity<?> addToCatalog(@Valid @RequestBody UserCatalogEntryDTO dto) {
        try {
            userCatalogService.addToCatalog(dto);
            return ResponseEntity.status(HttpStatus.CREATED).build();
        } catch (IllegalStateException e) {
            // El item ya existe, devolvemos un 200 OK en lugar de un error
            return ResponseEntity.ok().body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}
