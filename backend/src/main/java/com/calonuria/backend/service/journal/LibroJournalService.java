package com.calonuria.backend.service.journal;

import com.calonuria.backend.dto.journal.LibroJournalRegistroDTO;
import com.calonuria.backend.dto.journal.LibroJournalRespuestaDTO;
import com.calonuria.backend.model.catalog.Libro;
import com.calonuria.backend.model.journal.LibroJournal;
import com.calonuria.backend.model.user.Usuario;
import com.calonuria.backend.repository.catalog.LibroRepository;
import com.calonuria.backend.repository.journal.LibroJournalRepository;
import com.calonuria.backend.repository.user.UsuarioRepository;
import com.calonuria.backend.service.catalog.LibroService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class LibroJournalService {

    @Autowired
    private LibroJournalRepository libroJournalRepository;
    @Autowired
    private UsuarioRepository usuarioRepository;
    @Autowired
    private LibroRepository libroRepository;
    @Autowired
    private LibroService libroService;

    public LibroJournalRespuestaDTO guardarProgreso(LibroJournalRegistroDTO dto) {
        Usuario usuario = usuarioRepository.findById(dto.getIdUsuario())
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        Libro libro = libroRepository.findById(dto.getIdLibro())
                .orElseThrow(() -> new RuntimeException("Libro no encontrado"));

        LibroJournal journal = libroJournalRepository.findByUsuarioAndLibro(usuario, libro)
                .orElse(new LibroJournal());

        if (journal.getIdLibroJournal() == null) {
            journal.setUsuario(usuario);
            journal.setLibro(libro);
        }

        journal.setEstado(dto.getEstado());
        journal.setPaginaActual(dto.getPaginaActual());
        journal.setValoracion(dto.getValoracion());
        journal.setFormatoLectura(dto.getFormatoLectura());
        journal.setEmociones(dto.getEmociones());
        journal.setCitasFavoritas(dto.getCitasFavoritas());
        journal.setNotaPersonal(dto.getNotaPersonal());
        journal.setFechaInicio(dto.getFechaInicio());
        journal.setFechaFin(dto.getFechaFin());

        LibroJournal guardado = libroJournalRepository.save(journal);
        return mapearADTO(guardado);
    }

    public List<LibroJournalRespuestaDTO> obtenerJournalDeUsuario(Long idUsuario) {
        return libroJournalRepository.findByUsuario_IdUsuario(idUsuario)
                .stream()
                .map(this::mapearADTO)
                .collect(Collectors.toList());
    }

    public List<LibroJournalRespuestaDTO> obtenerPorEstado(Long idUsuario, String estado) {
        Usuario usuario = usuarioRepository.findById(idUsuario)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        return libroJournalRepository.findByUsuarioAndEstado(usuario, estado)
                .stream()
                .map(this::mapearADTO)
                .collect(Collectors.toList());
    }

    private LibroJournalRespuestaDTO mapearADTO(LibroJournal journal) {
        LibroJournalRespuestaDTO dto = new LibroJournalRespuestaDTO();
        dto.setIdLibroJournal(journal.getIdLibroJournal());
        dto.setLibro(libroService.mapearADTO(journal.getLibro()));
        dto.setEstado(journal.getEstado());
        dto.setPaginaActual(journal.getPaginaActual());
        dto.setValoracion(journal.getValoracion());
        dto.setFormatoLectura(journal.getFormatoLectura());
        dto.setEmociones(journal.getEmociones());
        dto.setCitasFavoritas(journal.getCitasFavoritas());
        dto.setNotaPersonal(journal.getNotaPersonal());
        dto.setFechaInicio(journal.getFechaInicio());
        dto.setFechaFin(journal.getFechaFin());
        return dto;
    }
}