package com.calonuria.backend.controller.catalog;

import com.calonuria.backend.dto.catalog.FanfictionRespuestaDTO;
import com.calonuria.backend.service.catalog.FanfictionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/fanfiction")
@Tag(name = "Catálogo de Fanfiction", description = "Endpoints para búsqueda y consulta de fanfictions")
public class FanfictionController {

    @Autowired
    private FanfictionService fanfictionService;

    @Operation(summary = "Buscar fanfics por título")
    @GetMapping("/buscar")
    public ResponseEntity<List<FanfictionRespuestaDTO>> buscarPorTitulo(@RequestParam("q") String titulo) {
        return ResponseEntity.ok(fanfictionService.buscarPorTitulo(titulo));
    }

    @Operation(summary = "Buscar fanfics por estado de publicación")
    @GetMapping("/estado")
    public ResponseEntity<List<FanfictionRespuestaDTO>> buscarPorEstado(@RequestParam String estado) {
        return ResponseEntity.ok(fanfictionService.buscarPorEstado(estado));
    }

    @Operation(summary = "Obtener fanfic por ID")
    @GetMapping("/{id}")
    public ResponseEntity<FanfictionRespuestaDTO> obtenerPorId(@PathVariable Long id) {
        return fanfictionService.obtenerFanficPorId(id)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
}