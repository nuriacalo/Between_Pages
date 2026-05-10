package com.calonuria.backend.features.journal.repository;

import com.calonuria.backend.features.journal.model.BaseJournal;
import com.calonuria.backend.features.user.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.repository.NoRepositoryBean;

import java.util.List;

/**
 * Repositorio base para la gestión de diarios de lectura.
 */
@NoRepositoryBean
public interface BaseJournalRepository<T extends BaseJournal> extends JpaRepository<T, Long> {

    /**
     * Busca todos los diarios de un usuario.
     * @param userId ID del usuario
     * @return lista de diarios
     */
    List<T> findByUserId(Long userId);

    /**
     * Busca diarios por estado.
     * @param user usuario
     * @param status estado de lectura
     * @return lista de diarios
     */
    List<T> findByUserAndStatus(User user, String status);

    /**
     * Busca solo relecturas.
     * @param user usuario
     * @return lista de diarios
     */
    List<T> findByUserAndRereadingTrue(User user);
}
