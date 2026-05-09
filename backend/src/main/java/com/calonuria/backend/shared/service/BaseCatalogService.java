package com.calonuria.backend.features.catalog.service;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Clase base abstracta para servicios de catálogo.
 * Elimina la duplicación de código entre BookService, MangaService y FanfictionService.
 *
 * @param <T> Tipo de la entidad (Book, Manga, Fanfiction)
 * @param <D> Tipo del DTO de respuesta
 * @param <ID> Tipo del ID de la entidad
 */
public abstract class BaseCatalogService<T, D, ID> {

    protected final JpaRepository<T, ID> repository;

    protected BaseCatalogService(JpaRepository<T, ID> repository) {
        this.repository = repository;
    }

    /**
     * Mapea una entidad a su DTO correspondiente.
     * Debe ser implementado por las subclases.
     */
    public abstract D mapToDTO(T entity);

    /**
     * Obtiene una entidad por su ID.
     */
    @Transactional(readOnly = true)
    public Optional<D> findById(ID id) {
        return repository.findById(id).map(this::mapToDTO);
    }

    /**
     * Busca entidades por título (contiene, ignorando case).
     * Las subclases deben proporcionar el método de búsqueda específico.
     */
    @Transactional(readOnly = true)
    public abstract List<D> searchByTitle(String title);

    /**
     * Obtiene todas las entidades del catálogo.
     */
    @Transactional(readOnly = true)
    public List<D> findAll() {
        return repository.findAll().stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    /**
     * Guarda una entidad y devuelve su DTO.
     */
    @Transactional
    public D saveAndMap(T entity) {
        return mapToDTO(repository.save(entity));
    }

    /**
     * Mapea una lista de entidades a DTOs.
     */
    public List<D> mapList(List<T> entities) {
        return entities.stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }
}
