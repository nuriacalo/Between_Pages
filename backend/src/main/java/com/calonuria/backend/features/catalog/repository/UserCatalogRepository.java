package com.calonuria.backend.features.catalog.repository;

import com.calonuria.backend.features.catalog.model.Book;
import com.calonuria.backend.features.catalog.model.Fanfiction;
import com.calonuria.backend.features.catalog.model.Manga;
import com.calonuria.backend.features.catalog.model.UserCatalog;
import com.calonuria.backend.features.user.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserCatalogRepository extends JpaRepository<UserCatalog, Long> {
    Optional<UserCatalog> findByUserAndBook(User user, Book book);
    Optional<UserCatalog> findByUserAndManga(User user, Manga manga);
    Optional<UserCatalog> findByUserAndFanfic(User user, Fanfiction fanfic);
    List<UserCatalog> findByUserId(Long userId);
}
