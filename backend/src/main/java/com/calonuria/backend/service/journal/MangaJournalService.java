package com.calonuria.backend.service.journal;

import com.calonuria.backend.dto.journal.MangaJournalRegistrationDTO;
import com.calonuria.backend.dto.journal.MangaJournalResponseDTO;
import com.calonuria.backend.model.catalog.Manga;
import com.calonuria.backend.model.journal.MangaJournal;
import com.calonuria.backend.model.user.User;
import com.calonuria.backend.repository.catalog.MangaRepository;
import com.calonuria.backend.repository.journal.MangaJournalRepository;
import com.calonuria.backend.repository.user.UserRepository;
import com.calonuria.backend.service.catalog.MangaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Servicio para la gestión del diario de lectura de mangas.
 */
@Service
public class MangaJournalService {

    @Autowired
    private MangaJournalRepository mangaJournalRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private MangaRepository mangaRepository;

    @Autowired
    private MangaService mangaService;

    /**
     * Guarda el progreso de lectura de un manga.
     * @param dto datos del progreso
     * @return DTO con la información guardada
     */
    public MangaJournalResponseDTO saveProgress(MangaJournalRegistrationDTO dto) {
        User user = userRepository.findById(dto.getUserId())
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        
        Manga manga;

        // Si el DTO trae un mangaId, buscamos por ese ID en la base de datos
        if (dto.getMangaId() != null) {
            manga = mangaRepository.findById(dto.getMangaId())
                    .orElseThrow(() -> new RuntimeException("Manga no encontrado con id: " + dto.getMangaId()));
        } else if (dto.getMangadexId() != null) {
            // Si trae mangadexId (pero no mangaId), lo buscamos o lo creamos
            Optional<Manga> existing = mangaRepository.findByMangadexId(dto.getMangadexId());
            if (existing.isPresent()) {
                manga = existing.get();
            } else {
                // El manga es nuevo, lo registramos en el catálogo antes de agregarlo al Journal
                Manga newManga = new Manga();
                newManga.setMangadexId(dto.getMangadexId());
                newManga.setSource(dto.getSource() != null ? dto.getSource() : "MangaDex");
                // Validar campos obligatorios que vienen de MangaDex (o valores por defecto si vienen nulos)
                newManga.setTitle(dto.getTitle() != null ? dto.getTitle() : "Título Desconocido");
                newManga.setAuthor(dto.getAuthor() != null ? dto.getAuthor() : "Autor Desconocido");
                newManga.setDemographic(dto.getDemographic());
                newManga.setGenre(dto.getGenre());
                newManga.setDescription(dto.getDescription());
                newManga.setCoverUrl(dto.getCoverUrl());
                newManga.setTotalChapters(dto.getTotalChapters());
                newManga.setTotalVolumes(dto.getTotalVolumes());
                newManga.setPublicationStatus(dto.getPublicationStatus());

                manga = mangaRepository.save(newManga);
            }
        } else {
            throw new RuntimeException("Debe proporcionar un mangaId o un mangadexId");
        }

        MangaJournal journal = mangaJournalRepository.findByUserAndManga(user, manga)
                .orElse(new MangaJournal());

        if (journal.getId() == null) {
            journal.setUser(user);
            journal.setManga(manga);
        }

        journal.setStatus(dto.getStatus());
        journal.setCurrentChapter(dto.getCurrentChapter());
        journal.setCurrentVolume(dto.getCurrentVolume());
        journal.setRating(dto.getRating());
        journal.setReadingFormat(dto.getReadingFormat());
        journal.setFavoriteCharacter(dto.getFavoriteCharacter());
        journal.setFavoriteArc(dto.getFavoriteArc());
        journal.setPersonalNotes(dto.getPersonalNotes());
        journal.setStartDate(dto.getStartDate());
        journal.setEndDate(dto.getEndDate());
        journal.setRereading(dto.getRereading());

        MangaJournal saved = mangaJournalRepository.save(journal);
        return mapToDTO(saved);
    }

    /**
     * Obtiene el journal de un usuario.
     * @param userId ID del usuario
     * @return lista de entradas del journal
     */
    public List<MangaJournalResponseDTO> getUserJournal(Long userId) {
        return mangaJournalRepository.findByUserId(userId)
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    /**
     * Obtiene entradas del journal filtradas por estado.
     * @param userId ID del usuario
     * @param status estado de lectura
     * @return lista de entradas filtradas
     */
    public List<MangaJournalResponseDTO> getByStatus(Long userId, String status) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        return mangaJournalRepository.findByUserAndStatus(user, status)
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    /**
     * Obtiene las relecturas de un usuario.
     * @param userId ID del usuario
     * @return lista de relecturas
     */
    public List<MangaJournalResponseDTO> getRereadings(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        return mangaJournalRepository.findByUserAndRereadingTrue(user)
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    /**
     * Elimina una entrada del journal.
     * @param journalId ID de la entrada
     */
    public void deleteJournal(Long journalId) {
        mangaJournalRepository.deleteById(journalId);
    }

    /**
     * Mapea una entrada del journal a su DTO de respuesta.
     * @param journal entrada del journal
     * @return DTO de respuesta
     */
    private MangaJournalResponseDTO mapToDTO(MangaJournal journal) {
        MangaJournalResponseDTO dto = new MangaJournalResponseDTO();
        dto.setId(journal.getId());
        dto.setManga(mangaService.mapToDTO(journal.getManga()));
        dto.setStatus(journal.getStatus());
        dto.setCurrentChapter(journal.getCurrentChapter());
        dto.setCurrentVolume(journal.getCurrentVolume());
        dto.setRating(journal.getRating());
        dto.setReadingFormat(journal.getReadingFormat());
        dto.setFavoriteCharacter(journal.getFavoriteCharacter());
        dto.setFavoriteArc(journal.getFavoriteArc());
        dto.setPersonalNotes(journal.getPersonalNotes());
        dto.setStartDate(journal.getStartDate());
        dto.setEndDate(journal.getEndDate());
        dto.setRereading(journal.getRereading());
        return dto;
    }
}
