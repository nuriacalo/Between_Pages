package com.calonuria.backend.controller.journal;

import com.calonuria.backend.dto.journal.FanficJournalRegistroDTO;
import com.calonuria.backend.dto.journal.FanficJournalRespuestaDTO;
import com.calonuria.backend.service.journal.FanficJournalService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/fanfic-journal")
@Tag(name = "Fanfic Journal", description = "Seguimiento de lectura de fanfictions")
public class FanficJournalController {

    @Autowired
    private FanficJournalService fanficJournalService;

    @Operation(summary = "Guardar o actualizar progreso de un fanfic")
    @PostMapping
    public ResponseEntity<FanficJournalRespuestaDTO> guardarProgreso(
            @Valid @RequestBody FanficJournalRegistroDTO dto) {
        return ResponseEntity.ok(fanficJournalService.guardarProgreso(dto));
    }

    @Operation(summary = "Obtener todos los journals de un usuario")
    @GetMapping("/usuario/{idUsuario}")
    public ResponseEntity<List<FanficJournalRespuestaDTO>> obtenerJournal(
            @PathVariable Long idUsuario) {
        return ResponseEntity.ok(fanficJournalService.obtenerJournalDeUsuario(idUsuario));
    }

    @Operation(summary = "Obtener journals por estado")
    @GetMapping("/usuario/{idUsuario}/estado")
    public ResponseEntity<List<FanficJournalRespuestaDTO>> obtenerPorEstado(
            @PathVariable Long idUsuario,
            @RequestParam String estado) {
        return ResponseEntity.ok(fanficJournalService.obtenerPorEstado(idUsuario, estado));
    }

    @Operation(summary = "Obtener relelecturas del usuario")
    @GetMapping("/usuario/{idUsuario}/relecturas")
    public ResponseEntity<List<FanficJournalRespuestaDTO>> obtenerRelecturas(
            @PathVariable Long idUsuario) {
        return ResponseEntity.ok(fanficJournalService.obtenerRelecturas(idUsuario));
    }
}