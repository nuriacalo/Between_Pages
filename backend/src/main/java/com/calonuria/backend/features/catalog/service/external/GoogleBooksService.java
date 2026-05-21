package com.calonuria.backend.features.catalog.service.external;

import com.calonuria.backend.features.catalog.dto.BookResponseDTO;
import com.calonuria.backend.features.catalog.model.Book;
import com.calonuria.backend.shared.config.GoogleBooksConfig;
import com.calonuria.backend.shared.exception.ResourceNotFoundException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;
import org.springframework.util.StringUtils;

import java.net.URI;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.StreamSupport;

@Service
@RequiredArgsConstructor
public class GoogleBooksService {

    private static final Logger log = LoggerFactory.getLogger(GoogleBooksService.class);
    private static final String GOOGLE_BOOKS_API_URL = "https://www.googleapis.com/books/v1/volumes";

    private final RestTemplate restTemplate;
    private final GoogleBooksConfig googleBooksConfig;
    private final ObjectMapper objectMapper;

    public List<BookResponseDTO> searchBooks(String title) {
        UriComponentsBuilder urlBuilder = UriComponentsBuilder
                .fromHttpUrl(GOOGLE_BOOKS_API_URL)
                .queryParam("q", title)
                .queryParam("maxResults", 10)
                .queryParam("printType", "books");

        if (StringUtils.hasText(googleBooksConfig.getApiKey())) {
            urlBuilder.queryParam("key", googleBooksConfig.getApiKey());
        }

        URI uri = urlBuilder.build().encode().toUri();
        List<BookResponseDTO> results = new ArrayList<>();

        try {
            String jsonResponse = restTemplate.getForObject(uri, String.class);
            if (!StringUtils.hasText(jsonResponse)) {
                log.warn("Google Books devolvió una respuesta vacía para el título '{}'", title);
                return results;
            }

            JsonNode root = objectMapper.readTree(jsonResponse);
            JsonNode items = root.path("items");

            if (items.isArray()) {
                for (JsonNode item : items) {
                    results.add(mapGoogleBookToDTO(item));
                }
            }
        } catch (Exception e) {
            log.error("Error al conectar con Google Books para '{}': {}", title, e.getMessage());
        }
        return results;
    }

    public BookResponseDTO fetchBookByGoogleId(String googleBooksId) {
        UriComponentsBuilder urlBuilder = UriComponentsBuilder
                .fromHttpUrl(GOOGLE_BOOKS_API_URL + "/")
                .path(googleBooksId);

        if (StringUtils.hasText(googleBooksConfig.getApiKey())) {
            urlBuilder.queryParam("key", googleBooksConfig.getApiKey());
        }
        URI uri = urlBuilder.build().encode().toUri();

        try {
            String json = restTemplate.getForObject(uri, String.class);
            JsonNode root = objectMapper.readTree(json);
            return mapGoogleBookToDTO(root);
        } catch (Exception e) {
            log.error("Error al obtener libro de Google Books por ID '{}': {}", googleBooksId, e.getMessage());
            throw new ResourceNotFoundException("No se pudo obtener la información del libro desde Google Books para el ID: " + googleBooksId);
        }
    }

    private BookResponseDTO mapGoogleBookToDTO(JsonNode item) {
        JsonNode info = item.path("volumeInfo");
        BookResponseDTO dto = new BookResponseDTO();

        dto.setGoogleBooksId(item.path("id").asText(null));
        dto.setTitle(info.path("title").asText("Título desconocido"));

        if (info.path("authors").isArray() && info.path("authors").size() > 0) {
            dto.setAuthor(info.path("authors").get(0).asText());
        } else {
            dto.setAuthor("Autor desconocido");
        }

        dto.setPublisher(info.path("publisher").asText(null));
        dto.setDescription(info.path("description").asText(null));
        dto.setPageCount(info.path("pageCount").asInt(0));

        JsonNode isbnNodes = info.path("industryIdentifiers");
        if (isbnNodes.isArray()) {
            for (JsonNode isbnNode : isbnNodes) {
                String type = isbnNode.path("type").asText();
                if ("ISBN_13".equals(type)) {
                    dto.setIsbn(isbnNode.path("identifier").asText(null));
                    break;
                }
                if ("ISBN_10".equals(type)) {
                    dto.setIsbn(isbnNode.path("identifier").asText(null));
                }
            }
        }

        JsonNode cover = info.path("imageLinks");
        if (!cover.isMissingNode()) {
            String thumbnailUrl = cover.path("thumbnail").asText(null);
            if (thumbnailUrl != null && thumbnailUrl.startsWith("http:")) {
                thumbnailUrl = thumbnailUrl.replace("http:", "https:");
            }
            dto.setCoverUrl(thumbnailUrl);
        }

        String date = info.path("publishedDate").asText("");
        if (date.length() >= 4) {
            try {
                dto.setPublicationYear(Integer.parseInt(date.substring(0, 4)));
            } catch (NumberFormatException e) {
                dto.setPublicationYear(null);
            }
        }

        if (info.has("categories") && info.get("categories").isArray()) {
            List<String> genres = StreamSupport.stream(info.get("categories").spliterator(), false)
                    .map(JsonNode::asText)
                    .collect(Collectors.toList());
            dto.setGenres(genres);
        }

        dto.setBookType("STANDALONE");
        return dto;
    }
}