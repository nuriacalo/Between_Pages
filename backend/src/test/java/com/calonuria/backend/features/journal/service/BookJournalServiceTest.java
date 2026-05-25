package com.calonuria.backend.features.journal.service;

import com.calonuria.backend.features.catalog.model.Book;
import com.calonuria.backend.features.catalog.service.BookService;
import com.calonuria.backend.features.journal.dto.BookJournalRegistrationDTO;
import com.calonuria.backend.features.journal.dto.BookJournalResponseDTO;
import com.calonuria.backend.features.journal.model.BookJournal;
import com.calonuria.backend.features.journal.repository.BookJournalRepository;
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

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class BookJournalServiceTest {

    @Mock
    private BookJournalRepository bookJournalRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private BookService bookService;

    @InjectMocks
    private BookJournalService bookJournalService;

    private User mockUser;
    private Book mockBook;
    private BookJournalRegistrationDTO mockDto;

    @BeforeEach
    void setUp() {
        // Configuramos objetos básicos que usaremos en varios tests
        mockUser = new User();
        mockUser.setId(1L);

        mockBook = new Book();
        mockBook.setId(1L);

        mockDto = new BookJournalRegistrationDTO();
        mockDto.setUserId(1L);
        mockDto.setBookId(1L);
        mockDto.setGoogleBooksId("vol123");
        mockDto.setStatus("READING");
        mockDto.setCurrentPage(50);
        mockDto.setRating(4);
    }

    @Nested
    @DisplayName("Tests para saveProgress()")
    class SaveProgressTests {

        @Test
        @DisplayName("Debería crear un nuevo Journal si no existe uno previo")
        void shouldCreateNewJournalWhenNoneExists() {
            // Arrange
            when(userRepository.findById(mockDto.getUserId())).thenReturn(Optional.of(mockUser));
            when(bookService.findOrCreateBook(mockDto.getBookId(), mockDto.getGoogleBooksId())).thenReturn(mockBook);
            // Simulamos que el repositorio no encuentra un journal existente
            when(bookJournalRepository.findByUserAndBook(mockUser, mockBook)).thenReturn(Optional.empty());
            
            // Cuando se guarde el nuevo journal, devolvemos uno con ID generado y los datos configurados
            when(bookJournalRepository.save(any(BookJournal.class))).thenAnswer(invocation -> {
                BookJournal savedJournal = invocation.getArgument(0);
                savedJournal.setId(100L); // Simulamos ID generado por BD
                return savedJournal;
            });

            // Act
            BookJournalResponseDTO result = bookJournalService.saveProgress(mockDto);

            // Assert
            assertNotNull(result);
            assertEquals(100L, result.getId());
            assertEquals(mockUser.getId(), result.getUserId());
            assertEquals("READING", result.getStatus());
            assertEquals(50, result.getCurrentPage());
            assertEquals(4, result.getRating());

            // Verificamos interacciones
            verify(userRepository).findById(mockUser.getId());
            verify(bookService).findOrCreateBook(mockBook.getId(), "vol123");
            verify(bookJournalRepository).findByUserAndBook(mockUser, mockBook);
            verify(bookJournalRepository).save(any(BookJournal.class));
            verify(bookService).mapToDTO(mockBook); // Porque se llama en el mapToDTO del journal
        }

        @Test
        @DisplayName("Debería actualizar el Journal si ya existe uno previo")
        void shouldUpdateJournalWhenAlreadyExists() {
            // Arrange
            BookJournal existingJournal = new BookJournal();
            existingJournal.setId(100L);
            existingJournal.setUser(mockUser);
            existingJournal.setBook(mockBook);
            existingJournal.setStatus("TBR");
            existingJournal.setCurrentPage(0);

            when(userRepository.findById(mockDto.getUserId())).thenReturn(Optional.of(mockUser));
            when(bookService.findOrCreateBook(mockDto.getBookId(), mockDto.getGoogleBooksId())).thenReturn(mockBook);
            // Simulamos que el repositorio SÍ encuentra un journal existente
            when(bookJournalRepository.findByUserAndBook(mockUser, mockBook)).thenReturn(Optional.of(existingJournal));
            
            // Simplemente devolvemos el mismo journal al guardar
            when(bookJournalRepository.save(any(BookJournal.class))).thenAnswer(invocation -> invocation.getArgument(0));

            // Act
            BookJournalResponseDTO result = bookJournalService.saveProgress(mockDto);

            // Assert
            assertNotNull(result);
            assertEquals(100L, result.getId()); // Mantiene el mismo ID
            assertEquals("READING", result.getStatus()); // El estado se actualizó
            assertEquals(50, result.getCurrentPage()); // La página se actualizó

            verify(bookJournalRepository).save(existingJournal);
        }

        @Test
        @DisplayName("Debería lanzar ResourceNotFoundException si el usuario no existe")
        void shouldThrowExceptionWhenUserNotFound() {
            // Arrange
            when(userRepository.findById(mockDto.getUserId())).thenReturn(Optional.empty());

            // Act & Assert
            ResourceNotFoundException exception = assertThrows(ResourceNotFoundException.class, () -> {
                bookJournalService.saveProgress(mockDto);
            });

            assertEquals("Usuario no encontrado con id: " + mockDto.getUserId(), exception.getMessage());
            
            // Verificamos que no se intentó buscar el libro ni guardar nada
            verify(bookService, never()).findOrCreateBook(any(), any());
            verify(bookJournalRepository, never()).save(any());
        }
    }
}