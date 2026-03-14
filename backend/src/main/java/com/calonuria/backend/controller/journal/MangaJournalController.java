package com.calonuria.backend.controller.journal;

import com.calonuria.backend.dto.journal.MangaJournalRegistroDTO;
import com.calonuria.backend.dto.journal.MangaJournalRespuestaDTO;
import com.calonuria.backend.service.journal.MangaJournalService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/manga-journal")
@Tag(name = "Manga Journal", description = "Seguimiento de lectura de mangas")
public class MangaJournalController {

    @Autowired
    private MangaJournalService mangaJournalService;

    @Operation(summary = "Guardar o actualizar progreso de un manga")
    @PostMapping
    public ResponseEntity<MangaJournalRespuestaDTO> guardarProgreso(
            @Valid @RequestBody MangaJournalRegistroDTO dto) {
        return ResponseEntity.ok(mangaJournalService.guardarProgreso(dto));
    }

    @Operation(summary = "Obtener todos los journals de un usuario")
    @GetMapping("/usuario/{idUsuario}")
    public ResponseEntity<List<MangaJournalRespuestaDTO>> obtenerJournal(
            @PathVariable Long idUsuario) {
        return ResponseEntity.ok(mangaJournalService.obtenerJournalDeUsuario(idUsuario));
    }

    @Operation(summary = "Obtener journals por estado")
    @GetMapping("/usuario/{idUsuario}/estado")
    public ResponseEntity<List<MangaJournalRespuestaDTO>> obtenerPorEstado(
            @PathVariable Long idUsuario,
            @RequestParam String estado) {
        return ResponseEntity.ok(mangaJournalService.obtenerPorEstado(idUsuario, estado));
    }
}