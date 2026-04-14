package com.calonuria.backend.controller.catalog;

import com.calonuria.backend.service.catalog.FanficTagService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

/**
 * Controlador para la gestión de tags de fanfictions.
 */
@RestController
@RequestMapping("/api/fanfiction/{fanficId}/tags")
@Tag(name = "Fanfic Tags", description = "Gestión de tags de fanfictions")
public class FanficTagController {

    @Autowired
    private FanficTagService fanficTagService;

    @Operation(summary = "Obtener todos los tags de un fanfic")
    @GetMapping
    public ResponseEntity<List<String>> getTags(@PathVariable Long fanficId) {
        return ResponseEntity.ok(fanficTagService.getTagsByFanfic(fanficId));
    }

    @Operation(summary = "Añadir un tag a un fanfic")
    @PostMapping
    public ResponseEntity<String> addTag(
            @PathVariable Long fanficId,
            @RequestParam String tag) {
        return ResponseEntity.ok(fanficTagService.addTag(fanficId, tag));
    }

    @Operation(summary = "Reemplazar todos los tags de un fanfic")
    @PutMapping
    public ResponseEntity<List<String>> updateTags(
            @PathVariable Long fanficId,
            @RequestBody List<String> newTags) {
        return ResponseEntity.ok(fanficTagService.updateTags(fanficId, newTags));
    }

    @Operation(summary = "Eliminar un tag por su ID")
    @DeleteMapping("/{tagId}")
    public ResponseEntity<?> deleteTag(
            @PathVariable Long fanficId,
            @PathVariable Long tagId) {
        fanficTagService.deleteTag(tagId);
        return ResponseEntity.noContent().build();
    }

    @Operation(summary = "Buscar fanfics que tengan un tag concreto")
    @GetMapping("/search")
    public ResponseEntity<List<Long>> searchByTag(@RequestParam String tag) {
        return ResponseEntity.ok(fanficTagService.searchFanficsByTag(tag));
    }
}