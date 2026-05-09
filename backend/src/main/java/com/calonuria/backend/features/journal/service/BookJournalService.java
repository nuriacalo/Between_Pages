package com.calonuria.backend.service.journal;

import com.calonuria.backend.dto.journal.BookJournalRegistrationDTO;
import com.calonuria.backend.dto.journal.BookJournalResponseDTO;
import com.calonuria.backend.exception.ResourceNotFoundException;
import com.calonuria.backend.model.catalog.Book;
import com.calonuria.backend.model.journal.BookJournal;
import com.calonuria.backend.model.user.User;
import com.calonuria.backend.repository.journal.BookJournalRepository;
import com.calonuria.backend.repository.user.UserRepository;
import com.calonuria.backend.service.catalog.BookService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class BookJournalService extends BaseJournalService<BookJournal, BookJournalResponseDTO, BookJournalRegistrationDTO> {

    private final BookJournalRepository bookJournalRepository;
    private final BookService bookService;

    public BookJournalService(BookJournalRepository bookJournalRepository,
                              UserRepository userRepository,
                              BookService bookService) {
        super(bookJournalRepository, userRepository);
        this.bookJournalRepository = bookJournalRepository;
        this.bookService = bookService;
    }

    @Override
    @Transactional
    public BookJournalResponseDTO saveProgress(BookJournalRegistrationDTO dto) {
        User user = userRepository.findById(dto.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("Usuario no encontrado con id: " + dto.getUserId()));

        Book book = bookService.findOrCreateBook(dto.getBookId(), dto.getGoogleBooksId());

        BookJournal journal = bookJournalRepository.findByUserAndBook(user, book)
                .orElse(new BookJournal());

        if (journal.getId() == null) {
            journal.setUser(user);
            journal.setBook(book);
        }

        journal.setStatus(JournalStatusConverter.toDatabase(dto.getStatus()));
        journal.setCurrentPage(dto.getCurrentPage());
        journal.setRating(dto.getRating());
        journal.setTearDrops(dto.getTearDrops());
        journal.setSpiceFlames(dto.getSpiceFlames());
        journal.setReadingFormat(dto.getReadingFormat());
        journal.setEmotions(dto.getEmotions());
        journal.setFavoriteQuotes(dto.getFavoriteQuotes());
        journal.setPersonalNotes(dto.getPersonalNotes());
        journal.setStartDate(dto.getStartDate());
        journal.setEndDate(dto.getEndDate());
        journal.setRereading(dto.getRereading());
        journal.setOwnership(dto.getOwnership());
        journal.setSeriesName(dto.getSeriesName());
        journal.setSeriesOrder(dto.getSeriesOrder());
        journal.setLoanedTo(dto.getLoanedTo());

        BookJournal saved = bookJournalRepository.save(journal);
        return mapToDTO(saved);
    }

    @Override
    protected BookJournalResponseDTO mapToDTO(BookJournal journal) {
        BookJournalResponseDTO dto = new BookJournalResponseDTO();
        dto.setId(journal.getId());
        dto.setUserId(journal.getUser().getId());
        dto.setBook(bookService.mapToDTO(journal.getBook()));
        dto.setStatus(journal.getStatus());
        dto.setCurrentPage(journal.getCurrentPage());
        dto.setRating(journal.getRating());
        dto.setTearDrops(journal.getTearDrops());
        dto.setSpiceFlames(journal.getSpiceFlames());
        dto.setReadingFormat(journal.getReadingFormat());
        dto.setEmotions(journal.getEmotions());
        dto.setFavoriteQuotes(journal.getFavoriteQuotes());
        dto.setPersonalNotes(journal.getPersonalNotes());
        dto.setStartDate(journal.getStartDate());
        dto.setEndDate(journal.getEndDate());
        dto.setUpdatedAt(journal.getUpdatedAt());
        dto.setRereading(journal.getRereading());
        dto.setOwnership(journal.getOwnership());
        dto.setSeriesName(journal.getSeriesName());
        dto.setSeriesOrder(journal.getSeriesOrder());
        dto.setLoanedTo(journal.getLoanedTo());
        return dto;
    }
}
