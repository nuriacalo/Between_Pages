package com.calonuria.backend.features.crawler.service;

import com.calonuria.backend.features.catalog.model.FanficTag;
import com.calonuria.backend.features.catalog.model.Fanfiction;
import com.calonuria.backend.features.catalog.repository.FanficTagRepository;
import com.calonuria.backend.features.catalog.repository.FanfictionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class Ao3CrawlerService {

    private final FanfictionRepository fanfictionRepository;
    private final FanficTagRepository fanficTagRepository;

    private static final String BASE_URL = "https://archiveofourown.org/works/";

    @Transactional
    public Fanfiction crawlWork(String ao3Input) {
        String ao3Id = extractId(ao3Input);

        Optional<Fanfiction> existing = fanfictionRepository.findByAo3Id(ao3Id);
        if (existing.isPresent()) {
            log.info("La fanfic con ao3_id {} ya existe en la BD.", ao3Id);
            Fanfiction fanfic = existing.get();
            // Forzamos la inicialización de colecciones Lazy para evitar LazyInitializationException en el mapeo a DTO
            fanfic.getGenres().size();
            fanfic.getTags().size();
            return fanfic;
        }

        String url = BASE_URL + ao3Id + "?view_adult=true";
        log.info("Crawleando AO3: {}", url);

        try {
            Document doc = Jsoup.connect(url)
                    .userAgent("Mozilla/5.0 (compatible; BetweenPages-personal/1.0)")
                    .referrer("https://archiveofourown.org")
                    .timeout(15000)
                    .get();

            Fanfiction fanfic = new Fanfiction();
            fanfic.setAo3Id(ao3Id);

            Element titleEl = doc.selectFirst("h2.title.heading");
            fanfic.setTitle(titleEl != null ? titleEl.text().trim() : "Sin título");

            Element authorEl = doc.selectFirst("h3.byline.heading a[rel=author]");
            fanfic.setAuthor(authorEl != null ? authorEl.text().trim() : "Anonymous");

            Elements fandoms = doc.select(".fandom.tags a.tag");
            String sourceMaterial = fandoms.stream()
                    .map(Element::text)
                    .reduce("", (a, b) -> a.isEmpty() ? b : a + ", " + b);
            fanfic.setSourceMaterial(sourceMaterial);

            Element summaryEl = doc.selectFirst(".summary blockquote.userstuff");
            fanfic.setDescription(summaryEl != null ? summaryEl.text().trim() : "");

            Element chaptersEl = doc.selectFirst("dd.chapters");
            if (chaptersEl != null) {
                String[] parts = chaptersEl.text().split("/");
                try {
                    fanfic.setCurrentChapter(Integer.parseInt(parts[0].trim().replace(",", "")));
                } catch (NumberFormatException e) {
                    fanfic.setCurrentChapter(0);
                }
                try {
                    fanfic.setTotalChapters("?".equals(parts[1].trim())
                            ? null
                            : Integer.parseInt(parts[1].trim().replace(",", "")));
                } catch (Exception e) {
                    fanfic.setTotalChapters(null);
                }
            }

            boolean isComplete = doc.select(".status").text().toLowerCase().contains("complete");
            boolean isOneShot  = fanfic.getTotalChapters() != null && fanfic.getTotalChapters() == 1;
            if (isComplete || isOneShot) {
                fanfic.setPublicationStatus("COMPLETED");
            } else {
                fanfic.setPublicationStatus("ONGOING");
            }

            Element shipEl = doc.selectFirst(".relationship.tags a.tag");
            if (shipEl != null) fanfic.setMainShip(shipEl.text().trim());

            Fanfiction saved = fanfictionRepository.save(fanfic);

            Elements freeformTags = doc.select(".freeform.tags a.tag");
            for (Element tagEl : freeformTags) {
                FanficTag tag = new FanficTag();
                tag.setFanfic(saved); // CORREGIDO AQUÍ
                tag.setTag(tagEl.text().trim());
                fanficTagRepository.save(tag);
                saved.getTags().add(tag); // Lo añadimos a la entidad para que llegue al frontend en la primera carga
            }
            
            // Inicializamos la colección vacía por seguridad del proxy de Hibernate
            saved.getGenres().size();

            log.info("Fanfic '{}' guardada con id {}", saved.getTitle(), saved.getId());
            return saved;

        } catch (IOException e) {
            log.error("Error al crawlear AO3 (id: {}): {}", ao3Id, e.getMessage());
            throw new RuntimeException("No se pudo crawlear la obra de AO3. Revisa la URL o el ID.", e);
        }
    }

    private String extractId(String input) {
        if (input == null || input.isBlank()) {
            throw new IllegalArgumentException("La URL o ID de AO3 está vacía.");
        }
        String trimmed = input.trim();
        if (trimmed.contains("archiveofourown.org/works/")) {
            String[] parts = trimmed.split("/works/");
            return parts[1].split("[/?]")[0].trim();
        }
        if (trimmed.matches("\\d+")) {
            return trimmed;
        }
        throw new IllegalArgumentException("Formato de URL o ID de AO3 no reconocido: " + input);
    }
}