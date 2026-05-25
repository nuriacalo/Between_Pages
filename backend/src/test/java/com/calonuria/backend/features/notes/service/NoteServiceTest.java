package com.calonuria.backend.features.notes.service;

import com.calonuria.backend.features.notes.dto.NoteRequestDTO;
import com.calonuria.backend.features.notes.dto.NoteResponseDTO;
import com.calonuria.backend.features.notes.model.Note;
import com.calonuria.backend.features.notes.repository.NoteRepository;
import com.calonuria.backend.features.user.model.User;
import com.calonuria.backend.features.user.repository.UserRepository;
import com.calonuria.backend.shared.exception.ResourceNotFoundException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Collections;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class NoteServiceTest {

    @Mock
    private NoteRepository noteRepository;

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private NoteService noteService;

    private User mockUser;
    private NoteRequestDTO mockDto;
    private Note mockNote;

    @BeforeEach
    void setUp() {
        mockUser = new User();
        mockUser.setId(1L);

        mockDto = new NoteRequestDTO();
        mockDto.setItemType("BOOK");
        mockDto.setItemId(10L);
        mockDto.setQuote("This is a quote.");
        mockDto.setNote("This is a note.");
        mockDto.setPage(123);

        mockNote = new Note();
        mockNote.setId(100L);
        mockNote.setUser(mockUser);
        mockNote.setItemType("BOOK");
        mockNote.setItemId(10L);
        mockNote.setQuote("This is a quote.");
        mockNote.setNote("This is a note.");
        mockNote.setPage(123);
    }

    @Nested
    @DisplayName("Tests for createNote()")
    class CreateNoteTests {

        @Test
        @DisplayName("Should create a new note when user exists")
        void shouldCreateNewNoteWhenUserExists() {
            // Arrange
            when(userRepository.findById(mockUser.getId())).thenReturn(Optional.of(mockUser));
            when(noteRepository.save(any(Note.class))).thenAnswer(invocation -> {
                Note savedNote = invocation.getArgument(0);
                savedNote.setId(100L);
                return savedNote;
            });

            // Act
            NoteResponseDTO result = noteService.createNote(mockUser.getId(), mockDto);

            // Assert
            assertNotNull(result);
            assertEquals(100L, result.getId());
            assertEquals("BOOK", result.getItemType());
            assertEquals(10L, result.getItemId());
            assertEquals("This is a quote.", result.getQuote());
            assertEquals("This is a note.", result.getNote());
            assertEquals(123, result.getPage());

            verify(userRepository).findById(mockUser.getId());
            verify(noteRepository).save(any(Note.class));
        }

        @Test
        @DisplayName("Should throw ResourceNotFoundException if user does not exist")
        void shouldThrowExceptionWhenUserNotFound() {
            // Arrange
            Long nonExistentUserId = 99L;
            when(userRepository.findById(nonExistentUserId)).thenReturn(Optional.empty());

            // Act & Assert
            ResourceNotFoundException exception = assertThrows(ResourceNotFoundException.class, () -> {
                noteService.createNote(nonExistentUserId, mockDto);
            });

            assertEquals("Usuario no encontrado con id: " + nonExistentUserId, exception.getMessage());
            verify(noteRepository, never()).save(any());
        }

        @Test
        @DisplayName("Should save itemType in uppercase")
        void shouldSaveItemTypeInUppercase() {
            // Arrange
            mockDto.setItemType("book"); // lowercase
            when(userRepository.findById(mockUser.getId())).thenReturn(Optional.of(mockUser));
            when(noteRepository.save(any(Note.class))).thenAnswer(invocation -> invocation.getArgument(0));

            // Act
            NoteResponseDTO result = noteService.createNote(mockUser.getId(), mockDto);

            // Assert
            assertEquals("BOOK", result.getItemType());
        }
    }

    @Nested
    @DisplayName("Tests for getNotesByItem()")
    class GetNotesByItemTests {

        @Test
        @DisplayName("Should return a list of notes for a given item and user")
        void shouldReturnListOfNotes() {
            // Arrange
            when(noteRepository.findByItemTypeAndItemIdAndUserId("BOOK", 10L, 1L))
                    .thenReturn(Collections.singletonList(mockNote));

            // Act
            List<NoteResponseDTO> result = noteService.getNotesByItem(1L, "book", 10L);

            // Assert
            assertFalse(result.isEmpty());
            assertEquals(1, result.size());
            assertEquals(100L, result.get(0).getId());
            verify(noteRepository).findByItemTypeAndItemIdAndUserId("BOOK", 10L, 1L);
        }
    }

    @Nested
    @DisplayName("Tests for getAllUserNotes()")
    class GetAllUserNotesTests {

        @Test
        @DisplayName("Should return all notes for a given user")
        void shouldReturnAllUserNotes() {
            // Arrange
            when(noteRepository.findByUserIdOrderByCreatedAtDesc(1L))
                    .thenReturn(Collections.singletonList(mockNote));

            // Act
            List<NoteResponseDTO> result = noteService.getAllUserNotes(1L);

            // Assert
            assertFalse(result.isEmpty());
            assertEquals(1, result.size());
            verify(noteRepository).findByUserIdOrderByCreatedAtDesc(1L);
        }
    }

    @Nested
    @DisplayName("Tests for deleteNote()")
    class DeleteNoteTests {

        @Test
        @DisplayName("Should call deleteById on repository")
        void shouldCallDeleteById() {
            // Arrange
            Long noteId = 100L;
            doNothing().when(noteRepository).deleteById(noteId);

            // Act
            noteService.deleteNote(noteId);

            // Assert
            verify(noteRepository, times(1)).deleteById(noteId);
        }
    }
}