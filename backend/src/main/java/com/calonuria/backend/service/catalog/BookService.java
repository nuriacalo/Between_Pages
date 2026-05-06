package com.calonuria.backend.service.catalog;

import com.calonuria.backend.config.GoogleBooksConfig;
import com.calonuria.backend.dto.catalog.BookResponseDTO;
import com.calonuria.backend.model.catalog.Book;
import com.calonuria.backend.repository.catalog.BookRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;
import org.springframework.util.StringUtils;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Servicio para la gestión de libros en el catálogo.
 * Integra con Google Books API para búsquedas externas.
 */
@Service
public class BookService extends BaseCatalogService<Book, BookResponseDTO, Long> {

    private static final Logger log = LoggerFactory.getLogger(BookService.class);

    private final BookRepository bookRepository;
    private final RestTemplate restTemplate;
    private final GoogleBooksConfig googleBooksConfig;

    public BookService(BookRepository bookRepository,
                       RestTemplate restTemplate,
                       GoogleBooksConfig googleBooksConfig) {
        super(bookRepository);
        this.bookRepository = bookRepository;
        this.restTemplate = restTemplate;
        this.googleBooksConfig = googleBooksConfig;
    }

    /**
     * Guarda un libro solo si no existe ya por googleBooksId.
     * @param book libro a guardar
     * @return DTO con la información del libro guardado
     */
    public BookResponseDTO saveIfNotExists(Book book) {
        if (book.getGoogleBooksId() != null) {
            Optional<Book> existing = bookRepository.findByGoogleBooksId(book.getGoogleBooksId());
            if (existing.isPresent()) {
                return mapToDTO(existing.get());
            }
        }
        return saveAndMap(book);
    }

    /**
     * Crea y guarda un libro desde un DTO si no existe.
     * @param dto DTO con los datos del libro
     * @return DTO con la información del libro guardado
     */
    public BookResponseDTO saveFromDTO(BookResponseDTO dto) {
        Book book = new Book();
        book.setGoogleBooksId(dto.getGoogleBooksId());
        book.setTitle(dto.getTitle());
        book.setAuthor(dto.getAuthor());
        book.setIsbn(dto.getIsbn());
        book.setPublisher(dto.getPublisher());
        book.setDescription(dto.getDescription());
        book.setCoverUrl(dto.getCoverUrl());
        book.setGenre(dto.getGenre());
        book.setBookType(dto.getBookType());
        book.setPublicationYear(dto.getPublicationYear());
        return saveIfNotExists(book);
    }

    // Alias para compatibilidad con controllers existentes
    public Optional<BookResponseDTO> getBookById(Long id) {
        return findById(id);
    }

    /**
     * Busca libros en Google Books API.
     * @param title título a buscar
     * @return lista de libros encontrados
     */
    public List<BookResponseDTO> searchInGoogleBooks(String title) {
        UriComponentsBuilder urlBuilder = UriComponentsBuilder
                .fromHttpUrl("https://www.googleapis.com/books/v1/volumes")
                .queryParam("q", "intitle:" + title)
                .queryParam("maxResults", 10);

        if (StringUtils.hasText(googleBooksConfig.getApiKey())) {
            urlBuilder.queryParam("key", googleBooksConfig.getApiKey());
        }

        String url = urlBuilder.build().encode().toUriString();

        List<BookResponseDTO> results = new ArrayList<>();

        try {
            String json = restTemplate.getForObject(url, String.class);
            if (!StringUtils.hasText(json)) {
                log.warn("Google Books devolvió una respuesta vacía para el título '{}'", title);
                return searchByTitle(title);
            }

            JsonNode root = new ObjectMapper().readTree(json);
            JsonNode error = root.path("error");
            if (!error.isMissingNode()) {
                log.warn("Google Books devolvió error {} para '{}': {}",
                        error.path("code").asInt(),
                        title,
                        error.path("message").asText("sin mensaje"));
                return searchByTitle(title);
            }

            JsonNode items = root.path("items");

            if (items.isArray()) {
                for (JsonNode item : items) {
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

                    JsonNode isbn = info.path("industryIdentifiers");
                    if (isbn.isArray() && isbn.size() > 0) {
                        dto.setIsbn(isbn.get(0).path("identifier").asText(null));
                    }

                    JsonNode categories = info.path("categories");
                    if (categories.isArray() && categories.size() > 0) {
                        dto.setGenre(categories.get(0).asText(null));
                    }

                    JsonNode cover = info.path("imageLinks");
                    if (!cover.isMissingNode()) {
                        String thumbnailUrl = cover.path("thumbnail").asText(null);
                        // Convertir HTTP a HTTPS para evitar problemas de carga en móviles
                        if (thumbnailUrl != null && thumbnailUrl.startsWith("http:")) {
                            thumbnailUrl = thumbnailUrl.replace("http:", "https:");
                        }
                        if (thumbnailUrl != null) {
                            log.info("Cover URL para '{}': {}", dto.getTitle(), thumbnailUrl);
                        } else {
                            log.warn("No hay thumbnail para: {}", dto.getTitle());
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

                    results.add(dto);
                }
            }
        } catch (Exception e) {
            log.error("Error al conectar con Google Books para '{}': {}", title, e.getMessage());
            return searchByTitle(title);
        }

        if (results.isEmpty()) {
            log.info("No se encontraron resultados en Google Books para '{}', buscando en BD local", title);
            return searchByTitle(title);
        }

        log.info("Enviando {} libros para '{}':", results.size(), title);
        for (BookResponseDTO r : results) {
            log.info("  - {} | coverUrl: {}", r.getTitle(), r.getCoverUrl());
        }

        return results;
    }

    @Override
    public List<BookResponseDTO> searchByTitle(String title) {
        return bookRepository.findByTitleContainingIgnoreCase(title)
                .stream().map(this::mapToDTO).collect(Collectors.toList());
    }

    public List<BookResponseDTO> searchInDatabase(String title) {
        return searchByTitle(title);
    }

    // Alias para compatibilidad con controllers existentes
    public List<BookResponseDTO> getAllBooks() {
        return findAll();
    }

    /**
     * Mapea un libro a su DTO de respuesta.
     * @param book libro
     * @return DTO de respuesta
     */
    @Override
    public BookResponseDTO mapToDTO(Book book) {
        BookResponseDTO dto = new BookResponseDTO();
        dto.setId(book.getId());
        dto.setGoogleBooksId(book.getGoogleBooksId());
        dto.setTitle(book.getTitle());
        dto.setAuthor(book.getAuthor());
        dto.setIsbn(book.getIsbn());
        dto.setPublisher(book.getPublisher());
        dto.setDescription(book.getDescription());
        dto.setCoverUrl(book.getCoverUrl());
        dto.setGenre(book.getGenre());
        dto.setBookType(book.getBookType());
        dto.setPublicationYear(book.getPublicationYear());
        return dto;
    }
}