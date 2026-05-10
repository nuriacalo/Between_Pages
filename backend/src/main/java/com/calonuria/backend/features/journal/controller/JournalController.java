package com.calonuria.backend.features.journal.controller;

import com.calonuria.backend.features.journal.dto.BookJournalRegistrationDTO;
import com.calonuria.backend.features.journal.dto.MangaJournalRegistrationDTO;
import com.calonuria.backend.features.journal.model.JournalType;
import com.calonuria.backend.features.journal.service.JournalService;
import com.calonuria.backend.features.journal.service.JournalServiceFactory;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/journal")
@Tag(name = "Journal", description = "Seguimiento de lectura")
public class JournalController {

    private final JournalServiceFactory serviceFactory;

    public JournalController(JournalServiceFactory serviceFactory) {
        this.serviceFactory = serviceFactory;
    }

    @PostMapping("/book")
    public ResponseEntity<?> saveBookProgress(@RequestBody BookJournalRegistrationDTO dto) {
        JournalService<Object, Object> service = serviceFactory.getService(JournalType.BOOK);
        return ResponseEntity.ok(service.saveProgress(dto));
    }

    @PostMapping("/manga")
    public ResponseEntity<?> saveMangaProgress(@RequestBody MangaJournalRegistrationDTO dto) {
        JournalService<Object, Object> service = serviceFactory.getService(JournalType.MANGA);
        return ResponseEntity.ok(service.saveProgress(dto));
    }

    // TODO: Add Fanfic endpoint

    @GetMapping("/{type}/user/{userId}")
    public ResponseEntity<List<?>> getUserJournal(@PathVariable JournalType type, @PathVariable Long userId) {
        JournalService<?, ?> service = serviceFactory.getService(type);
        return ResponseEntity.ok(service.getUserJournal(userId));
    }

    @GetMapping("/{type}/user/{userId}/status/{status}")
    public ResponseEntity<List<?>> getByStatus(@PathVariable JournalType type, @PathVariable Long userId, @PathVariable String status) {
        JournalService<?, ?> service = serviceFactory.getService(type);
        return ResponseEntity.ok(service.getByStatus(userId, status));
    }

    @GetMapping("/{type}/user/{userId}/rereadings")
    public ResponseEntity<List<?>> getRereadings(@PathVariable JournalType type, @PathVariable Long userId) {
        JournalService<?, ?> service = serviceFactory.getService(type);
        return ResponseEntity.ok(service.getRereadings(userId));
    }

    @DeleteMapping("/{type}/{journalId}")
    public ResponseEntity<Void> deleteJournal(@PathVariable JournalType type, @PathVariable Long journalId) {
        JournalService<?, ?> service = serviceFactory.getService(type);
        service.deleteJournal(journalId);
        return ResponseEntity.noContent().build();
    }
}
