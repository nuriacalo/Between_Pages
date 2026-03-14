package com.calonuria.backend.service.journal;

import com.calonuria.backend.dto.journal.MangaJournalRegistroDTO;
import com.calonuria.backend.dto.journal.MangaJournalRespuestaDTO;
import com.calonuria.backend.model.catalog.Manga;
import com.calonuria.backend.model.journal.MangaJournal;
import com.calonuria.backend.model.user.Usuario;
import com.calonuria.backend.repository.catalog.MangaRepository;
import com.calonuria.backend.repository.journal.MangaJournalRepository;
import com.calonuria.backend.repository.user.UsuarioRepository;
import com.calonuria.backend.service.catalog.MangaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class MangaJournalService {

    @Autowired
    private MangaJournalRepository mangaJournalRepository;
    @Autowired
    private UsuarioRepository usuarioRepository;
    @Autowired
    private MangaRepository mangaRepository;
    @Autowired
    private MangaService mangaService;

    public MangaJournalRespuestaDTO guardarProgreso(MangaJournalRegistroDTO dto) {
        Usuario usuario = usuarioRepository.findById(dto.getIdUsuario())
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        Manga manga = mangaRepository.findById(dto.getIdManga())
                .orElseThrow(() -> new RuntimeException("Manga no encontrado"));

        MangaJournal journal = mangaJournalRepository.findByUsuarioAndManga(usuario, manga)
                .orElse(new MangaJournal());

        if (journal.getIdMangaJournal() == null) {
            journal.setUsuario(usuario);
            journal.setManga(manga);
        }

        journal.setEstado(dto.getEstado());
        journal.setCapituloActual(dto.getCapituloActual());
        journal.setVolumenActual(dto.getVolumenActual());
        journal.setValoracion(dto.getValoracion());
        journal.setFormatoLectura(dto.getFormatoLectura());
        journal.setPersonajeFavorito(dto.getPersonajeFavorito());
        journal.setArcoFavorito(dto.getArcoFavorito());
        journal.setNotaPersonal(dto.getNotaPersonal());
        journal.setFechaInicio(dto.getFechaInicio());
        journal.setFechaFin(dto.getFechaFin());

        MangaJournal guardado = mangaJournalRepository.save(journal);
        return mapearADTO(guardado);
    }

    public List<MangaJournalRespuestaDTO> obtenerJournalDeUsuario(Long idUsuario) {
        return mangaJournalRepository.findByUsuario_IdUsuario(idUsuario)
                .stream()
                .map(this::mapearADTO)
                .collect(Collectors.toList());
    }

    public List<MangaJournalRespuestaDTO> obtenerPorEstado(Long idUsuario, String estado) {
        Usuario usuario = usuarioRepository.findById(idUsuario)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        return mangaJournalRepository.findByUsuarioAndEstado(usuario, estado)
                .stream()
                .map(this::mapearADTO)
                .collect(Collectors.toList());
    }

    private MangaJournalRespuestaDTO mapearADTO(MangaJournal journal) {
        MangaJournalRespuestaDTO dto = new MangaJournalRespuestaDTO();
        dto.setIdMangaJournal(journal.getIdMangaJournal());
        dto.setManga(mangaService.mapearADTO(journal.getManga()));
        dto.setEstado(journal.getEstado());
        dto.setCapituloActual(journal.getCapituloActual());
        dto.setVolumenActual(journal.getVolumenActual());
        dto.setValoracion(journal.getValoracion());
        dto.setFormatoLectura(journal.getFormatoLectura());
        dto.setPersonajeFavorito(journal.getPersonajeFavorito());
        dto.setArcoFavorito(journal.getArcoFavorito());
        dto.setNotaPersonal(journal.getNotaPersonal());
        dto.setFechaInicio(journal.getFechaInicio());
        dto.setFechaFin(journal.getFechaFin());
        return dto;
    }
}