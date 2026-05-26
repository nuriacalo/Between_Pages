package com.calonuria.backend.features.catalog.service;

import com.calonuria.backend.features.catalog.dto.MangaResponseDTO;
import com.calonuria.backend.features.catalog.model.Manga;
import com.calonuria.backend.features.catalog.repository.MangaRepository;
import com.calonuria.backend.features.catalog.repository.UserCatalogRepository;
import com.calonuria.backend.features.catalog.service.external.JikanService;
import com.calonuria.backend.shared.exception.ResourceNotFoundException;
import com.calonuria.backend.shared.service.BaseCatalogService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class MangaService extends BaseCatalogService<Manga, MangaResponseDTO, Long> {

    private final MangaRepository mangaRepository;
    private final JikanService jikanService;
    private final UserCatalogRepository userCatalogRepository;

    public MangaService(MangaRepository mangaRepository, JikanService jikanService, UserCatalogRepository userCatalogRepository) {
        super(mangaRepository);
        this.mangaRepository = mangaRepository;
        this.jikanService = jikanService;
        this.userCatalogRepository = userCatalogRepository;
    }

    @Transactional(readOnly = true)
    public List<MangaResponseDTO> getMangasByUserId(Long userId) {
        return userCatalogRepository.findByUserId(userId).stream()
                .filter(uc -> "MANGA".equals(uc.getItemType()) && uc.getManga() != null)
                .map(uc -> mapToDTO(uc.getManga()))
                .collect(Collectors.toList());
    }

    @Transactional
    public Manga findOrCreate(Long mangaId, Integer malId) {
        if (mangaId != null) {
            return mangaRepository.findById(mangaId)
                    .orElseThrow(() -> new ResourceNotFoundException("Manga no encontrado con id: " + mangaId));
        }

        if (malId != null) {
            return mangaRepository.findByMalId(malId)
                    .orElseGet(() -> {
                        MangaResponseDTO mangaDTO = jikanService.getMangaById(malId);
                        return createMangaFromDto(mangaDTO);
                    });
        }

        throw new IllegalArgumentException("Se debe proporcionar un mangaId o un malId para encontrar o crear un manga.");
    }

    @Override
    public List<MangaResponseDTO> searchByTitle(String title) {
        return mangaRepository.findByTitleContainingIgnoreCase(title)
                .stream().map(this::mapToDTO).toList();
    }

    @Override
    public MangaResponseDTO mapToDTO(Manga manga) {
        MangaResponseDTO dto = new MangaResponseDTO();
        dto.setId(manga.getId());
        dto.setMalId(manga.getMalId());
        dto.setSource(manga.getSource());
        dto.setTitle(manga.getTitle());
        dto.setAuthor(manga.getAuthor());
        dto.setDemographic(manga.getDemographic());
        dto.setDescription(manga.getDescription());
        dto.setCoverUrl(manga.getCoverUrl());
        dto.setTotalChapters(manga.getTotalChapters());
        dto.setTotalVolumes(manga.getTotalVolumes());
        dto.setMalScore(manga.getMalScore());
        dto.setPublicationStatus(manga.getPublicationStatus());
        return dto;
    }

    @Transactional
    public MangaResponseDTO createManga(MangaResponseDTO dto) {
        Manga manga = createMangaFromDto(dto);
        return mapToDTO(manga);
    }

    @Transactional
    public Optional<MangaResponseDTO> updateManga(Long id, MangaResponseDTO dto) {
        return mangaRepository.findById(id)
                .map(manga -> {
                    updateMangaFromDto(manga, dto);
                    return mapToDTO(mangaRepository.save(manga));
                });
    }

    private Manga createMangaFromDto(MangaResponseDTO dto) {
        Manga manga = new Manga();
        manga.setMalId(dto.getMalId());
        updateMangaFromDto(manga, dto);
        return mangaRepository.save(manga);
    }

    private void updateMangaFromDto(Manga manga, MangaResponseDTO dto) {
        manga.setSource(dto.getSource());
        manga.setTitle(dto.getTitle());
        manga.setAuthor(dto.getAuthor());
        manga.setDemographic(dto.getDemographic());
        manga.setDescription(dto.getDescription());
        manga.setCoverUrl(dto.getCoverUrl());
        manga.setTotalChapters(dto.getTotalChapters());
        manga.setTotalVolumes(dto.getTotalVolumes());
        manga.setMalScore(dto.getMalScore());
        manga.setPublicationStatus(dto.getPublicationStatus());
    }
}