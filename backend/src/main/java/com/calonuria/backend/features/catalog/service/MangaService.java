package com.calonuria.backend.features.catalog.service;

import com.calonuria.backend.features.catalog.dto.MangaResponseDTO;
import com.calonuria.backend.features.catalog.service.external.JikanService;
import com.calonuria.backend.shared.exception.ResourceNotFoundException;
import com.calonuria.backend.features.catalog.model.Genre;
import com.calonuria.backend.features.catalog.model.Manga;
import com.calonuria.backend.features.catalog.repository.GenreRepository;
import com.calonuria.backend.features.catalog.repository.MangaRepository;
import com.calonuria.backend.shared.service.BaseCatalogService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * Service class for managing manga entities within the local catalog.
 * Handles creation, updates, querying, and DTO mapping for mangas.
 * Designed to interact cooperatively with external synchronization services (e.g., Jikan API).
 */
@Service
public class MangaService extends BaseCatalogService<Manga, MangaResponseDTO, Long> {

    private final MangaRepository mangaRepository;
    private final GenreRepository genreRepository;
    private final JikanService jikanService;

    /**
     * Constructs a new {@code MangaService}.
     *
     * @param mangaRepository the repository for manga persistence
     * @param genreRepository the repository for genre persistence
     */
    public MangaService(MangaRepository mangaRepository, GenreRepository genreRepository, JikanService jikanService) {
        super(mangaRepository);
        this.mangaRepository = mangaRepository;
        this.genreRepository = genreRepository;
        this.jikanService = jikanService;
    }

    /**
     * Retrieves a manga from the local database using either its internal ID or its MyAnimeList ID.
     * Note: Unlike books or fanfics, if a manga does not exist by its MAL ID, this method
     * throws an exception rather than fetching it automatically. External fetch logic should
     * be handled by the Jikan API controller.
     *
     * @param mangaId the local database ID (optional)
     * @param malId   the MyAnimeList ID (optional)
     * @return the found {@link Manga} entity
     * @throws ResourceNotFoundException if the manga is not found locally
     * @throws IllegalArgumentException  if both IDs are null
     */
    @Transactional
    public Manga findOrCreate(Long mangaId, Integer malId) {
        if (mangaId != null) {
            return mangaRepository.findById(mangaId)
                    .orElseThrow(() -> new ResourceNotFoundException("Manga no encontrado con id: " + mangaId));
        }

        if (malId != null) {
            return mangaRepository.findByMalId(malId)
                    .orElseGet(() -> {
                        MangaResponseDTO dto = jikanService.getMangaById(malId);
                        if (dto == null) {
                            throw new ResourceNotFoundException("Manga con malId " + malId + " no encontrado en la base de datos local ni en Jikan.");
                        }
                        return createMangaFromDTO(dto);
                    });
        }

        throw new IllegalArgumentException("Se debe proporcionar un mangaId o un malId para encontrar un manga.");
    }

    /**
     * Converts a raw {@link Manga} entity into its corresponding DTO format.
     *
     * @param manga the entity to map
     * @return the mapped {@link MangaResponseDTO}
     */
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

    /**
     * Creates a new manual manga entry in the catalog.
     *
     * @param dto the data payload for the new manga
     * @return the saved and mapped {@link MangaResponseDTO}
     */
    @Transactional
    public MangaResponseDTO createManga(MangaResponseDTO dto) {
        Manga manga = createMangaFromDTO(dto);
        manga.setSource("MANUAL");
        Manga savedManga = mangaRepository.save(manga);
        return mapToDTO(savedManga);
    }

    private Manga createMangaFromDTO(MangaResponseDTO dto) {
        Manga manga = new Manga();
        manga.setMalId(dto.getMalId());
        manga.setTitle(dto.getTitle());
        manga.setAuthor(dto.getAuthor());
        manga.setDemographic(dto.getDemographic());
        manga.setDescription(dto.getDescription());
        manga.setCoverUrl(dto.getCoverUrl());
        manga.setTotalChapters(dto.getTotalChapters());
        manga.setTotalVolumes(dto.getTotalVolumes());
        manga.setPublicationStatus(dto.getPublicationStatus());
        manga.setMalScore(dto.getMalScore());
        manga.setSource(dto.getSource());

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
        return mangaRepository.save(manga);
    }

    /**
     * Updates an existing manga record with the properties provided in the DTO.
     *
     * @param id  the local database ID of the manga to update
     * @param dto the data to apply
     * @return an {@link Optional} containing the updated DTO, or empty if not found
     */
    @Transactional
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

    /**
     * Searches for mangas matching the given title query, ignoring case.
     *
     * @param title the substring to search for in manga titles
     * @return a list of {@link MangaResponseDTO} matching the query
     */
    @Override
    public List<MangaResponseDTO> searchByTitle(String title) {
        return mangaRepository.findByTitleContainingIgnoreCase(title)
                .stream().map(this::mapToDTO).collect(Collectors.toList());
    }
}