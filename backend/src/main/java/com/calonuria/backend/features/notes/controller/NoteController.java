package com.calonuria.backend.features.notes.controller;

import com.calonuria.backend.features.notes.dto.CreateNoteDto;
import com.calonuria.backend.features.notes.model.Note;
import com.calonuria.backend.features.notes.repository.NoteRepository;
import com.calonuria.backend.features.user.model.User;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/notes")
public class NoteController {

    private final NoteRepository noteRepository;

    public NoteController(NoteRepository noteRepository) {
        this.noteRepository = noteRepository;
    }

    @GetMapping
    public ResponseEntity<List<Note>> getNotesByItemId(
            @RequestParam String itemType,
            @RequestParam Long itemId,
            @AuthenticationPrincipal User user) {
        List<Note> notes = noteRepository.findByItemTypeAndItemIdAndUserId(itemType, itemId, user.getId());
        return ResponseEntity.ok(notes);
    }

    @PostMapping
    public ResponseEntity<Note> createNote(@RequestBody CreateNoteDto createNoteDto, @AuthenticationPrincipal User user) {
        Note note = new Note();
        note.setUser(user);
        note.setItemType(createNoteDto.getItemType());
        note.setItemId(createNoteDto.getItemId());
        note.setQuote(createNoteDto.getQuote());
        note.setNote(createNoteDto.getNote());
        note.setPage(createNoteDto.getPage());
        Note savedNote = noteRepository.save(note);
        return ResponseEntity.ok(savedNote);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteNote(@PathVariable Long id) {
        noteRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}