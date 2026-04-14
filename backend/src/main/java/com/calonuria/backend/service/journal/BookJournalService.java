package com.calonuria.backend.service.journal;

import com.calonuria.backend.dto.journal.BookJournalRegistrationDTO;
import com.calonuria.backend.dto.journal.BookJournalResponseDTO;
import com.calonuria.backend.model.catalog.Book;
import com.calonuria.backend.model.journal.BookJournal;
import com.calonuria.backend.model.user.User;
import com.calonuria.backend.repository.catalog.BookRepository;
import com.calonuria.backend.repository.journal.BookJournalRepository;
import com.calonuria.backend.repository.user.UserRepository;
import com.calonuria.backend.service.catalog.BookService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Servicio para la gestión del diario de lectura de libros.
 */
@Service
public class BookJournalService {

    @Autowired
    private BookJournalRepository bookJournalRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private BookRepository bookRepository;

    @Autowired
    private BookService bookService;

    /**
     * Guarda el progreso de lectura de un libro.
     * @param dto datos del progreso
     * @return DTO con la información guardada
     */
    public BookJournalResponseDTO saveProgress(BookJournalRegistrationDTO dto) {
        User user = userRepository.findById(dto.getUserId())
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        Book book;

        // Si el DTO trae un bookId, buscamos por ese ID en la base de datos
        if (dto.getBookId() != null) {
            book = bookRepository.findById(dto.getBookId())
                    .orElseThrow(() -> new RuntimeException("Libro no encontrado con id: " + dto.getBookId()));
        } else if (dto.getGoogleBooksId() != null) {
            // Si trae googleBooksId (pero no bookId), lo buscamos o lo creamos
            Optional<Book> existing = bookRepository.findByGoogleBooksId(dto.getGoogleBooksId());
            if (existing.isPresent()) {
                book = existing.get();
            } else {
                // El libro es nuevo, lo registramos en el catálogo antes de agregarlo al Journal
                Book newBook = new Book();
                newBook.setGoogleBooksId(dto.getGoogleBooksId());
                // Validar campos obligatorios que vienen del Google Books (o valores por defecto si vienen nulos)
                newBook.setTitle(dto.getTitle() != null ? dto.getTitle() : "Título Desconocido");
                newBook.setAuthor(dto.getAuthor() != null ? dto.getAuthor() : "Autor Desconocido");
                newBook.setIsbn(dto.getIsbn());
                newBook.setPublisher(dto.getPublisher());
                newBook.setDescription(dto.getDescription());
                newBook.setCoverUrl(dto.getCoverUrl());
                newBook.setGenre(dto.getGenre());
                // El constraint en la DB exige valores específicos para book_type (Standalone, Saga, Series) o null
                newBook.setBookType(dto.getBookType() != null ? dto.getBookType() : "Standalone");
                newBook.setPublicationYear(dto.getPublicationYear());

                book = bookRepository.save(newBook);
            }
        } else {
            throw new RuntimeException("Debe proporcionar un bookId o un googleBooksId");
        }

        // Ahora buscamos si el usuario ya tiene este libro en su journal
        BookJournal journal = bookJournalRepository.findByUserAndBook(user, book)
                .orElse(new BookJournal());

        if (journal.getId() == null) {
            journal.setUser(user);
            journal.setBook(book);
        }

        journal.setStatus(dto.getStatus());
        journal.setCurrentPage(dto.getCurrentPage());
        journal.setRating(dto.getRating());
        journal.setReadingFormat(dto.getReadingFormat());
        journal.setEmotions(dto.getEmotions());
        journal.setFavoriteQuotes(dto.getFavoriteQuotes());
        journal.setPersonalNotes(dto.getPersonalNotes());
        journal.setStartDate(dto.getStartDate());
        journal.setEndDate(dto.getEndDate());
        journal.setRereading(dto.getRereading());

        BookJournal saved = bookJournalRepository.save(journal);
        return mapToDTO(saved);
    }

    /**
     * Obtiene el journal de un usuario.
     * @param userId ID del usuario
     * @return lista de entradas del journal
     */
    @Transactional(readOnly = true)
    public List<BookJournalResponseDTO> getUserJournal(Long userId) {
        return bookJournalRepository.findByUserId(userId)
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    /**
     * Obtiene entradas del journal filtradas por estado.
     * @param userId ID del usuario
     * @param status estado de lectura
     * @return lista de entradas filtradas
     */
    public List<BookJournalResponseDTO> getByStatus(Long userId, String status) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        return bookJournalRepository.findByUserAndStatus(user, status)
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    /**
     * Obtiene las relecturas de un usuario.
     * @param userId ID del usuario
     * @return lista de relecturas
     */
    public List<BookJournalResponseDTO> getRereadings(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        return bookJournalRepository.findByUserAndRereadingTrue(user)
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    /**
     * Elimina una entrada del journal.
     * @param journalId ID de la entrada
     */
    public void deleteJournal(Long journalId) {
        bookJournalRepository.deleteById(journalId);
    }

    /**
     * Mapea una entrada del journal a su DTO de respuesta.
     * @param journal entrada del journal
     * @return DTO de respuesta
     */
    private BookJournalResponseDTO mapToDTO(BookJournal journal) {
        BookJournalResponseDTO dto = new BookJournalResponseDTO();
        dto.setId(journal.getId());
        dto.setBook(bookService.mapToDTO(journal.getBook()));
        dto.setStatus(journal.getStatus());
        dto.setCurrentPage(journal.getCurrentPage());
        dto.setRating(journal.getRating());
        dto.setReadingFormat(journal.getReadingFormat());
        dto.setEmotions(journal.getEmotions());
        dto.setFavoriteQuotes(journal.getFavoriteQuotes());
        dto.setPersonalNotes(journal.getPersonalNotes());
        dto.setStartDate(journal.getStartDate());
        dto.setEndDate(journal.getEndDate());
        dto.setRereading(journal.getRereading());
        return dto;
    }
}
