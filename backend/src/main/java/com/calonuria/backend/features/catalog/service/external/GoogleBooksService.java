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

import java.util.ArrayList;
import java.util.List;

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
                .queryParam("q", "intitle:" + title)
                .queryParam("maxResults", 10);

        if (StringUtils.hasText(googleBooksConfig.getApiKey())) {
            urlBuilder.queryParam("key", googleBooksConfig.getApiKey());
        }

        String url = urlBuilder.build().encode().toUriString();
        List<BookResponseDTO> results = new ArrayList<>();

        try {
            String jsonResponse = restTemplate.getForObject(url, String.class);
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
            // En caso de error, devolvemos una lista vacía. El controlador local se encargará del fallback si es necesario.
        }
        return results;
    }
    
    public Book fetchBookByGoogleId(String googleBooksId) {
        UriComponentsBuilder urlBuilder = UriComponentsBuilder
                .fromHttpUrl(GOOGLE_BOOKS_API_URL + "/")
                .path(googleBooksId);

        if (StringUtils.hasText(googleBooksConfig.getApiKey())) {
            urlBuilder.queryParam("key", googleBooksConfig.getApiKey());
        }
        String url = urlBuilder.build().encode().toUriString();

        try {
            String json = restTemplate.getForObject(url, String.class);
            JsonNode root = objectMapper.readTree(json);
            return parseBookFromJsonNode(root);
        } catch (Exception e) {
            log.error("Error al obtener libro de Google Books por ID '{}': {}", googleBooksId, e.getMessage());
            throw new ResourceNotFoundException("No se pudo obtener la información del libro desde Google Books para el ID: " + googleBooksId);
        }
    }

    private BookResponseDTO mapGoogleBookToDTO(JsonNode item) {
        Book book = parseBookFromJsonNode(item);
        BookResponseDTO dto = new BookResponseDTO();
        dto.setGoogleBooksId(book.getGoogleBooksId());
        dto.setTitle(book.getTitle());
        dto.setAuthor(book.getAuthor());
        dto.setIsbn(book.getIsbn());
        dto.setPublisher(book.getPublisher());
        dto.setDescription(book.getDescription());
        dto.setCoverUrl(book.getCoverUrl());
        // Los géneros se parsean pero no se guardan en el DTO directamente aquí
        // porque no tenemos la entidad Genre. El DTO solo lleva los nombres.
        dto.setPublicationYear(book.getPublicationYear());
        dto.setPageCount(book.getPageCount());
        return dto;
    }

    private Book parseBookFromJsonNode(JsonNode item) {
        JsonNode info = item.path("volumeInfo");
        Book book = new Book();

        book.setGoogleBooksId(item.path("id").asText(null));
        book.setTitle(info.path("title").asText("Título desconocido"));

        if (info.path("authors").isArray() && info.path("authors").size() > 0) {
            book.setAuthor(info.path("authors").get(0).asText());
        } else {
            book.setAuthor("Autor desconocido");
        }

        book.setPublisher(info.path("publisher").asText(null));
        book.setDescription(info.path("description").asText(null));
        book.setPageCount(info.path("pageCount").asInt(0));

        JsonNode isbnNodes = info.path("industryIdentifiers");
        if (isbnNodes.isArray()) {
            for (JsonNode isbnNode : isbnNodes) {
                String type = isbnNode.path("type").asText();
                if ("ISBN_13".equals(type)) {
                    book.setIsbn(isbnNode.path("identifier").asText(null));
                    break;
                }
                if ("ISBN_10".equals(type)) {
                    book.setIsbn(isbnNode.path("identifier").asText(null));
                }
            }
        }

        JsonNode cover = info.path("imageLinks");
        if (!cover.isMissingNode()) {
            String thumbnailUrl = cover.path("thumbnail").asText(null);
            if (thumbnailUrl != null && thumbnailUrl.startsWith("http:")) {
                thumbnailUrl = thumbnailUrl.replace("http:", "https:");
            }
            book.setCoverUrl(thumbnailUrl);
        }

        String date = info.path("publishedDate").asText("");
        if (date.length() >= 4) {
            try {
                book.setPublicationYear(Integer.parseInt(date.substring(0, 4)));
            } catch (NumberFormatException e) {
                book.setPublicationYear(null);
            }
        }
        
        book.setBookType("STANDALONE");
        return book;
    }
}
