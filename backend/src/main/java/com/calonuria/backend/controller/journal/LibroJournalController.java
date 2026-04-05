package com.calonuria.backend.controller.journal;

import com.calonuria.backend.dto.journal.LibroJournalRegistroDTO;
import com.calonuria.backend.dto.journal.LibroJournalRespuestaDTO;
import com.calonuria.backend.service.journal.LibroJournalService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/libro-journal")
@Tag(name = "Libro Journal", description = "Seguimiento de lectura de libros")
public class LibroJournalController {

    @Autowired
    private LibroJournalService libroJournalService;

    @Operation(summary = "Guardar o actualizar progreso de un libro")
    @PostMapping
    public ResponseEntity<LibroJournalRespuestaDTO> guardarProgreso(
            @Valid @RequestBody LibroJournalRegistroDTO dto) {
        return ResponseEntity.ok(libroJournalService.guardarProgreso(dto));
    }

    @Operation(summary = "Obtener todos los journals de un usuario")
    @GetMapping("/usuario/{idUsuario}")
    public ResponseEntity<List<LibroJournalRespuestaDTO>> obtenerJournal(
            @PathVariable Long idUsuario) {
        return ResponseEntity.ok(libroJournalService.obtenerJournalDeUsuario(idUsuario));
    }

    @Operation(summary = "Obtener journals por estado")
    @GetMapping("/usuario/{idUsuario}/estado")
    public ResponseEntity<List<LibroJournalRespuestaDTO>> obtenerPorEstado(
            @PathVariable Long idUsuario,
            @RequestParam String estado) {
        return ResponseEntity.ok(libroJournalService.obtenerPorEstado(idUsuario, estado));
    }

    @Operation(summary = "Obtener relecturas del usuario")
    @GetMapping("/usuario/{idUsuario}/relecturas")
    public ResponseEntity<List<LibroJournalRespuestaDTO>> obtenerRelecturas(
            @PathVariable Long idUsuario) {
        return ResponseEntity.ok(libroJournalService.obtenerRelecturas(idUsuario));
    }

    @Operation(summary = "Eliminar un registro de journal")
    @DeleteMapping("/{idJournal}")
    public ResponseEntity<?> eliminarJournal(@PathVariable Long idJournal) {
        libroJournalService.eliminarJournal(idJournal);
        return ResponseEntity.noContent().build();
    }
}
