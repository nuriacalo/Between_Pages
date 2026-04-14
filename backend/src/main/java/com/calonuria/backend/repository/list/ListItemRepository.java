package com.calonuria.backend.repository.list;

import com.calonuria.backend.model.list.ListItem;
import com.calonuria.backend.model.list.ReadingList;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

/**
 * Repositorio para la gestión de elementos de listas.
 */
@Repository
public interface ListItemRepository extends JpaRepository<ListItem, Long> {

    /**
     * Busca todos los elementos de una lista.
     * @param list lista
     * @return lista de elementos
     */
    List<ListItem> findByList(ReadingList list);

    /**
     * Busca un elemento de una lista que contenga un libro específico.
     * @param list lista
     * @param bookId ID del libro
     * @return Optional con el elemento
     */
    Optional<ListItem> findByListAndBookId(ReadingList list, Long bookId);

    /**
     * Busca un elemento de una lista que contenga un manga específico.
     * @param list lista
     * @param mangaId ID del manga
     * @return Optional con el elemento
     */
    Optional<ListItem> findByListAndMangaId(ReadingList list, Long mangaId);

    /**
     * Busca un elemento de una lista que contenga un fanfiction específico.
     * @param list lista
     * @param fanficId ID del fanfiction
     * @return Optional con el elemento
     */
    Optional<ListItem> findByListAndFanficId(ReadingList list, Long fanficId);

    /**
     * Elimina todos los elementos de una lista.
     * @param list lista
     */
    void deleteByList(ReadingList list);

    /**
     * Cuenta el número de elementos en una lista.
     * @param list lista
     * @return número de elementos
     */
    long countByList(ReadingList list);
}
