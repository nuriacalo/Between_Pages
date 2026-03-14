package com.calonuria.backend.repository.journal;

import com.calonuria.backend.model.catalog.Fanfiction;
import com.calonuria.backend.model.journal.FanficJournal;
import com.calonuria.backend.model.user.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface FanficJournalRepository extends JpaRepository<FanficJournal, Long> {

    // Todos los journals de un usuario
    @Query("SELECT f FROM FanficJournal f WHERE f.usuario.idUsuario = :idUsuario")
    List<FanficJournal> findByUsuario_IdUsuario(@Param("idUsuario") Long idUsuario);

    // Entrada específica de un usuario para un fanfic
    Optional<FanficJournal> findByUsuarioAndFanfic(Usuario usuario, Fanfiction fanfic);

    // Por estado
    List<FanficJournal> findByUsuarioAndEstado(Usuario usuario, String estado);

    // Por valoración exacta
    List<FanficJournal> findByUsuarioAndValoracion(Usuario usuario, Integer valoracion);

    // Por valoración mínima
    List<FanficJournal> findByUsuarioAndValoracionGreaterThanEqual(Usuario usuario, Integer valoracion);

    // Solo relelecturas
    List<FanficJournal> findByUsuarioAndRelecturaTrue(Usuario usuario);

    // Por nivel de angst
    List<FanficJournal> findByUsuarioAndNivelAngst(Usuario usuario, String nivelAngst);

    // Leídos en un rango de fechas
    List<FanficJournal> findByUsuarioAndFechaFinBetween(
            Usuario usuario, LocalDate desde, LocalDate hasta);
}