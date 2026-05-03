package com.calonuria.backend.service.catalog;

import com.calonuria.backend.dto.catalog.MangaResponseDTO;
import com.calonuria.backend.model.catalog.Manga;
import com.calonuria.backend.repository.catalog.MangaRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Servicio para la gestión de mangas en el catálogo.
 * Integra con Jikan API (MyAnimeList) para búsquedas externas.
 */
@Service
public class MangaService {

    private static final Logger log = LoggerFactory.getLogger(MangaService.class);

    private final MangaRepository mangaRepository;
    private final RestTemplate restTemplate;

    public MangaService(MangaRepository mangaRepository, RestTemplate restTemplate) {
        this.mangaRepository = mangaRepository;
        this.restTemplate = restTemplate;
    }

    /**
     * Guarda un manga solo si no existe ya por malId.
     * @param manga manga a guardar
     * @return DTO con la información del manga guardado
     */
    public MangaResponseDTO saveIfNotExists(Manga manga) {
        if (manga.getMalId() != null) {
            Optional<Manga> existing = mangaRepository.findByMalId(manga.getMalId());
            if (existing.isPresent()) {
                return mapToDTO(existing.get());
            }
        }
        return mapToDTO(mangaRepository.save(manga));
    }

    /**
     * Obtiene un manga por su ID.
     * @param id ID del manga
     * @return Optional con el DTO del manga
     */
    public Optional<MangaResponseDTO> getMangaById(Long id) {
        return mangaRepository.findById(id).map(this::mapToDTO);
    }

    /**
     * Busca mangas en Jikan API (MyAnimeList).
     * @param title título a buscar
     * @return lista de mangas encontrados
     */
    public List<MangaResponseDTO> searchInJikan(String title) {
        String url = "https://api.jikan.moe/v4/manga?q=" + title + "&limit=10";
        List<MangaResponseDTO> results = new ArrayList<>();

        try {
            String json = restTemplate.getForObject(url, String.class);
            JsonNode data = new ObjectMapper().readTree(json).path("data");

            if (data.isArray()) {
                for (JsonNode item : data) {
                    MangaResponseDTO dto = new MangaResponseDTO();
                    
                    // mal_id desde Jikan API
                    JsonNode malIdNode = item.path("mal_id");
                    if (!malIdNode.isMissingNode() && !malIdNode.isNull()) {
                        dto.setMalId(malIdNode.asInt());
                    }

                    // Título
                    dto.setTitle(item.path("title").asText("Título desconocido"));

                    // Descripción
                    dto.setDescription(item.path("synopsis").asText(null));

                    // Autor
                    JsonNode authors = item.path("authors");
                    if (authors.isArray() && authors.size() > 0) {
                        dto.setAuthor(authors.get(0).path("name").asText("Desconocido"));
                    } else {
                        dto.setAuthor("Desconocido");
                    }

                    // Estado - mapear valores de Jikan a valores de BD
                    dto.setPublicationStatus(mapJikanStatus(item.path("status").asText(null)));

                    // Demografía
                    JsonNode demographics = item.path("demographics");
                    if (demographics.isArray() && demographics.size() > 0) {
                        dto.setDemographic(demographics.get(0).path("name").asText(null));
                    }

                    // Géneros
                    JsonNode genres = item.path("genres");
                    if (genres.isArray() && genres.size() > 0) {
                        dto.setGenre(genres.get(0).path("name").asText(null));
                    }

                    // Portada
                    JsonNode images = item.path("images");
                    if (!images.isMissingNode()) {
                        String coverUrl = images.path("jpg").path("image_url").asText(null);
                        if (coverUrl == null) {
                            coverUrl = images.path("webp").path("image_url").asText(null);
                        }
                        dto.setCoverUrl(coverUrl);
                    }

                    // Capítulos y volúmenes
                    dto.setTotalChapters(item.path("chapters").asInt());
                    dto.setTotalVolumes(item.path("volumes").asInt());

                    // Score de MAL
                    JsonNode score = item.path("score");
                    if (!score.isMissingNode() && !score.isNull()) {
                        dto.setMalScore(new java.math.BigDecimal(score.asDouble()));
                    }

                    results.add(dto);
                }
            }
        } catch (Exception e) {
            log.error("Error al conectar con Jikan API: {}", e.getMessage());
        }

        return results;
    }

    /**
     * Busca mangas en la base de datos local.
     * @param title título a buscar
     * @return lista de mangas encontrados
     */
    public List<MangaResponseDTO> searchInDatabase(String title) {
        return mangaRepository.findByTitleContainingIgnoreCase(title)
                .stream().map(this::mapToDTO).collect(Collectors.toList());
    }

    /**
     * Obtiene todos los mangas del catálogo.
     * @return lista de todos los mangas
     */
    public List<MangaResponseDTO> getAllMangas() {
        return mangaRepository.findAll().stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    /**
     * Mapea un manga a su DTO de respuesta.
     * @param manga manga
     * @return DTO de respuesta
     */
    public MangaResponseDTO mapToDTO(Manga manga) {
        MangaResponseDTO dto = new MangaResponseDTO();
        dto.setId(manga.getId());
        dto.setMalId(manga.getMalId());
        dto.setMalScore(manga.getMalScore());
        dto.setSource(manga.getSource());
        dto.setTitle(manga.getTitle());
        dto.setAuthor(manga.getAuthor());
        dto.setDemographic(manga.getDemographic());
        dto.setGenre(manga.getGenre());
        dto.setDescription(manga.getDescription());
        dto.setCoverUrl(manga.getCoverUrl());
        dto.setTotalChapters(manga.getTotalChapters());
        dto.setTotalVolumes(manga.getTotalVolumes());
        dto.setPublicationStatus(manga.getPublicationStatus());
        return dto;
    }

    /**
     * Mapea el estado de publicación de Jikan API a valores de BD.
     * BD espera: 'Publishing', 'Finished', 'On Hiatus', 'Discontinued', 'Not yet published'
     */
    private String mapJikanStatus(String jikanStatus) {
        if (jikanStatus == null) return null;

        return switch (jikanStatus.toLowerCase()) {
            case "publishing" -> "Publishing";
            case "finished", "completed" -> "Finished";
            case "on_hiatus", "hiatus" -> "On Hiatus";
            case "discontinued", "cancelled", "canceled" -> "Discontinued";
            case "not_yet_published" -> "Not yet published";
            default -> {
                log.warn("Estado de manga desconocido de Jikan: {}", jikanStatus);
                yield jikanStatus;
            }
        };
    }
}