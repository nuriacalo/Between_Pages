package com.calonuria.backend.features.crawler.controller;

import com.calonuria.backend.features.catalog.dto.FanfictionResponseDTO;
import com.calonuria.backend.features.catalog.model.Fanfiction;
import com.calonuria.backend.features.crawler.dto.Ao3CrawlRequestDTO;
import com.calonuria.backend.features.crawler.service.Ao3CrawlerService;
import com.calonuria.backend.features.catalog.service.FanficService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * REST Controller that handles HTTP requests for crawling fanfictions from Archive of Our Own (AO3).
 * Interacts with the {@link Ao3CrawlerService} to scrape and parse AO3 work URLs.
 * 
 * <p>Base path: {@code /api/crawler/ao3}</p>
 */
@RestController
@RequestMapping("/api/crawler/ao3")
@RequiredArgsConstructor
@Tag(name = "AO3 Crawler", description = "Herramienta para extraer metadatos de fanfictions directamente desde Archive of Our Own")
public class Ao3CrawlerController {

    private final Ao3CrawlerService ao3CrawlerService;
    private final FanficService fanficService;

    /**
     * Crawls an AO3 work using its URL or direct ID.
     * Extracts metadata (title, author, summary, tags, relationships) and saves it to the local catalog.
     *
     * @param request the request payload containing the AO3 URL or ID
     * @return a {@link ResponseEntity} containing the extracted and mapped {@link FanfictionResponseDTO}
     */
    @Operation(summary = "Extraer información de un fanfic desde AO3",
               description = "Extrae título, autor, resumen y tags desde una URL válida de AO3")
    @PostMapping
    public ResponseEntity<FanfictionResponseDTO> crawlWork(@Valid @RequestBody Ao3CrawlRequestDTO request) {
        // Obtenemos la entidad (crawleada o desde la BD)
        Fanfiction fanfic = ao3CrawlerService.crawlWork(request.ao3Input());

        // La devolvemos como DTO utilizando el servicio
        FanfictionResponseDTO response = fanficService.mapToDTO(fanfic);

        return ResponseEntity.ok(response);
    }
}