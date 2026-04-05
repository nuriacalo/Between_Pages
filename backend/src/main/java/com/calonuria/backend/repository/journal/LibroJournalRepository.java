package com.calonuria.backend.repository.journal;

import com.calonuria.backend.model.catalog.Libro;
import com.calonuria.backend.model.journal.LibroJournal;
import com.calonuria.backend.model.user.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface LibroJournalRepository extends JpaRepository<LibroJournal, Long> {

    // Todos los journals de un usuario
    @Query("SELECT l FROM LibroJournal l WHERE l.usuario.idUsuario = :idUsuario")
    List<LibroJournal> findByUsuario_IdUsuario(@Param("idUsuario") Long idUsuario);

    // Entrada específica de un usuario para un libro
    Optional<LibroJournal> findByUsuarioAndLibro(Usuario usuario, Libro libro);

    // Por estado
    List<LibroJournal> findByUsuarioAndEstado(Usuario usuario, String estado);

    // Por valoración exacta
    List<LibroJournal> findByUsuarioAndValoracion(Usuario usuario, Integer valoracion);

    // Por valoración mínima
    List<LibroJournal> findByUsuarioAndValoracionGreaterThanEqual(Usuario usuario, Integer valoracion);

    // Leídos en un rango de fechas
    List<LibroJournal> findByUsuarioAndFechaFinBetween(
            Usuario usuario, LocalDate desde, LocalDate hasta);

    // Empezados en un rango de fechas
    List<LibroJournal> findByUsuarioAndFechaInicioBetween(
            Usuario usuario, LocalDate desde, LocalDate hasta);

    // Solo relecturas
    List<LibroJournal> findByUsuarioAndRelecturaTrue(Usuario usuario);
}