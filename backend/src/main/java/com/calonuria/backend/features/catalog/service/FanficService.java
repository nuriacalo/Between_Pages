package com.calonuria.backend.features.catalog.service;

import com.calonuria.backend.features.catalog.dto.FanficResponseDTO;
import com.calonuria.backend.shared.exception.ResourceNotFoundException;
import com.calonuria.backend.features.catalog.model.Fanfiction;
import com.calonuria.backend.features.catalog.model.Genre;
import com.calonuria.backend.features.catalog.repository.FanfictionRepository;
import com.calonuria.backend.features.catalog.repository.GenreRepository;
import com.calonuria.backend.shared.service.BaseCatalogService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class FanficService extends BaseCatalogService<Fanfiction, FanficResponseDTO, Long> {

    private final FanfictionRepository fanficRepository;
    private final GenreRepository genreRepository;

    public FanficService(FanfictionRepository fanficRepository, GenreRepository genreRepository) {
        super(fanficRepository);
        this.fanficRepository = fanficRepository;
        this.genreRepository = genreRepository;
    }

    @Transactional
    public Fanfiction findOrCreate(Long fanficId, String ao3Id) {
        if (fanficId != null) {
            return fanficRepository.findById(fanficId)
                    .orElseThrow(() -> new ResourceNotFoundException("Fanfic no encontrado con id: " + fanficId));
        }

        if (ao3Id != null) {
            return fanficRepository.findByAo3Id(ao3Id)
                    .orElseThrow(() -> new ResourceNotFoundException("Fanfic no encontrado con ao3Id: " + ao3Id));
        }

        throw new IllegalArgumentException("Se debe proporcionar un fanficId o un ao3Id para encontrar un fanfic.");
    }

    @Override
    public FanficResponseDTO mapToDTO(Fanfiction fanfic) {
        FanficResponseDTO dto = new FanficResponseDTO();
        dto.setId(fanfic.getId());
        dto.setAo3Id(fanfic.getAo3Id());
        dto.setTitle(fanfic.getTitle());
        dto.setAuthor(fanfic.getAuthor());
        dto.setSourceMaterial(fanfic.getSourceMaterial());
        dto.setDescription(fanfic.getDescription());
        dto.setCoverUrl(fanfic.getCoverUrl());
        if (fanfic.getGenres() != null) {
            dto.setGenres(fanfic.getGenres().stream().map(Genre::getName).collect(Collectors.toList()));
        }
        dto.setMainShip(fanfic.getMainShip());
        dto.setTheme(fanfic.getTheme());
        dto.setCurrentChapter(fanfic.getCurrentChapter());
        dto.setTotalChapters(fanfic.getTotalChapters());
        dto.setPublicationStatus(fanfic.getPublicationStatus());
        return dto;
    }

    public Optional<FanficResponseDTO> updateFanfic(Long id, FanficResponseDTO dto) {
        return fanficRepository.findById(id)
                .map(fanfic -> {
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

                    if (dto.getGenres() != null) {
                        Set<Genre> genres = new HashSet<>();
                        for (String genreName : dto.getGenres()) {
                            Genre genre = genreRepository.findByNameIgnoreCase(genreName)
                                    .orElseGet(() -> {
                                        Genre newGenre = new Genre();
                                        newGenre.setName(genreName);
                                        return genreRepository.save(newGenre);
                                    });
                            genres.add(genre);
                        }
                        fanfic.setGenres(genres);
                    }

                    return mapToDTO(fanficRepository.save(fanfic));
                });
    }

    @Override
    public List<FanficResponseDTO> searchByTitle(String title) {
        return fanficRepository.findByTitleContainingIgnoreCase(title)
                .stream().map(this::mapToDTO).collect(Collectors.toList());
    }
}
