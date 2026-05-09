package com.calonuria.backend.controller.journal;

import com.calonuria.backend.dto.journal.MangaJournalRegistrationDTO;
import com.calonuria.backend.dto.journal.MangaJournalResponseDTO;
import com.calonuria.backend.service.journal.MangaJournalService;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/manga-journal")
@Tag(name = "Manga Journal", description = "Seguimiento de lectura de mangas")
public class MangaJournalController extends BaseJournalController<
        MangaJournalResponseDTO,
        MangaJournalRegistrationDTO,
        MangaJournalService> {

    public MangaJournalController(MangaJournalService mangaJournalService, ApplicationEventPublisher eventPublisher) {
        super(mangaJournalService, eventPublisher);
    }
}
