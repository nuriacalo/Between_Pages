package com.calonuria.backend.features.catalog.service;

import com.calonuria.backend.features.catalog.dto.UserCatalogEntryDTO;
import com.calonuria.backend.features.catalog.model.UserCatalog;
import com.calonuria.backend.features.catalog.repository.BookRepository;
import com.calonuria.backend.features.catalog.repository.FanfictionRepository;
import com.calonuria.backend.features.catalog.repository.MangaRepository;
import com.calonuria.backend.features.catalog.repository.UserCatalogRepository;
import com.calonuria.backend.features.user.repository.UserRepository;
import com.calonuria.backend.shared.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserCatalogService {

    private final UserCatalogRepository userCatalogRepository;
    private final UserRepository userRepository;
    private final BookRepository bookRepository;
    private final MangaRepository mangaRepository;
    private final FanfictionRepository fanfictionRepository;

    @Transactional
    public UserCatalog addToCatalog(UserCatalogEntryDTO dto) {
        final var user = userRepository.findById(dto.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("Usuario no encontrado"));

        UserCatalog entry = new UserCatalog();
        entry.setUser(user);
        entry.setItemType(dto.getItemType());

        switch (dto.getItemType()) {
            case "BOOK":
                final var book = bookRepository.findById(dto.getBookId())
                        .orElseThrow(() -> new ResourceNotFoundException("Libro no encontrado"));
                entry.setBook(book);
                // Evitar duplicados
                userCatalogRepository.findByUserAndBook(user, book).ifPresent(e -> {
                    throw new IllegalStateException("El libro ya está en el catálogo del usuario.");
                });
                break;
            case "MANGA":
                final var manga = mangaRepository.findById(dto.getMangaId())
                        .orElseThrow(() -> new ResourceNotFoundException("Manga no encontrado"));
                entry.setManga(manga);
                userCatalogRepository.findByUserAndManga(user, manga).ifPresent(e -> {
                    throw new IllegalStateException("El manga ya está en el catálogo del usuario.");
                });
                break;
            case "FANFIC":
                final var fanfic = fanfictionRepository.findById(dto.getFanficId())
                        .orElseThrow(() -> new ResourceNotFoundException("Fanfic no encontrado"));
                entry.setFanfic(fanfic);
                userCatalogRepository.findByUserAndFanfic(user, fanfic).ifPresent(e -> {
                    throw new IllegalStateException("El fanfic ya está en el catálogo del usuario.");
                });
                break;
            default:
                throw new IllegalArgumentException("Tipo de item no válido: " + dto.getItemType());
        }

        return userCatalogRepository.save(entry);
    }
}
