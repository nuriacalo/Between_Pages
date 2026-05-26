package com.calonuria.backend.features.catalog.service;

import com.calonuria.backend.features.catalog.dto.FanfictionResponseDTO;
import com.calonuria.backend.features.catalog.model.Fanfiction;
import com.calonuria.backend.features.catalog.repository.FanfictionRepository;
import com.calonuria.backend.features.catalog.repository.UserCatalogRepository;
import com.calonuria.backend.shared.exception.ResourceNotFoundException;
import com.calonuria.backend.shared.service.BaseCatalogService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class FanfictionService extends BaseCatalogService<Fanfiction, FanfictionResponseDTO, Long> {

    private final FanfictionRepository fanfictionRepository;
    private final UserCatalogRepository userCatalogRepository;

    public FanfictionService(FanfictionRepository fanfictionRepository, UserCatalogRepository userCatalogRepository) {
        super(fanfictionRepository);
        this.fanfictionRepository = fanfictionRepository;
        this.userCatalogRepository = userCatalogRepository;
    }

    @Transactional(readOnly = true)
    public List<FanfictionResponseDTO> getFanficsByUserId(Long userId) {
        return userCatalogRepository.findByUserId(userId).stream()
                .filter(uc -> "FANFIC".equals(uc.getItemType()) && uc.getFanfic() != null)
                .map(uc -> mapToDTO(uc.getFanfic()))
                .collect(Collectors.toList());
    }

    @Transactional
    public Fanfiction findOrCreate(Long fanficId, String ao3Id) {
        if (fanficId != null) {
            return fanfictionRepository.findById(fanficId)
                    .orElseThrow(() -> new ResourceNotFoundException("Fanfic no encontrado con id: " + fanficId));
        }

        if (StringUtils.hasText(ao3Id)) {
            return fanfictionRepository.findByAo3Id(ao3Id)
                    .orElseGet(() -> {
                        Fanfiction newFanfic = new Fanfiction();
                        newFanfic.setAo3Id(ao3Id);
                        return fanfictionRepository.save(newFanfic);
                    });
        }

        throw new IllegalArgumentException("Se debe proporcionar un fanficId o un ao3Id para encontrar o crear un fanfic.");
    }

    @Override
    public List<FanfictionResponseDTO> searchByTitle(String title) {
        return fanfictionRepository.findByTitleContainingIgnoreCase(title)
                .stream().map(this::mapToDTO).toList();
    }

    @Transactional(readOnly = true)
    public List<FanfictionResponseDTO> searchByStatus(String status) {
        return fanfictionRepository.findByPublicationStatusIgnoreCase(status)
                .stream().map(this::mapToDTO).toList();
    }

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
        dto.setMainShip(fanfic.getMainShip());
        dto.setTheme(fanfic.getTheme());
        dto.setCurrentChapter(fanfic.getCurrentChapter());
        dto.setTotalChapters(fanfic.getTotalChapters());
        dto.setPublicationStatus(fanfic.getPublicationStatus());
        return dto;
    }

    @Transactional
    public FanfictionResponseDTO createFanfic(FanfictionResponseDTO dto) {
        Fanfiction fanfic = createFanficFromDto(dto);
        return mapToDTO(fanfic);
    }

    @Transactional
    public Optional<FanfictionResponseDTO> updateFanfic(Long id, FanfictionResponseDTO dto) {
        return fanfictionRepository.findById(id)
                .map(fanfic -> {
                    updateFanficFromDto(fanfic, dto);
                    return mapToDTO(fanfictionRepository.save(fanfic));
                });
    }

    private Fanfiction createFanficFromDto(FanfictionResponseDTO dto) {
        Fanfiction fanfic = new Fanfiction();
        fanfic.setAo3Id(dto.getAo3Id());
        updateFanficFromDto(fanfic, dto);
        return fanfictionRepository.save(fanfic);
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
    }
}