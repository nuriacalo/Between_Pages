package com.calonuria.backend.repository.journal;

import com.calonuria.backend.model.catalog.Manga;
import com.calonuria.backend.model.journal.MangaJournal;
import com.calonuria.backend.model.user.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface MangaJournalRepository extends JpaRepository<MangaJournal, Long> {

    // Todos los journals de un usuario
    @Query("SELECT m FROM MangaJournal m WHERE m.usuario.idUsuario = :idUsuario")
    List<MangaJournal> findByUsuario_IdUsuario(@Param("idUsuario") Long idUsuario);

    // Entrada específica de un usuario para un manga
    Optional<MangaJournal> findByUsuarioAndManga(Usuario usuario, Manga manga);

    // Por estado
    List<MangaJournal> findByUsuarioAndEstado(Usuario usuario, String estado);

    // Por valoración exacta
    List<MangaJournal> findByUsuarioAndValoracion(Usuario usuario, Integer valoracion);

    // Por valoración mínima
    List<MangaJournal> findByUsuarioAndValoracionGreaterThanEqual(Usuario usuario, Integer valoracion);

    // Leídos en un rango de fechas
    List<MangaJournal> findByUsuarioAndFechaFinBetween(
            Usuario usuario, LocalDate desde, LocalDate hasta);

    // Solo relecturas
    List<MangaJournal> findByUsuarioAndRelecturaTrue(Usuario usuario);
}