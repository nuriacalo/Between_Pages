package com.calonuria.backend.features.catalog.service;

import com.calonuria.backend.features.catalog.model.Book;
import com.calonuria.backend.features.catalog.repository.BookRepository;
import com.calonuria.backend.features.search.dto.BookResponseDTO;
import com.calonuria.backend.features.search.service.GoogleBooksService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class BookServiceTest {

    @Mock
    private BookRepository bookRepository;

    @Mock
    private GoogleBooksService googleBooksService;

    @InjectMocks
    private BookService bookService;

    @Test
    void findOrCreateBook_withBookId() {
        Book book = new Book();
        when(bookRepository.findById(1L)).thenReturn(Optional.of(book));
        assertNotNull(bookService.findOrCreateBook(1L, null));
    }

    @Test
    void findOrCreateBook_withGoogleBooksId_exists() {
        Book book = new Book();
        when(bookRepository.findByGoogleBooksId("testId")).thenReturn(Optional.of(book));
        assertNotNull(bookService.findOrCreateBook(null, "testId"));
    }

    @Test
    void findOrCreateBook_withGoogleBooksId_create() {
        when(bookRepository.findByGoogleBooksId("testId")).thenReturn(Optional.empty());
        when(googleBooksService.fetchBookByGoogleId("testId")).thenReturn(new BookResponseDTO());
        when(bookRepository.save(any(Book.class))).thenReturn(new Book());
        assertNotNull(bookService.findOrCreateBook(null, "testId"));
    }
}