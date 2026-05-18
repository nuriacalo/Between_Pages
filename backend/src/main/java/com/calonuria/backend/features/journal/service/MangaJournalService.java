package com.calonuria.backend.features.journal.service;

import com.calonuria.backend.features.journal.dto.MangaJournalRegistrationDTO;
import com.calonuria.backend.features.journal.dto.MangaJournalResponseDTO;
import com.calonuria.backend.shared.exception.ResourceNotFoundException;
import com.calonuria.backend.features.catalog.model.Manga;
import com.calonuria.backend.features.journal.model.MangaJournal;
import com.calonuria.backend.features.user.model.User;
import com.calonuria.backend.features.journal.repository.MangaJournalRepository;
import com.calonuria.backend.features.user.repository.UserRepository;
import com.calonuria.backend.features.catalog.service.MangaService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class MangaJournalService extends BaseJournalService<MangaJournal, MangaJournalResponseDTO, MangaJournalRegistrationDTO> {

    private final MangaJournalRepository mangaJournalRepository;
    private final MangaService mangaService;

    public MangaJournalService(MangaJournalRepository mangaJournalRepository,
                               UserRepository userRepository,
                               MangaService mangaService) {
        super(mangaJournalRepository, userRepository);
        this.mangaJournalRepository = mangaJournalRepository;
        this.mangaService = mangaService;
    }

    @Override
    @Transactional
    public MangaJournalResponseDTO saveProgress(MangaJournalRegistrationDTO dto) {
        User user = userRepository.findById(dto.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("Usuario no encontrado con id: " + dto.getUserId()));
        
        Manga manga = mangaService.findOrCreate(dto.getMangaId(), dto.getMalId());

        MangaJournal journal = mangaJournalRepository.findByUserAndManga(user, manga)
                .orElse(new MangaJournal());

        if (journal.getId() == null) {
            journal.setUser(user);
            journal.setManga(manga);
        }

        journal.setStatus(normalizeJournalStatus(dto.getStatus()));
        journal.setCurrentChapter(dto.getCurrentChapter());
        journal.setCurrentVolume(dto.getCurrentVolume());
        journal.setRating(dto.getRating());
        journal.setTearDrops(dto.getTearDrops());
        journal.setSpiceFlames(dto.getSpiceFlames());
        journal.setReadingFormat(dto.getReadingFormat());
        journal.setFavoriteCharacter(dto.getFavoriteCharacter());
        journal.setFavoriteArc(dto.getFavoriteArc());
        journal.setPersonalNotes(dto.getPersonalNotes());
        journal.setStartDate(dto.getStartDate());
        journal.setEndDate(dto.getEndDate());
        journal.setRereading(dto.getRereading());
        
        journal.setOwnership(dto.getOwnership());
        journal.setLoanedTo(dto.getLoanedTo());

        MangaJournal saved = mangaJournalRepository.save(journal);
        return mapToDTO(saved);
    }

    @Override
    protected MangaJournalResponseDTO mapToDTO(MangaJournal journal) {
        MangaJournalResponseDTO dto = new MangaJournalResponseDTO();
        dto.setId(journal.getId());
        dto.setUserId(journal.getUser().getId());
        dto.setManga(mangaService.mapToDTO(journal.getManga()));
        dto.setStatus(journal.getStatus());
        dto.setCurrentChapter(journal.getCurrentChapter());
        dto.setCurrentVolume(journal.getCurrentVolume());
        dto.setRating(journal.getRating());
        dto.setTearDrops(journal.getTearDrops());
        dto.setSpiceFlames(journal.getSpiceFlames());
        dto.setReadingFormat(journal.getReadingFormat());
        dto.setFavoriteCharacter(journal.getFavoriteCharacter());
        dto.setFavoriteArc(journal.getFavoriteArc());
        dto.setPersonalNotes(journal.getPersonalNotes());
        dto.setStartDate(journal.getStartDate());
        dto.setEndDate(journal.getEndDate());
        dto.setUpdatedAt(journal.getUpdatedAt());
        dto.setRereading(journal.getRereading());
        dto.setOwnership(journal.getOwnership());
        dto.setLoanedTo(journal.getLoanedTo());
        return dto;
    }
}
