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
    public ResponseEntity<List<Note>> getNotesByBookId(@RequestParam String bookId, @AuthenticationPrincipal User user) {
        List<Note> entries = noteRepository.findByBookIdAndUserId(bookId, user.getId());
        return ResponseEntity.ok(entries);
    }

    @PostMapping
    public ResponseEntity<Note> createNote(@RequestBody CreateNoteDto createNoteDto, @AuthenticationPrincipal User user) {
        Note note = new Note();
        note.setBookId(createNoteDto.getBookId());
        note.setQuote(createNoteDto.getQuote());
        note.setNote(createNoteDto.getNote());
        note.setPage(createNoteDto.getPage());
        note.setUser(user);

        Note savedNote = noteRepository.save(note);
        return ResponseEntity.ok(savedNote);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteNote(@PathVariable Long id, @AuthenticationPrincipal User user) {
        Note note = noteRepository.findById(id).orElse(null);
        if (note == null || !note.getUser().getId().equals(user.getId())) {
            return ResponseEntity.notFound().build();
        }
        noteRepository.delete(note);
        return ResponseEntity.noContent().build();
    }
}