package com.calonuria.backend.repository.list;

import com.calonuria.backend.model.list.ReadingList;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

/**
 * Repositorio para la gestión de listas de lectura.
 */
@Repository
public interface ReadingListRepository extends JpaRepository<ReadingList, Long> {

    /**
     * Busca todas las listas de un usuario.
     * @param userId ID del usuario
     * @return lista de listas
     */
    @Query("SELECT l FROM ReadingList l WHERE l.user.id = :userId")
    List<ReadingList> findByUserId(@Param("userId") Long userId);

    /**
     * Busca una lista por nombre de un usuario concreto.
     * @param userId ID del usuario
     * @param name nombre de la lista
     * @return Optional con la lista
     */
    Optional<ReadingList> findByUserIdAndNameIgnoreCase(Long userId, String name);

    /**
     * Busca listas de un usuario que contengan cierta palabra en el nombre.
     * @param userId ID del usuario
     * @param name nombre a buscar
     * @return lista de listas
     */
    List<ReadingList> findByUserIdAndNameContainingIgnoreCase(Long userId, String name);

    /**
     * Busca listas que contienen un libro concreto.
     * @param userId ID del usuario
     * @param bookId ID del libro
     * @return lista de listas
     */
    @Query("SELECT li.list FROM ListItem li WHERE li.book.id = :bookId AND li.list.user.id = :userId")
    List<ReadingList> findListsWithBook(@Param("userId") Long userId, @Param("bookId") Long bookId);

    /**
     * Busca listas que contienen un fanfiction concreto.
     * @param userId ID del usuario
     * @param fanficId ID del fanfiction
     * @return lista de listas
     */
    @Query("SELECT li.list FROM ListItem li WHERE li.fanfic.id = :fanficId AND li.list.user.id = :userId")
    List<ReadingList> findListsWithFanfic(@Param("userId") Long userId, @Param("fanficId") Long fanficId);

    /**
     * Busca listas que contienen un manga concreto.
     * @param userId ID del usuario
     * @param mangaId ID del manga
     * @return lista de listas
     */
    @Query("SELECT li.list FROM ListItem li WHERE li.manga.id = :mangaId AND li.list.user.id = :userId")
    List<ReadingList> findListsWithManga(@Param("userId") Long userId, @Param("mangaId") Long mangaId);
}
