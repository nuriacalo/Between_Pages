package com.calonuria.backend.features.notes.controller;

import com.calonuria.backend.features.notes.dto.NoteRequestDTO;
import com.calonuria.backend.features.notes.dto.NoteResponseDTO;
import com.calonuria.backend.features.notes.service.NoteService;
import com.calonuria.backend.features.user.model.User;
import com.calonuria.backend.features.user.repository.UserRepository;
import org.springframework.security.core.Authentication;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/notes")
public class NoteController {

    private final NoteService noteService;
    private final UserRepository userRepository;

    public NoteController(NoteService noteService, UserRepository userRepository) {
        this.noteService = noteService;
        this.userRepository = userRepository;
    }

    private Long getUserId(Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return null;
        }
        // Extraemos el email del token
        String email = authentication.getName(); 
        // Buscamos al usuario en la BD para obtener su ID
        return userRepository.findByEmail(email)
                .map(User::getId)
                .orElse(null);
    }

    @PostMapping
    public ResponseEntity<NoteResponseDTO> createNote(
            Authentication authentication, 
            @RequestBody NoteRequestDTO requestDTO) {
        Long userId = getUserId(authentication);
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        NoteResponseDTO createdNote = noteService.createNote(userId, requestDTO);
        return new ResponseEntity<>(createdNote, HttpStatus.CREATED);
    }

    @GetMapping
    public ResponseEntity<List<NoteResponseDTO>> getNotes(
            Authentication authentication,
            @RequestParam String itemType,
            @RequestParam Long itemId) {
        Long userId = getUserId(authentication);
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        List<NoteResponseDTO> notes = noteService.getNotesByItem(userId, itemType, itemId);
        return ResponseEntity.ok(notes);
    }

    @GetMapping("/all")
    public ResponseEntity<List<NoteResponseDTO>> getAllNotes(
            Authentication authentication) {
        Long userId = getUserId(authentication);
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        List<NoteResponseDTO> notes = noteService.getAllUserNotes(userId);
        return ResponseEntity.ok(notes);
    }

    @DeleteMapping("/{noteId}")
    public ResponseEntity<Void> deleteNote(@PathVariable Long noteId) {
        noteService.deleteNote(noteId);
        return ResponseEntity.noContent().build();
    }
}