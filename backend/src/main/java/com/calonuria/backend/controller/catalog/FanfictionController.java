package com.calonuria.backend.controller.catalog;

import com.calonuria.backend.dto.catalog.FanfictionRespuestaDTO;
import com.calonuria.backend.model.catalog.Fanfiction;
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

    // Añadir en FanfictionController
    @Operation(summary = "Guardar fanfic en base de datos local")
    @PostMapping
    public ResponseEntity<FanfictionRespuestaDTO> guardarFanfic(@RequestBody FanfictionRespuestaDTO dto) {
        Fanfiction fanfic = new Fanfiction();
        fanfic.setAo3Id(dto.getAo3Id());
        fanfic.setTitulo(dto.getTitulo());
        fanfic.setAutor(dto.getAutor());
        fanfic.setHistoriaBase(dto.getHistoriaBase());
        fanfic.setDescripcion(dto.getDescripcion());
        fanfic.setPortadaUrl(dto.getPortadaUrl());
        fanfic.setGenero(dto.getGenero());
        fanfic.setShipPrincipal(dto.getShipPrincipal());
        fanfic.setTematica(dto.getTematica());
        fanfic.setCapituloActual(dto.getCapituloActual());
        fanfic.setTotalCapitulos(dto.getTotalCapitulos());
        fanfic.setEstadoPublicacion(dto.getEstadoPublicacion());
        return ResponseEntity.ok(fanfictionService.guardarSiNoExiste(fanfic));
    }
}