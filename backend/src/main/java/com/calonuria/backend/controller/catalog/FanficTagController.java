package com.calonuria.backend.controller.catalog;

import com.calonuria.backend.service.catalog.FanficTagService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/fanfiction/{idFanfic}/tags")
@Tag(name = "Fanfic Tags", description = "Gestión de tags de fanfictions")
public class FanficTagController {

    @Autowired
    private FanficTagService fanficTagService;

    @Operation(summary = "Obtener todos los tags de un fanfic")
    @GetMapping
    public ResponseEntity<List<String>> obtenerTags(@PathVariable Long idFanfic) {
        return ResponseEntity.ok(fanficTagService.obtenerTagsDeFanfic(idFanfic));
    }

    @Operation(summary = "Añadir un tag a un fanfic")
    @PostMapping
    public ResponseEntity<String> añadirTag(
            @PathVariable Long idFanfic,
            @RequestParam String tag) {
        return ResponseEntity.ok(fanficTagService.añadirTag(idFanfic, tag));
    }

    @Operation(summary = "Reemplazar todos los tags de un fanfic")
    @PutMapping
    public ResponseEntity<List<String>> actualizarTags(
            @PathVariable Long idFanfic,
            @RequestBody List<String> nuevosTags) {
        return ResponseEntity.ok(fanficTagService.actualizarTags(idFanfic, nuevosTags));
    }

    @Operation(summary = "Eliminar un tag por su ID")
    @DeleteMapping("/{idTag}")
    public ResponseEntity<?> eliminarTag(
            @PathVariable Long idFanfic,
            @PathVariable Long idTag) {
        fanficTagService.eliminarTag(idTag);
        return ResponseEntity.noContent().build();
    }

    @Operation(summary = "Buscar fanfics que tengan un tag concreto")
    @GetMapping("/buscar")
    public ResponseEntity<List<Long>> buscarPorTag(@RequestParam String tag) {
        return ResponseEntity.ok(fanficTagService.buscarFanficsPorTag(tag));
    }
}