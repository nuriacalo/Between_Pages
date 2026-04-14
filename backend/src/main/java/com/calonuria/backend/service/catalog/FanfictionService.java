package com.calonuria.backend.service.catalog;

import com.calonuria.backend.dto.catalog.FanfictionResponseDTO;
import com.calonuria.backend.model.catalog.Fanfiction;
import com.calonuria.backend.model.catalog.FanficTag;
import com.calonuria.backend.repository.catalog.FanfictionRepository;
import com.calonuria.backend.repository.catalog.FanficTagRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Servicio para la gestión de fanfictions en el catálogo.
 */
@Service
public class FanfictionService {

    @Autowired
    private FanfictionRepository fanfictionRepository;

    @Autowired
    private FanficTagRepository fanficTagRepository;

    /**
     * Guarda un fanfiction solo si no existe ya por ao3Id.
     * @param fanfic fanfiction a guardar
     * @return DTO con la información del fanfiction guardado
     */
    public FanfictionResponseDTO saveIfNotExists(Fanfiction fanfic) {
        if (fanfic.getAo3Id() != null) {
            Optional<Fanfiction> existing = fanfictionRepository.findByAo3Id(fanfic.getAo3Id());
            if (existing.isPresent()) {
                return mapToDTO(existing.get());
            }
        }
        return mapToDTO(fanfictionRepository.save(fanfic));
    }

    /**
     * Obtiene un fanfiction por su ID.
     * @param id ID del fanfiction
     * @return Optional con el DTO del fanfiction
     */
    public Optional<FanfictionResponseDTO> getFanficById(Long id) {
        return fanfictionRepository.findById(id).map(this::mapToDTO);
    }

    /**
     * Busca fanfictions por título.
     * @param title título a buscar
     * @return lista de fanfictions encontrados
     */
    public List<FanfictionResponseDTO> searchByTitle(String title) {
        return fanfictionRepository.findByTitleContainingIgnoreCase(title)
                .stream().map(this::mapToDTO).collect(Collectors.toList());
    }

    /**
     * Busca fanfictions por estado de publicación.
     * @param status estado a buscar
     * @return lista de fanfictions encontrados
     */
    public List<FanfictionResponseDTO> searchByStatus(String status) {
        return fanfictionRepository.findByPublicationStatusIgnoreCase(status)
                .stream().map(this::mapToDTO).collect(Collectors.toList());
    }

    /**
     * Mapea un fanfiction a su DTO de respuesta.
     * @param fanfic fanfiction
     * @return DTO de respuesta
     */
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
        // Cargar tags desde la tabla fanfic_tag
        List<String> tags = fanficTagRepository.findByFanfic_Id(fanfic.getId())
                .stream().map(FanficTag::getTag).collect(Collectors.toList());
        dto.setTags(tags);
        return dto;
    }
}