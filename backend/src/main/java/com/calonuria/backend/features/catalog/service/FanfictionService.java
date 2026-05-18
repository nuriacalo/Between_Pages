package com.calonuria.backend.features.catalog.service;

import com.calonuria.backend.features.catalog.dto.FanfictionResponseDTO;
import com.calonuria.backend.features.catalog.model.Fanfiction;
import com.calonuria.backend.features.catalog.model.FanficTag;
import com.calonuria.backend.features.catalog.model.Genre;
import com.calonuria.backend.features.catalog.repository.FanfictionRepository;
import com.calonuria.backend.features.catalog.repository.GenreRepository;
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

/**
 * Service class for managing fanfiction entities within the local catalog.
 * Extends {@link BaseCatalogService} to reuse common catalog logic.
 * Primarily designed to work alongside the AO3 Crawler Service to store
 * and update extracted fanfiction metadata.
 */
@Service
public class FanfictionService extends BaseCatalogService<Fanfiction, FanfictionResponseDTO, Long> {

    private final FanfictionRepository fanfictionRepository;
    private final GenreRepository genreRepository;

    /**
     * Constructs a new {@code FanfictionService}.
     *
     * @param fanfictionRepository the repository for fanfiction persistence
     * @param genreRepository      the repository for genre persistence
     */
    public FanfictionService(FanfictionRepository fanfictionRepository, GenreRepository genreRepository) {
        super(fanfictionRepository);
        this.fanfictionRepository = fanfictionRepository;
        this.genreRepository = genreRepository;
    }

    /**
     * Retrieves a fanfiction from the database or creates a new empty placeholder
     * if it does not exist.
     *
     * @param fanfictionId the local database ID (optional)
     * @param ao3Id        the Archive of Our Own ID (optional)
     * @return the resolved or newly initialized {@link Fanfiction}
     * @throws ResourceNotFoundException if the provided local ID does not exist
     */
    @Transactional
    public Fanfiction findOrCreate(Long fanfictionId, String ao3Id) {
        if (fanfictionId != null) {
            return fanfictionRepository.findById(fanfictionId)
                    .orElseThrow(() -> new ResourceNotFoundException("Fanfiction no encontrado con id: " + fanfictionId));
        }
        if (ao3Id != null && !ao3Id.isEmpty()) {
            return fanfictionRepository.findByAo3Id(ao3Id)
                    .orElseGet(() -> fanfictionRepository.save(new Fanfiction(ao3Id)));
        }
        // Si ambos son nulos, crea una nueva instancia sin ao3Id.
        // El título y otros detalles se pueden añadir después.
        return fanfictionRepository.save(new Fanfiction());
    }

    /**
     * Updates an existing fanfiction record with the properties provided in the DTO.
     *
     * @param id  the local database ID of the fanfiction to update
     * @param dto the data to apply
     * @return an {@link Optional} containing the updated DTO, or empty if not found
     */
    @Transactional
    public Optional<FanfictionResponseDTO> updateFanfic(Long id, FanfictionResponseDTO dto) {
        return fanfictionRepository.findById(id)
                .map(fanfic -> {
                    updateFanficFromDto(fanfic, dto);
                    return mapToDTO(fanfictionRepository.save(fanfic));
                });
    }

    /**
     * Internal helper method to map fields from a DTO to a persistent entity.
     * Handles complex mapping for relationships like genres.
     */
    private void updateFanficFromDto(Fanfiction fanfic, FanfictionResponseDTO dto) {
        fanfic.setTitle(dto.getTitle());
        fanfic.setAuthor(dto.getAuthor());
        fanfic.setSourceMaterial(dto.getSourceMaterial());
        fanfic.setDescription(dto.getDescription());
        fanfic.setCoverUrl(dto.getCoverUrl());
        fanfic.setMainShip(dto.getMainShip());
        fanfic.setTheme(dto.getTheme());
        fanfic.setCurrentChapter(dto.getCurrentChapter());
        fanfic.setTotalChapters(dto.getTotalChapters());
        fanfic.setPublicationStatus(dto.getPublicationStatus());

        if (dto.getGenres() != null && !dto.getGenres().isEmpty()) {
            Set<Genre> genres = dto.getGenres().stream()
                    .filter(StringUtils::hasText) // Filtramos textos vacíos de la lista
                    .map(String::trim)
                    .map(genreName -> genreRepository.findByNameIgnoreCase(genreName)
                            .orElseGet(() -> genreRepository.save(new Genre(null, genreName))))
                    .collect(Collectors.toSet());
            fanfic.setGenres(genres);
        } else {
            // Si la lista viene vacía o nula, limpiamos los géneros
            fanfic.setGenres(new HashSet<>());
        }
    }

    /**
     * Persists a fanfiction entity only if another fanfiction with the same
     * AO3 ID does not already exist in the database.
     *
     * @param fanfic the fanfiction entity to save
     * @return the saved (or pre-existing) {@link FanfictionResponseDTO}
     */
    @Transactional
    public FanfictionResponseDTO saveIfNotExists(Fanfiction fanfic) {
        if (fanfic.getAo3Id() != null) {
            Optional<Fanfiction> existing = fanfictionRepository.findByAo3Id(fanfic.getAo3Id());
            if (existing.isPresent()) {
                return mapToDTO(existing.get());
            }
        }
        return saveAndMap(fanfic);
    }

    /**
     * Creates and saves a new fanfiction from a DTO representation if it doesn't already exist.
     *
     * @param dto the payload representing the new fanfiction
     * @return the mapped {@link FanfictionResponseDTO}
     */
    @Transactional
    public FanfictionResponseDTO saveFromDTO(FanfictionResponseDTO dto) {
        Fanfiction fanfic = new Fanfiction();
        fanfic.setAo3Id(dto.getAo3Id());
        updateFanficFromDto(fanfic, dto);
        return saveIfNotExists(fanfic);
    }

    /**
     * Alias method for finding a fanfiction by its database ID.
     */
    public Optional<FanfictionResponseDTO> getFanficById(Long id) {
        return findById(id);
    }

    /**
     * Searches for fanfictions matching the given title query, ignoring case.
     */
    @Override
    @Transactional(readOnly = true)
    public List<FanfictionResponseDTO> searchByTitle(String title) {
        return fanfictionRepository.findByTitleContainingIgnoreCase(title)
                .stream().map(this::mapToDTO).toList();
    }

    /**
     * Searches for fanfictions by their publication status (e.g., 'ONGOING').
     *
     * @param status the publication status
     * @return a list of matching {@link FanfictionResponseDTO}
     */
    @Transactional(readOnly = true)
    public List<FanfictionResponseDTO> searchByStatus(String status) {
        return fanfictionRepository.findByPublicationStatusIgnoreCase(status)
                .stream().map(this::mapToDTO).toList();
    }

    /**
     * Alias method for retrieving all fanfictions.
     */
    public List<FanfictionResponseDTO> getAllFanfics() {
        return findAll();
    }

    /**
     * Converts a raw {@link Fanfiction} entity into its corresponding DTO format.
     * Uses Hibernate BatchSize optimization to efficiently fetch AO3 tags.
     *
     * @param fanfic the entity to map
     * @return the mapped {@link FanfictionResponseDTO}
     */
    @Override
    public FanfictionResponseDTO mapToDTO(Fanfiction fanfic) {
        FanfictionResponseDTO dto = new FanfictionResponseDTO();
        dto.setId(fanfic.getId());
        dto.setAo3Id(fanfic.getAo3Id());
        dto.setTitle(fanfic.getTitle());
        dto.setAuthor(fanfic.getAuthor());
        dto.setSourceMaterial(fanfic.getSourceMaterial());
        dto.setDescription(fanfic.getDescription());
        dto.setCoverUrl(fanfic.getCoverUrl());

        if (fanfic.getGenres() != null && !fanfic.getGenres().isEmpty()) {
            dto.setGenres(fanfic.getGenres().stream().map(Genre::getName).collect(Collectors.toList()));
        }

        dto.setMainShip(fanfic.getMainShip());
        dto.setTheme(fanfic.getTheme());
        dto.setCurrentChapter(fanfic.getCurrentChapter());
        dto.setTotalChapters(fanfic.getTotalChapters());
        dto.setPublicationStatus(fanfic.getPublicationStatus());

        // Cargar tags eficientemente gracias a @BatchSize en la entidad
        if (fanfic.getTags() != null) {
            List<String> tags = fanfic.getTags().stream().map(FanficTag::getTag).toList();
            dto.setTags(tags);
        }

        return dto;
    }
}
