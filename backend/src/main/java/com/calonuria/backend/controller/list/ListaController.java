package com.calonuria.backend.controller.list;

import com.calonuria.backend.dto.list.ListaRegistroDTO;
import com.calonuria.backend.dto.list.ListaRespuestaDTO;
import com.calonuria.backend.service.list.ListaService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/lista")
@Tag(name = "Listas", description = "Gestión de listas personalizadas del usuario")
public class ListaController {

    @Autowired
    private ListaService listaService;

    @Operation(summary = "Crear una nueva lista")
    @PostMapping
    public ResponseEntity<ListaRespuestaDTO> crearLista(@Valid @RequestBody ListaRegistroDTO dto) {
        return ResponseEntity.ok(listaService.crearLista(dto));
    }

    @Operation(summary = "Obtener todas las listas de un usuario")
    @GetMapping("/usuario/{idUsuario}")
    public ResponseEntity<List<ListaRespuestaDTO>> obtenerListasDeUsuario(
            @PathVariable Long idUsuario) {
        return ResponseEntity.ok(listaService.obtenerListasDeUsuario(idUsuario));
    }

    @Operation(summary = "Eliminar una lista")
    @DeleteMapping("/{idLista}")
    public ResponseEntity<?> eliminarLista(@PathVariable Long idLista) {
        listaService.eliminarLista(idLista);
        return ResponseEntity.noContent().build();
    }
}