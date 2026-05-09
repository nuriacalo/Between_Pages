package com.calonuria.backend.controller.journal;

import com.calonuria.backend.dto.journal.BookJournalRegistrationDTO;
import com.calonuria.backend.dto.journal.BookJournalResponseDTO;
import com.calonuria.backend.service.journal.BookJournalService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RestController
@RequestMapping("/api/book-journal")
@Tag(name = "Book Journal", description = "Seguimiento de lectura de libros")
public class BookJournalController extends BaseJournalController<
        BookJournalResponseDTO,
        BookJournalRegistrationDTO,
        BookJournalService> {

    public BookJournalController(BookJournalService bookJournalService, ApplicationEventPublisher eventPublisher) {
        super(bookJournalService, eventPublisher);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<String> handleValidationErrors(MethodArgumentNotValidException ex) {
        StringBuilder errors = new StringBuilder();
        ex.getBindingResult().getFieldErrors().forEach(error -> {
            errors.append(String.format("Field '%s': %s (value: %s); ",
                error.getField(), error.getDefaultMessage(), error.getRejectedValue()));
        });
        log.error("[BookJournalController] Validation failed: {}", errors);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body("Validation failed: " + errors.toString());
    }
}
