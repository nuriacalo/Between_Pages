package com.calonuria.backend.service.journal;

import com.calonuria.backend.dto.journal.FanficJournalRegistroDTO;
import com.calonuria.backend.dto.journal.FanficJournalRespuestaDTO;
import com.calonuria.backend.model.catalog.Fanfiction;
import com.calonuria.backend.model.journal.FanficJournal;
import com.calonuria.backend.model.user.Usuario;
import com.calonuria.backend.repository.catalog.FanfictionRepository;
import com.calonuria.backend.repository.journal.FanficJournalRepository;
import com.calonuria.backend.repository.user.UsuarioRepository;
import com.calonuria.backend.service.catalog.FanfictionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class FanficJournalService {

    @Autowired
    private FanficJournalRepository fanficJournalRepository;
    @Autowired
    private UsuarioRepository usuarioRepository;
    @Autowired
    private FanfictionRepository fanfictionRepository;
    @Autowired
    private FanfictionService fanfictionService;

    public FanficJournalRespuestaDTO guardarProgreso(FanficJournalRegistroDTO dto) {
        Usuario usuario = usuarioRepository.findById(dto.getIdUsuario())
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        
        Fanfiction fanfic;

        // Si el DTO trae un idFanfiction, buscamos por ese ID en la base de datos
        if (dto.getIdFanfiction() != null) {
            fanfic = fanfictionRepository.findById(dto.getIdFanfiction())
                    .orElseThrow(() -> new RuntimeException("Fanfiction no encontrado con id: " + dto.getIdFanfiction()));
        } else if (dto.getAo3Id() != null) {
            // Si trae ao3Id (pero no idFanfiction), lo buscamos o lo creamos
            Optional<Fanfiction> existente = fanfictionRepository.findByAo3Id(dto.getAo3Id());
            if (existente.isPresent()) {
                fanfic = existente.get();
            } else {
                // El fanfic es nuevo, lo registramos en el catálogo antes de agregarlo al Journal
                Fanfiction nuevoFanfic = new Fanfiction();
                nuevoFanfic.setAo3Id(dto.getAo3Id());
                // Validar campos obligatorios que vienen de la API de AO3/similar
                nuevoFanfic.setTitulo(dto.getTitulo() != null ? dto.getTitulo() : "Título Desconocido");
                nuevoFanfic.setAutor(dto.getAutor() != null ? dto.getAutor() : "Autor Desconocido");
                nuevoFanfic.setHistoriaBase(dto.getHistoriaBase());
                nuevoFanfic.setDescripcion(dto.getDescripcion());
                nuevoFanfic.setPortadaUrl(dto.getPortadaUrl());
                nuevoFanfic.setGenero(dto.getGenero());
                nuevoFanfic.setShipPrincipal(dto.getShipPrincipal());
                nuevoFanfic.setTematica(dto.getTematica());
                nuevoFanfic.setTotalCapitulos(dto.getTotalCapitulos());
                nuevoFanfic.setEstadoPublicacion(dto.getEstadoPublicacion());

                fanfic = fanfictionRepository.save(nuevoFanfic);
            }
        } else {
            throw new RuntimeException("Debe proporcionar un idFanfiction o un ao3Id");
        }

        FanficJournal journal = fanficJournalRepository.findByUsuarioAndFanfic(usuario, fanfic)
                .orElse(new FanficJournal());

        if (journal.getIdFanficJournal() == null) {
            journal.setUsuario(usuario);
            journal.setFanfic(fanfic);
        }

        journal.setEstado(dto.getEstado());
        journal.setCapituloActual(dto.getCapituloActual());
        journal.setValoracion(dto.getValoracion());
        journal.setShipPrincipal(dto.getShipPrincipal());
        journal.setShipsSecundarios(dto.getShipsSecundarios());
        journal.setTematica(dto.getTematica());
        journal.setNivelAngst(dto.getNivelAngst());
        journal.setFidelidadShip(dto.getFidelidadShip());
        journal.setCanonVsAu(dto.getCanonVsAu());
        journal.setRelectura(dto.getRelectura());
        journal.setNotasPersonales(dto.getNotasPersonales());
        journal.setFechaInicio(dto.getFechaInicio());
        journal.setFechaFin(dto.getFechaFin());

        FanficJournal guardado = fanficJournalRepository.save(journal);
        return mapearADTO(guardado);
    }

    public List<FanficJournalRespuestaDTO> obtenerJournalDeUsuario(Long idUsuario) {
        return fanficJournalRepository.findByUsuario_IdUsuario(idUsuario)
                .stream()
                .map(this::mapearADTO)
                .collect(Collectors.toList());
    }

    public List<FanficJournalRespuestaDTO> obtenerPorEstado(Long idUsuario, String estado) {
        Usuario usuario = usuarioRepository.findById(idUsuario)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        return fanficJournalRepository.findByUsuarioAndEstado(usuario, estado)
                .stream()
                .map(this::mapearADTO)
                .collect(Collectors.toList());
    }

    public List<FanficJournalRespuestaDTO> obtenerRelecturas(Long idUsuario) {
        Usuario usuario = usuarioRepository.findById(idUsuario)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        return fanficJournalRepository.findByUsuarioAndRelecturaTrue(usuario)
                .stream()
                .map(this::mapearADTO)
                .collect(Collectors.toList());
    }

    public void eliminarJournal(Long idJournal) {
        fanficJournalRepository.deleteById(idJournal);
    }

    private FanficJournalRespuestaDTO mapearADTO(FanficJournal journal) {
        FanficJournalRespuestaDTO dto = new FanficJournalRespuestaDTO();
        dto.setIdFanficJournal(journal.getIdFanficJournal());
        dto.setFanfic(fanfictionService.mapearADTO(journal.getFanfic()));
        dto.setEstado(journal.getEstado());
        dto.setCapituloActual(journal.getCapituloActual());
        dto.setValoracion(journal.getValoracion());
        dto.setShipPrincipal(journal.getShipPrincipal());
        dto.setShipsSecundarios(journal.getShipsSecundarios());
        dto.setNivelAngst(journal.getNivelAngst());
        dto.setFidelidadShip(journal.getFidelidadShip());
        dto.setCanonVsAu(journal.getCanonVsAu());
        dto.setRelectura(journal.getRelectura());
        dto.setNotasPersonales(journal.getNotasPersonales());
        dto.setFechaInicio(journal.getFechaInicio());
        dto.setFechaFin(journal.getFechaFin());
        return dto;
    }
}