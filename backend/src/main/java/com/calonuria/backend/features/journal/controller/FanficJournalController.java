package com.calonuria.backend.controller.journal;

import com.calonuria.backend.dto.journal.FanficJournalRegistrationDTO;
import com.calonuria.backend.dto.journal.FanficJournalResponseDTO;
import com.calonuria.backend.service.journal.FanficJournalService;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/fanfic-journal")
@Tag(name = "Fanfic Journal", description = "Seguimiento de lectura de fanfictions")
public class FanficJournalController extends BaseJournalController<
        FanficJournalResponseDTO,
        FanficJournalRegistrationDTO,
        FanficJournalService> {

    public FanficJournalController(FanficJournalService fanficJournalService, ApplicationEventPublisher eventPublisher) {
        super(fanficJournalService, eventPublisher);
    }
}
