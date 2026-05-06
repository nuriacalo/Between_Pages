package com.calonuria.backend.service.journal;

import com.calonuria.backend.dto.journal.MangaJournalRegistrationDTO;
import com.calonuria.backend.dto.journal.MangaJournalResponseDTO;
import com.calonuria.backend.exception.ResourceNotFoundException;
import com.calonuria.backend.model.catalog.Manga;
import com.calonuria.backend.model.journal.MangaJournal;
import com.calonuria.backend.model.user.User;
import com.calonuria.backend.repository.catalog.MangaRepository;
import com.calonuria.backend.repository.journal.MangaJournalRepository;
import com.calonuria.backend.repository.user.UserRepository;
import com.calonuria.backend.service.catalog.MangaService;
import com.calonuria.backend.service.catalog.PublicationStatusConverter;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

/**
 * Servicio para la gestión del diario de lectura de mangas.
 */
@Service
public class MangaJournalService extends BaseJournalService<MangaJournal, MangaJournalResponseDTO> {

    private final MangaJournalRepository mangaJournalRepository;
    private final MangaRepository mangaRepository;
    private final MangaService mangaService;

    public MangaJournalService(MangaJournalRepository mangaJournalRepository,
                               UserRepository userRepository,
                               MangaRepository mangaRepository,
                               MangaService mangaService) {
        super(mangaJournalRepository, userRepository);
        this.mangaJournalRepository = mangaJournalRepository;
        this.mangaRepository = mangaRepository;
        this.mangaService = mangaService;
    }

    /**
     * Guarda el progreso de lectura de un manga.
     * @param dto datos del progreso
     * @return DTO con la información guardada
     */
    @Transactional
    public MangaJournalResponseDTO saveProgress(MangaJournalRegistrationDTO dto) {
        User user = userRepository.findById(dto.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("Usuario no encontrado con id: " + dto.getUserId()));
        
        Manga manga;

        // Si el DTO trae un mangaId, buscamos por ese ID en la base de datos
        if (dto.getMangaId() != null) {
            manga = mangaRepository.findById(dto.getMangaId())
                    .orElseThrow(() -> new ResourceNotFoundException("Manga no encontrado con id: " + dto.getMangaId()));
        } else if (dto.getMalId() != null) {
            // Si trae malId (pero no mangaId), lo buscamos o lo creamos
            Optional<Manga> existing = mangaRepository.findByMalId(dto.getMalId());
            if (existing.isPresent()) {
                manga = existing.get();
            } else {
                // El manga es nuevo, lo registramos en el catálogo antes de agregarlo al Journal
                Manga newManga = new Manga();
                newManga.setMalId(dto.getMalId());
                newManga.setSource(dto.getSource() != null ? dto.getSource() : "MyAnimeList");
                // Validar campos obligatorios que vienen de MyAnimeList (o valores por defecto si vienen nulos)
                newManga.setTitle(dto.getTitle() != null ? dto.getTitle() : "Título Desconocido");
                newManga.setAuthor(dto.getAuthor() != null ? dto.getAuthor() : "Autor Desconocido");
                newManga.setDemographic(dto.getDemographic());
                newManga.setGenre(dto.getGenre());
                newManga.setDescription(dto.getDescription());
                newManga.setCoverUrl(dto.getCoverUrl());
                newManga.setTotalChapters(dto.getTotalChapters());
                newManga.setTotalVolumes(dto.getTotalVolumes());
                // Mapear estado a valores de BD
                newManga.setPublicationStatus(PublicationStatusConverter.toDatabase(dto.getPublicationStatus()));

                manga = mangaRepository.save(newManga);
            }
        } else {
            throw new IllegalArgumentException("Debe proporcionar un mangaId o un malId");
        }

        MangaJournal journal = mangaJournalRepository.findByUserAndManga(user, manga)
                .orElse(new MangaJournal());

        if (journal.getId() == null) {
            journal.setUser(user);
            journal.setManga(manga);
        }

        journal.setStatus(JournalStatusConverter.toDatabase(dto.getStatus()));
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

    /**
     * Mapea una entrada del journal a su DTO de respuesta.
     * @param journal entrada del journal
     * @return DTO de respuesta
     */
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
