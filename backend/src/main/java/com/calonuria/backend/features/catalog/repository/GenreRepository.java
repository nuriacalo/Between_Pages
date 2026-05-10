package com.calonuria.backend.features.catalog.repository;

import com.calonuria.backend.features.catalog.model.Genre;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface GenreRepository extends JpaRepository<Genre, Integer> {
    Optional<Genre> findByNameIgnoreCase(String name);
}
