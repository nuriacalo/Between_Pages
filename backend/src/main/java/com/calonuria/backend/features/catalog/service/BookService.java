package com.calonuria.backend.features.catalog.service;

import com.calonuria.backend.features.catalog.model.Book;
import com.calonuria.backend.features.catalog.model.Genre;
import com.calonuria.backend.features.catalog.repository.BookRepository;
import com.calonuria.backend.features.catalog.repository.GenreRepository;
import com.calonuria.backend.features.catalog.repository.UserCatalogRepository;
import com.calonuria.backend.features.search.dto.BookResponseDTO;
import com.calonuria.backend.features.search.service.GoogleBooksService;
import com.calonuria.backend.shared.exception.ResourceNotFoundException;
import com.calonuria.backend.shared.service.BaseCatalogService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class BookService extends BaseCatalogService<Book, BookResponseDTO, Long> {

    private final BookRepository bookRepository;
    private final GenreRepository genreRepository;
    private final GoogleBooksService googleBooksService;
    private final UserCatalogRepository userCatalogRepository;

    public BookService(BookRepository bookRepository, GenreRepository genreRepository, GoogleBooksService googleBooksService, UserCatalogRepository userCatalogRepository) {
        super(bookRepository);
        this.bookRepository = bookRepository;
        this.genreRepository = genreRepository;
        this.googleBooksService = googleBooksService;
        this.userCatalogRepository = userCatalogRepository;
    }

    @Transactional(readOnly = true)
    public List<BookResponseDTO> getBooksByUserId(Long userId) {
        return userCatalogRepository.findByUserId(userId).stream()
                .filter(uc -> "BOOK".equals(uc.getItemType()) && uc.getBook() != null)
                .map(uc -> {
                    BookResponseDTO dto = mapToDTO(uc.getBook());
                    dto.setStatus(uc.getStatus());
                    return dto;
                })
                .collect(Collectors.toList());
    }

    @Transactional
    public Book findOrCreateBook(Long bookId, String googleBooksId) {
        if (bookId != null) {
            return bookRepository.findById(bookId)
                    .orElseThrow(() -> new ResourceNotFoundException("Libro no encontrado con id: " + bookId));
        }

        if (StringUtils.hasText(googleBooksId)) {
            return bookRepository.findByGoogleBooksId(googleBooksId)
                    .orElseGet(() -> {
                        BookResponseDTO bookDTO = googleBooksService.fetchBookByGoogleId(googleBooksId);
                        return createBookFromDto(bookDTO);
                    });
        }

        throw new IllegalArgumentException("Se debe proporcionar un bookId o un googleBooksId para encontrar o crear un libro.");
    }

    @Override
    public List<BookResponseDTO> searchByTitle(String title) {
        return bookRepository.findByTitleContainingIgnoreCase(title)
                .stream().map(this::mapToDTO).toList();
    }

    @Override
    public BookResponseDTO mapToDTO(Book book) {
        BookResponseDTO dto = new BookResponseDTO();
        dto.setId(book.getId());
        dto.setGoogleBooksId(book.getGoogleBooksId());
        dto.setTitle(book.getTitle());
        dto.setAuthor(book.getAuthor());
        dto.setIsbn(book.getIsbn());
        dto.setPublisher(book.getPublisher());
        dto.setDescription(book.getDescription());
        dto.setCoverUrl(book.getCoverUrl());
        if (book.getGenres() != null) {
            dto.setGenres(book.getGenres().stream().map(Genre::getName).toList());
        }
        dto.setBookType(book.getBookType());
        dto.setPublicationYear(book.getPublicationYear());
        dto.setPageCount(book.getPageCount());
        return dto;
    }

    @Transactional
    public BookResponseDTO createBook(BookResponseDTO dto) {
        Book book = createBookFromDto(dto);
        return mapToDTO(book);
    }

    @Transactional
    public Optional<BookResponseDTO> updateBook(Long id, BookResponseDTO dto) {
        return bookRepository.findById(id)
                .map(book -> {
                    updateBookFromDto(book, dto);
                    return mapToDTO(bookRepository.save(book));
                });
    }

    private Book createBookFromDto(BookResponseDTO dto) {
        Book book = new Book();
        book.setGoogleBooksId(dto.getGoogleBooksId());
        updateBookFromDto(book, dto);
        return bookRepository.save(book);
    }

    private void updateBookFromDto(Book book, BookResponseDTO dto) {
        book.setTitle(dto.getTitle());
        book.setAuthor(dto.getAuthor());
        book.setIsbn(dto.getIsbn());
        book.setPublisher(dto.getPublisher());
        book.setDescription(dto.getDescription());
        book.setCoverUrl(dto.getCoverUrl());
        book.setBookType(dto.getBookType());
        book.setPublicationYear(dto.getPublicationYear());
        book.setPageCount(dto.getPageCount());

        if (dto.getGenres() != null) {
            Set<Genre> genres = new HashSet<>();
            for (String genreName : dto.getGenres()) {
                Genre genre = genreRepository.findByNameIgnoreCase(genreName)
                        .orElseGet(() -> {
                            Genre newGenre = new Genre();
                            newGenre.setName(genreName);
                            return genreRepository.save(newGenre);
                        });
                genres.add(genre);
            }
            book.setGenres(genres);
        }
    }
}
