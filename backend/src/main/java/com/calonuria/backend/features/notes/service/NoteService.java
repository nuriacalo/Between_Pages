package com.calonuria.backend.features.notes.service;

import com.calonuria.backend.features.notes.dto.NoteRequestDTO;
import com.calonuria.backend.features.notes.dto.NoteResponseDTO;
import com.calonuria.backend.features.notes.model.Note;
import com.calonuria.backend.features.notes.repository.NoteRepository;
import com.calonuria.backend.features.user.model.User;
import com.calonuria.backend.features.user.repository.UserRepository;
import com.calonuria.backend.shared.exception.ResourceNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class NoteService {

    private final NoteRepository noteRepository;
    private final UserRepository userRepository;

    public NoteService(NoteRepository noteRepository, UserRepository userRepository) {
        this.noteRepository = noteRepository;
        this.userRepository = userRepository;
    }

    @Transactional
    public NoteResponseDTO createNote(Long userId, NoteRequestDTO dto) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Usuario no encontrado con id: " + userId));

        Note note = new Note();
        note.setUser(user);
        note.setItemType(dto.getItemType().toUpperCase());
        note.setItemId(dto.getItemId());
        note.setQuote(dto.getQuote());
        note.setNote(dto.getNote());
        note.setPage(dto.getPage());

        Note savedNote = noteRepository.save(note);
        return mapToDTO(savedNote);
    }

    @Transactional(readOnly = true)
    public List<NoteResponseDTO> getNotesByItem(Long userId, String itemType, Long itemId) {
        return noteRepository.findByItemTypeAndItemIdAndUserId(itemType.toUpperCase(), itemId, userId)
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<NoteResponseDTO> getAllUserNotes(Long userId) {
        return noteRepository.findByUserIdOrderByCreatedAtDesc(userId)
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    @Transactional
    public void deleteNote(Long noteId) {
        noteRepository.deleteById(noteId);
    }

    private NoteResponseDTO mapToDTO(Note note) {
        NoteResponseDTO dto = new NoteResponseDTO();
        dto.setId(note.getId());
        dto.setItemType(note.getItemType());
        dto.setItemId(note.getItemId());
        dto.setQuote(note.getQuote());
        dto.setNote(note.getNote());
        dto.setPage(note.getPage());
        dto.setCreatedAt(note.getCreatedAt());
        return dto;
    }
}