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
import java.util.Optional;
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
        
        Manga manga;

        // Si el DTO trae un idManga, buscamos por ese ID en la base de datos
        if (dto.getIdManga() != null) {
            manga = mangaRepository.findById(dto.getIdManga())
                    .orElseThrow(() -> new RuntimeException("Manga no encontrado con id: " + dto.getIdManga()));
        } else if (dto.getMangadexId() != null) {
            // Si trae mangadexId (pero no idManga), lo buscamos o lo creamos
            Optional<Manga> existente = mangaRepository.findByMangadexId(dto.getMangadexId());
            if (existente.isPresent()) {
                manga = existente.get();
            } else {
                // El manga es nuevo, lo registramos en el catálogo antes de agregarlo al Journal
                Manga nuevoManga = new Manga();
                nuevoManga.setMangadexId(dto.getMangadexId());
                nuevoManga.setFuente(dto.getFuente() != null ? dto.getFuente() : "MangaDex");
                // Validar campos obligatorios que vienen de MangaDex (o valores por defecto si vienen nulos)
                nuevoManga.setTitulo(dto.getTitulo() != null ? dto.getTitulo() : "Título Desconocido");
                nuevoManga.setMangaka(dto.getMangaka() != null ? dto.getMangaka() : "Mangaka Desconocido");
                nuevoManga.setDemografia(dto.getDemografia());
                nuevoManga.setGenero(dto.getGenero());
                nuevoManga.setDescripcion(dto.getDescripcion());
                nuevoManga.setPortadaUrl(dto.getPortadaUrl());
                nuevoManga.setTotalCapitulos(dto.getTotalCapitulos());
                nuevoManga.setTotalVolumenes(dto.getTotalVolumenes());
                nuevoManga.setEstadoPublicacion(dto.getEstadoPublicacion());

                manga = mangaRepository.save(nuevoManga);
            }
        } else {
            throw new RuntimeException("Debe proporcionar un idManga o un mangadexId");
        }

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

    public List<MangaJournalRespuestaDTO> obtenerRelecturas(Long idUsuario) {
        Usuario usuario = usuarioRepository.findById(idUsuario)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        return mangaJournalRepository.findByUsuarioAndRelecturaTrue(usuario)
                .stream()
                .map(this::mapearADTO)
                .collect(Collectors.toList());
    }

    public void eliminarJournal(Long idJournal) {
        mangaJournalRepository.deleteById(idJournal);
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