package com.calonuria.backend.service.journal;

import com.calonuria.backend.dto.journal.FanficJournalRegistrationDTO;
import com.calonuria.backend.dto.journal.FanficJournalResponseDTO;
import com.calonuria.backend.exception.ResourceNotFoundException;
import com.calonuria.backend.model.catalog.Fanfiction;
import com.calonuria.backend.model.journal.FanficJournal;
import com.calonuria.backend.model.user.User;
import com.calonuria.backend.repository.journal.FanficJournalRepository;
import com.calonuria.backend.repository.user.UserRepository;
import com.calonuria.backend.service.catalog.FanficService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class FanficJournalService extends BaseJournalService<FanficJournal, FanficJournalResponseDTO, FanficJournalRegistrationDTO> {

    private final FanficJournalRepository fanficJournalRepository;
    private final FanficService fanficService;

    public FanficJournalService(FanficJournalRepository fanficJournalRepository,
                                UserRepository userRepository,
                                FanficService fanficService) {
        super(fanficJournalRepository, userRepository);
        this.fanficJournalRepository = fanficJournalRepository;
        this.fanficService = fanficService;
    }

    @Override
    @Transactional
    public FanficJournalResponseDTO saveProgress(FanficJournalRegistrationDTO dto) {
        User user = userRepository.findById(dto.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("Usuario no encontrado con id: " + dto.getUserId()));
        
        Fanfiction fanfic = fanficService.findOrCreate(dto.getFanfictionId(), dto.getAo3Id());

        FanficJournal journal = fanficJournalRepository.findByUserAndFanfic(user, fanfic)
                .orElse(new FanficJournal());

        if (journal.getId() == null) {
            journal.setUser(user);
            journal.setFanfic(fanfic);
        }

        journal.setStatus(JournalStatusConverter.toDatabase(dto.getStatus()));
        journal.setCurrentChapter(dto.getCurrentChapter());
        journal.setRating(dto.getRating());
        journal.setTearDrops(dto.getTearDrops());
        journal.setSpiceFlames(dto.getSpiceFlames());
        journal.setMainShip(dto.getMainShip());
        journal.setSecondaryShips(dto.getSecondaryShips());
        journal.setTheme(dto.getTheme());
        journal.setAngstLevel(dto.getAngstLevel());
        journal.setShipLoyalty(dto.getShipLoyalty());
        journal.setCanonType(dto.getCanonType());
        journal.setRereading(dto.getRereading());
        journal.setPersonalNotes(dto.getPersonalNotes());
        journal.setStartDate(dto.getStartDate());
        journal.setEndDate(dto.getEndDate());

        FanficJournal saved = fanficJournalRepository.save(journal);
        return mapToDTO(saved);
    }

    @Override
    protected FanficJournalResponseDTO mapToDTO(FanficJournal journal) {
        FanficJournalResponseDTO dto = new FanficJournalResponseDTO();
        dto.setId(journal.getId());
        dto.setUserId(journal.getUser().getId());
        dto.setFanfic(fanficService.mapToDTO(journal.getFanfic()));
        dto.setStatus(journal.getStatus());
        dto.setCurrentChapter(journal.getCurrentChapter());
        dto.setRating(journal.getRating());
        dto.setTearDrops(journal.getTearDrops());
        dto.setSpiceFlames(journal.getSpiceFlames());
        dto.setMainShip(journal.getMainShip());
        dto.setSecondaryShips(journal.getSecondaryShips());
        dto.setAngstLevel(journal.getAngstLevel());
        dto.setShipLoyalty(journal.getShipLoyalty());
        dto.setCanonType(journal.getCanonType());
        dto.setRereading(journal.getRereading());
        dto.setPersonalNotes(journal.getPersonalNotes());
        dto.setStartDate(journal.getStartDate());
        dto.setEndDate(journal.getEndDate());
        dto.setUpdatedAt(journal.getUpdatedAt());
        return dto;
    }
}
