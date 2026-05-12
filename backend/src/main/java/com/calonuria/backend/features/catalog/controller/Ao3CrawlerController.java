package com.calonuria.backend.features.catalog.controller;

import com.calonuria.backend.features.catalog.dto.Ao3CrawlRequestDTO;
import com.calonuria.backend.features.catalog.dto.FanfictionResponseDTO;
import com.calonuria.backend.features.catalog.model.Fanfiction;
import com.calonuria.backend.features.catalog.service.external.Ao3CrawlerService;
import com.calonuria.backend.features.catalog.service.FanficService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/crawler/ao3")
@RequiredArgsConstructor
public class Ao3CrawlerController {

    private final Ao3CrawlerService ao3CrawlerService;
    private final FanficService fanficService;

    @PostMapping
    public ResponseEntity<FanfictionResponseDTO> crawlWork(@Valid @RequestBody Ao3CrawlRequestDTO request) {
        // Obtenemos la entidad (crawleada o desde la BD)
        Fanfiction fanfic = ao3CrawlerService.crawlWork(request.ao3Input());

        // La devolvemos como DTO utilizando el servicio
        FanfictionResponseDTO response = fanficService.mapToDTO(fanfic);

        return ResponseEntity.ok(response);
    }
}