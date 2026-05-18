package com.calonuria.backend.features.catalog.controller;

import com.calonuria.backend.features.catalog.service.FanficTagService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

/**
 * REST Controller for managing tags associated with fanfictions.
 * Allows retrieving, adding, updating, and deleting tags on specific fanfics.
 * 
 * <p>Base path: {@code /api/fanfiction/{fanficId}/tags}</p>
 */
@RestController
@RequestMapping("/api/fanfiction/{fanficId}/tags")
@Tag(name = "Fanfic Tags", description = "Gestión de tags de fanfictions")
@RequiredArgsConstructor
public class FanficTagController {

    private final FanficTagService fanficTagService;

    /**
     * Retrieves all tags associated with a specific fanfiction.
     *
     * @param fanficId the unique identifier of the fanfiction
     * @return a {@link ResponseEntity} containing a list of tag strings
     */
    @Operation(summary = "Obtener todos los tags de un fanfic")
    @GetMapping
    public ResponseEntity<List<String>> getTags(@PathVariable Long fanficId) {
        return ResponseEntity.ok(fanficTagService.getTagsByFanfic(fanficId));
    }

    /**
     * Adds a new tag to a specific fanfiction.
     *
     * @param fanficId the unique identifier of the fanfiction
     * @param tag      the tag string to add
     * @return a {@link ResponseEntity} containing the successfully added tag
     */
    @Operation(summary = "Añadir un tag a un fanfic")
    @PostMapping
    public ResponseEntity<String> addTag(
            @PathVariable Long fanficId,
            @RequestParam String tag) {
        return ResponseEntity.ok(fanficTagService.addTag(fanficId, tag));
    }

    /**
     * Replaces all existing tags for a fanfiction with a new list of tags.
     *
     * @param fanficId the unique identifier of the fanfiction
     * @param newTags  the new list of tags to associate with the fanfiction
     * @return a {@link ResponseEntity} containing the updated list of tags
     */
    @Operation(summary = "Reemplazar todos los tags de un fanfic")
    @PutMapping
    public ResponseEntity<List<String>> updateTags(
            @PathVariable Long fanficId,
            @RequestBody List<String> newTags) {
        return ResponseEntity.ok(fanficTagService.updateTags(fanficId, newTags));
    }

    /**
     * Deletes a specific tag from a fanfiction by its tag ID.
     *
     * @param fanficId the unique identifier of the fanfiction
     * @param tagId    the unique identifier of the tag
     * @return a {@link ResponseEntity} with status 204 No Content
     */
    @Operation(summary = "Eliminar un tag por su ID")
    @DeleteMapping("/{tagId}")
    public ResponseEntity<?> deleteTag(
            @PathVariable Long fanficId,
            @PathVariable Long tagId) {
        fanficTagService.deleteTag(tagId);
        return ResponseEntity.noContent().build();
    }

    /**
     * Searches for all fanfictions that contain a specific tag.
     *
     * @param fanficId the placeholder path variable (not actively used in this endpoint context)
     * @param tag      the tag to search for across all fanfictions
     * @return a {@link ResponseEntity} containing a list of fanfiction IDs matching the tag
     */
    @Operation(summary = "Buscar fanfics que tengan un tag concreto")
    @GetMapping("/search")
    public ResponseEntity<List<Long>> searchByTag(
            @PathVariable(required = false) Long fanficId, 
            @RequestParam String tag) {
        return ResponseEntity.ok(fanficTagService.searchFanficsByTag(tag));
    }
}
