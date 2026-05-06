package com.calonuria.backend.service.journal;

import com.calonuria.backend.dto.journal.FanficJournalRegistrationDTO;
import com.calonuria.backend.dto.journal.FanficJournalResponseDTO;
import com.calonuria.backend.exception.ResourceNotFoundException;
import com.calonuria.backend.model.catalog.Fanfiction;
import com.calonuria.backend.model.journal.FanficJournal;
import com.calonuria.backend.model.user.User;
import com.calonuria.backend.repository.catalog.FanfictionRepository;
import com.calonuria.backend.repository.journal.FanficJournalRepository;
import com.calonuria.backend.repository.user.UserRepository;
import com.calonuria.backend.service.catalog.FanfictionService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.Optional;

/**
 * Servicio para la gestión del diario de lectura de fanfictions.
 */
@Service
public class FanficJournalService extends BaseJournalService<FanficJournal, FanficJournalResponseDTO> {

    private final FanficJournalRepository fanficJournalRepository;
    private final FanfictionRepository fanfictionRepository;
    private final FanfictionService fanfictionService;

    public FanficJournalService(FanficJournalRepository fanficJournalRepository,
                                UserRepository userRepository,
                                FanfictionRepository fanfictionRepository,
                                FanfictionService fanfictionService) {
        super(fanficJournalRepository, userRepository);
        this.fanficJournalRepository = fanficJournalRepository;
        this.fanfictionRepository = fanfictionRepository;
        this.fanfictionService = fanfictionService;
    }

    /**
     * Guarda el progreso de lectura de un fanfiction.
     * @param dto datos del progreso
     * @return DTO con la información guardada
     */
    @Transactional
    public FanficJournalResponseDTO saveProgress(FanficJournalRegistrationDTO dto) {
        User user = userRepository.findById(dto.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("Usuario no encontrado con id: " + dto.getUserId()));
        
        Fanfiction fanfic;

        // Si el DTO trae un fanfictionId, buscamos por ese ID en la base de datos
        if (dto.getFanfictionId() != null) {
            fanfic = fanfictionRepository.findById(dto.getFanfictionId())
                    .orElseThrow(() -> new ResourceNotFoundException("Fanfiction no encontrado con id: " + dto.getFanfictionId()));
        } else if (dto.getAo3Id() != null) {
            // Si trae ao3Id (pero no fanfictionId), lo buscamos o lo creamos
            Optional<Fanfiction> existing = fanfictionRepository.findByAo3Id(dto.getAo3Id());
            if (existing.isPresent()) {
                fanfic = existing.get();
            } else {
                // El fanfic es nuevo, lo registramos en el catálogo antes de agregarlo al Journal
                Fanfiction newFanfic = new Fanfiction();
                newFanfic.setAo3Id(dto.getAo3Id());
                // Validar campos obligatorios que vienen de la API de AO3/similar
                newFanfic.setTitle(dto.getTitle() != null ? dto.getTitle() : "Título Desconocido");
                newFanfic.setAuthor(dto.getAuthor() != null ? dto.getAuthor() : "Autor Desconocido");
                newFanfic.setSourceMaterial(dto.getSourceMaterial());
                newFanfic.setDescription(dto.getDescription());
                newFanfic.setCoverUrl(dto.getCoverUrl());
                newFanfic.setGenre(dto.getGenre());
                newFanfic.setMainShip(dto.getMainShip());
                newFanfic.setTheme(dto.getTheme());
                newFanfic.setTotalChapters(dto.getTotalChapters());
                newFanfic.setPublicationStatus(dto.getPublicationStatus());

                fanfic = fanfictionRepository.save(newFanfic);
            }
        } else {
            throw new IllegalArgumentException("Debe proporcionar un fanfictionId o un ao3Id");
        }

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

    /**
     * Mapea una entrada del journal a su DTO de respuesta.
     * @param journal entrada del journal
     * @return DTO de respuesta
     */
    @Override
    protected FanficJournalResponseDTO mapToDTO(FanficJournal journal) {
        FanficJournalResponseDTO dto = new FanficJournalResponseDTO();
        dto.setId(journal.getId());
        dto.setUserId(journal.getUser().getId());
        dto.setFanfic(fanfictionService.mapToDTO(journal.getFanfic()));
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
