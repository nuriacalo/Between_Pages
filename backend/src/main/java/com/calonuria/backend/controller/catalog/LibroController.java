package com.calonuria.backend.controller.catalog;

import com.calonuria.backend.dto.catalog.LibroRespuestaDTO;
import com.calonuria.backend.service.catalog.LibroService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/libro")
@Tag(name = "Catálogo de Libros", description = "Endpoints para búsqueda en Google Books y base de datos local")
public class LibroController {

    @Autowired
    private LibroService libroService;

    @Operation(summary = "Buscar libros en Google Books")
    @GetMapping("/buscar")
    public ResponseEntity<List<LibroRespuestaDTO>> buscarEnGoogleBooks(@RequestParam("q") String titulo) {
        return ResponseEntity.ok(libroService.buscarEnGoogleBooks(titulo));
    }

    @Operation(summary = "Buscar libros en base de datos local")
    @GetMapping("/buscar/local")
    public ResponseEntity<List<LibroRespuestaDTO>> buscarEnBD(@RequestParam("q") String titulo) {
        return ResponseEntity.ok(libroService.buscarEnBD(titulo));
    }

    @Operation(summary = "Obtener libro por ID")
    @GetMapping("/{id}")
    public ResponseEntity<LibroRespuestaDTO> obtenerPorId(@PathVariable Long id) {
        return libroService.obtenerLibroPorId(id)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
}