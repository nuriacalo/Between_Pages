package com.calonuria.backend.service.catalog;

import com.calonuria.backend.dto.catalog.MangaResponseDTO;
import com.calonuria.backend.exception.ResourceNotFoundException;
import com.calonuria.backend.model.catalog.Genre;
import com.calonuria.backend.model.catalog.Manga;
import com.calonuria.backend.repository.catalog.GenreRepository;
import com.calonuria.backend.repository.catalog.MangaRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class MangaService extends BaseCatalogService<Manga, MangaResponseDTO, Long> {

    private final MangaRepository mangaRepository;
    private final GenreRepository genreRepository;

    public MangaService(MangaRepository mangaRepository, GenreRepository genreRepository) {
        super(mangaRepository);
        this.mangaRepository = mangaRepository;
        this.genreRepository = genreRepository;
    }

    @Transactional
    public Manga findOrCreate(Long mangaId, Integer malId) {
        if (mangaId != null) {
            return mangaRepository.findById(mangaId)
                    .orElseThrow(() -> new ResourceNotFoundException("Manga no encontrado con id: " + mangaId));
        }

        if (malId != null) {
            return mangaRepository.findByMalId(malId)
                    .orElseThrow(() -> new ResourceNotFoundException("Manga no encontrado con malId: " + malId));
        }

        throw new IllegalArgumentException("Se debe proporcionar un mangaId o un malId para encontrar un manga.");
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
        if (manga.getGenres() != null) {
            dto.setGenres(manga.getGenres().stream().map(Genre::getName).collect(Collectors.toList()));
        }
        dto.setDescription(manga.getDescription());
        dto.setCoverUrl(manga.getCoverUrl());
        dto.setTotalChapters(manga.getTotalChapters());
        dto.setTotalVolumes(manga.getTotalVolumes());
        dto.setPublicationStatus(manga.getPublicationStatus());
        dto.setMalScore(manga.getMalScore());
        return dto;
    }

    public Optional<MangaResponseDTO> updateManga(Long id, MangaResponseDTO dto) {
        return mangaRepository.findById(id)
                .map(manga -> {
                    manga.setTitle(dto.getTitle());
                    manga.setAuthor(dto.getAuthor());
                    manga.setDemographic(dto.getDemographic());
                    manga.setDescription(dto.getDescription());
                    manga.setCoverUrl(dto.getCoverUrl());
                    manga.setTotalChapters(dto.getTotalChapters());
                    manga.setTotalVolumes(dto.getTotalVolumes());
                    manga.setPublicationStatus(dto.getPublicationStatus());
                    manga.setMalScore(dto.getMalScore());

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
                        manga.setGenres(genres);
                    }

                    return mapToDTO(mangaRepository.save(manga));
                });
    }

    @Override
    public List<MangaResponseDTO> searchByTitle(String title) {
        return mangaRepository.findByTitleContainingIgnoreCase(title)
                .stream().map(this::mapToDTO).collect(Collectors.toList());
    }
}
