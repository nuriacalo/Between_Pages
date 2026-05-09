package com.calonuria.backend.service.catalog;

import com.calonuria.backend.dto.catalog.FanfictionResponseDTO;
import com.calonuria.backend.model.catalog.Fanfiction;
import com.calonuria.backend.model.catalog.FanficTag;
import com.calonuria.backend.repository.catalog.FanfictionRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

/**
 * Servicio para la gestión de fanfictions en el catálogo.
 * Extiende BaseCatalogService para reutilizar código común.
 */
@Service
public class FanfictionService extends BaseCatalogService<Fanfiction, FanfictionResponseDTO, Long> {

    private final FanfictionRepository fanfictionRepository;

    public FanfictionService(FanfictionRepository fanfictionRepository) {
        super(fanfictionRepository);
        this.fanfictionRepository = fanfictionRepository;
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
        fanfic.setTitle(dto.getTitle());
        fanfic.setAuthor(dto.getAuthor());
        fanfic.setSourceMaterial(dto.getSourceMaterial());
        fanfic.setDescription(dto.getDescription());
        fanfic.setCoverUrl(dto.getCoverUrl());
        fanfic.setGenre(dto.getGenre());
        fanfic.setMainShip(dto.getMainShip());
        fanfic.setTheme(dto.getTheme());
        fanfic.setCurrentChapter(dto.getCurrentChapter());
        fanfic.setTotalChapters(dto.getTotalChapters());
        fanfic.setPublicationStatus(dto.getPublicationStatus());
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
        dto.setGenre(fanfic.getGenre());
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