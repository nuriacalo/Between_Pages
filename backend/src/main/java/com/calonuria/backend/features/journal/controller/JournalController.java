package com.calonuria.backend.features.journal.controller;

import com.calonuria.backend.features.journal.dto.BookJournalRegistrationDTO;
import com.calonuria.backend.features.journal.dto.FanficJournalRegistrationDTO;
import com.calonuria.backend.features.journal.dto.MangaJournalRegistrationDTO;
import com.calonuria.backend.features.journal.model.JournalType;
import com.calonuria.backend.features.journal.service.JournalService;
import com.calonuria.backend.features.journal.service.JournalServiceFactory;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * REST Controller for managing user reading journals.
 * Provides endpoints to record reading progress, status changes, ratings, 
 * and fetch reading histories for books, mangas, and fanfictions.
 * Uses a {@link JournalServiceFactory} to delegate logic to the appropriate service type.
 * 
 * <p>Base path: {@code /api/journal}</p>
 */
@RestController
@RequestMapping("/api/journal")
@Tag(name = "Journal", description = "Seguimiento de lectura")
public class JournalController {

    private final JournalServiceFactory serviceFactory;

    /**
     * Constructs a new {@code JournalController}.
     *
     * @param serviceFactory the factory used to obtain the appropriate journal service
     */
    public JournalController(JournalServiceFactory serviceFactory) {
        this.serviceFactory = serviceFactory;
    }

    /**
     * Saves or updates reading progress for a book.
     *
     * @param dto the payload containing the book progress data
     * @return a {@link ResponseEntity} containing the saved record
     */
    @Operation(summary = "Guardar progreso de libro", description = "Crea o actualiza el diario de lectura de un libro")
    @PostMapping("/book")
    public ResponseEntity<?> saveBookProgress(@RequestBody BookJournalRegistrationDTO dto) {
        JournalService<Object, Object> service = serviceFactory.getService(JournalType.BOOK);
        return ResponseEntity.ok(service.saveProgress(dto));
    }

    /**
     * Saves or updates reading progress for a manga.
     *
     * @param dto the payload containing the manga progress data
     * @return a {@link ResponseEntity} containing the saved record
     */
    @Operation(summary = "Guardar progreso de manga", description = "Crea o actualiza el diario de lectura de un manga")
    @PostMapping("/manga")
    public ResponseEntity<?> saveMangaProgress(@RequestBody MangaJournalRegistrationDTO dto) {
        JournalService<Object, Object> service = serviceFactory.getService(JournalType.MANGA);
        return ResponseEntity.ok(service.saveProgress(dto));
    }

    /**
     * Saves or updates reading progress for a fanfiction.
     *
     * @param dto the payload containing the fanfic progress data
     * @return a {@link ResponseEntity} containing the saved record
     */
    @Operation(summary = "Guardar progreso de fanfic", description = "Crea o actualiza el diario de lectura de un fanfic")
    @PostMapping("/fanfic")
    public ResponseEntity<?> saveFanficProgress(@RequestBody FanficJournalRegistrationDTO dto) {
        JournalService<Object, Object> service = serviceFactory.getService(JournalType.FANFIC);
        return ResponseEntity.ok(service.saveProgress(dto));
    }

    /**
     * Retrieves the entire journal history of a specific media type for a given user.
     *
     * @param type   the type of journal to fetch (BOOK, MANGA, FANFIC)
     * @param userId the user's ID
     * @return a {@link ResponseEntity} containing a list of journal entries
     */
    @Operation(summary = "Obtener diario por tipo", description = "Obtiene todos los registros de un usuario para un tipo específico (BOOK, MANGA, FANFIC)")
    @GetMapping("/{type}/user/{userId}")
    public ResponseEntity<List<?>> getUserJournal(@PathVariable JournalType type, @PathVariable Long userId) {
        JournalService<?, ?> service = serviceFactory.getService(type);
        return ResponseEntity.ok(service.getUserJournal(userId));
    }

    /**
     * Retrieves journal entries filtered by their current reading status.
     *
     * @param type   the type of journal to fetch
     * @param userId the user's ID
     * @param status the status string (e.g., 'READING', 'FINISHED')
     * @return a {@link ResponseEntity} containing a list of matching journal entries
     */
    @Operation(summary = "Obtener diario por estado", description = "Filtra el diario del usuario según un estado (ej. READING, FINISHED)")
    @GetMapping("/{type}/user/{userId}/status")
    public ResponseEntity<List<?>> getByStatus(@PathVariable JournalType type, @PathVariable Long userId, @RequestParam String status) {
        JournalService<?, ?> service = serviceFactory.getService(type);
        return ResponseEntity.ok(service.getByStatus(userId, status));
    }

    /**
     * Retrieves journal entries marked specifically as rereadings.
     *
     * @param type   the type of journal to fetch
     * @param userId the user's ID
     * @return a {@link ResponseEntity} containing a list of journal entries marked as reread
     */
    @Operation(summary = "Obtener relecturas", description = "Devuelve los libros/mangas/fanfics que el usuario está releyendo")
    @GetMapping("/{type}/user/{userId}/rereadings")
    public ResponseEntity<List<?>> getRereadings(@PathVariable JournalType type, @PathVariable Long userId) {
        JournalService<?, ?> service = serviceFactory.getService(type);
        return ResponseEntity.ok(service.getRereadings(userId));
    }

    /**
     * Deletes a specific journal entry by its ID.
     *
     * @param type      the type of the journal
     * @param journalId the ID of the journal entry
     * @return a {@link ResponseEntity} with status 204 No Content
     */
    @Operation(summary = "Eliminar registro", description = "Elimina un registro específico del diario de lectura")
    @DeleteMapping("/{type}/{journalId}")
    public ResponseEntity<Void> deleteJournal(@PathVariable JournalType type, @PathVariable Long journalId) {
        JournalService<?, ?> service = serviceFactory.getService(type);
        service.deleteJournal(journalId);
        return ResponseEntity.noContent().build();
    }
}
