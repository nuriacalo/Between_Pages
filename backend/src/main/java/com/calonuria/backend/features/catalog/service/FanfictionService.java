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
 * Servicio para la gestión de fanfictions en el catálogo.
 * Extiende BaseCatalogService para reutilizar código común.
 */
@Service
public class FanfictionService extends BaseCatalogService<Fanfiction, FanfictionResponseDTO, Long> {

    private final FanfictionRepository fanfictionRepository;
    private final GenreRepository genreRepository;

    public FanfictionService(FanfictionRepository fanfictionRepository, GenreRepository genreRepository) {
        super(fanfictionRepository);
        this.fanfictionRepository = fanfictionRepository;
        this.genreRepository = genreRepository;
    }

    @Transactional
    public Fanfiction findOrCreate(Long fanfictionId, String ao3Id) {
        if (fanfictionId != null) {
            return fanfictionRepository.findById(fanfictionId)
                    .orElseThrow(() -> new ResourceNotFoundException("Fanfiction no encontrado con id: " + fanfictionId));
        }
        if (ao3Id != null && !ao3Id.isEmpty()) {
            return fanfictionRepository.findByAo3Id(ao3Id)
                    .orElseThrow(() -> new ResourceNotFoundException("Fanfiction no encontrado con ao3Id: " + ao3Id));
        }
        throw new IllegalArgumentException("Se requiere fanfictionId o ao3Id");
    }

    @Transactional
    public Optional<FanfictionResponseDTO> updateFanfic(Long id, FanfictionResponseDTO dto) {
        return fanfictionRepository.findById(id)
                .map(fanfic -> {
                    updateFanficFromDto(fanfic, dto);
                    return mapToDTO(fanfictionRepository.save(fanfic));
                });
    }

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

        // Corrección: Manejamos directamente la lista de géneros en lugar de un String
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
     * Guarda un fanfiction solo si no existe ya por ao3Id.
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
     * Crea y guarda un fanfiction desde un DTO si no existe.
     */
    @Transactional
    public FanfictionResponseDTO saveFromDTO(FanfictionResponseDTO dto) {
        Fanfiction fanfic = new Fanfiction();
        fanfic.setAo3Id(dto.getAo3Id());
        updateFanficFromDto(fanfic, dto);
        return saveIfNotExists(fanfic);
    }

    // Alias para compatibilidad con controllers existentes
    public Optional<FanfictionResponseDTO> getFanficById(Long id) {
        return findById(id);
    }

    @Override
    @Transactional(readOnly = true)
    public List<FanfictionResponseDTO> searchByTitle(String title) {
        return fanfictionRepository.findByTitleContainingIgnoreCase(title)
                .stream().map(this::mapToDTO).toList();
    }

    /**
     * Busca fanfictions por estado de publicación.
     */
    @Transactional(readOnly = true)
    public List<FanfictionResponseDTO> searchByStatus(String status) {
        return fanfictionRepository.findByPublicationStatusIgnoreCase(status)
                .stream().map(this::mapToDTO).toList();
    }

    // Alias para compatibilidad con controllers existentes
    public List<FanfictionResponseDTO> getAllFanfics() {
        return findAll();
    }

    /**
     * Mapea un fanfiction a su DTO de respuesta.
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

        // Corrección: Mapeamos el Set<Genre> a un List<String> directamente
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