package com.calonuria.backend.service.catalog;

import com.calonuria.backend.dto.catalog.FanfictionRespuestaDTO;
import com.calonuria.backend.model.catalog.Fanfiction;
import com.calonuria.backend.model.catalog.FanficTag;
import com.calonuria.backend.repository.catalog.FanfictionRepository;
import com.calonuria.backend.repository.catalog.FanficTagRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class FanfictionService {

    @Autowired
    private FanfictionRepository fanfictionRepository;

    @Autowired
    private FanficTagRepository fanficTagRepository;

    // Guarda solo si no existe ya por ao3Id
    public FanfictionRespuestaDTO guardarSiNoExiste(Fanfiction fanfic) {
        if (fanfic.getAo3Id() != null) {
            Optional<Fanfiction> existente = fanfictionRepository.findByAo3Id(fanfic.getAo3Id());
            if (existente.isPresent()) {
                return mapearADTO(existente.get());
            }
        }
        return mapearADTO(fanfictionRepository.save(fanfic));
    }

    public Optional<FanfictionRespuestaDTO> obtenerFanficPorId(Long id) {
        return fanfictionRepository.findById(id).map(this::mapearADTO);
    }

    public List<FanfictionRespuestaDTO> buscarPorTitulo(String titulo) {
        return fanfictionRepository.findByTituloContainingIgnoreCase(titulo)
                .stream().map(this::mapearADTO).collect(Collectors.toList());
    }

    public List<FanfictionRespuestaDTO> buscarPorEstado(String estado) {
        return fanfictionRepository.findByEstadoPublicacionIgnoreCase(estado)
                .stream().map(this::mapearADTO).collect(Collectors.toList());
    }

    public FanfictionRespuestaDTO mapearADTO(Fanfiction fanfic) {
        FanfictionRespuestaDTO dto = new FanfictionRespuestaDTO();
        dto.setIdFanfic(fanfic.getIdFanfic());
        dto.setAo3Id(fanfic.getAo3Id());
        dto.setTitulo(fanfic.getTitulo());
        dto.setAutor(fanfic.getAutor());
        dto.setHistoriaBase(fanfic.getHistoriaBase());
        dto.setDescripcion(fanfic.getDescripcion());
        dto.setPortadaUrl(fanfic.getPortadaUrl());
        dto.setGenero(fanfic.getGenero());
        dto.setShipPrincipal(fanfic.getShipPrincipal());
        dto.setTematica(fanfic.getTematica());
        dto.setCapituloActual(fanfic.getCapituloActual());
        dto.setTotalCapitulos(fanfic.getTotalCapitulos());
        dto.setEstadoPublicacion(fanfic.getEstadoPublicacion());
        // Cargar tags desde la tabla fanfic_tag
        List<String> tags = fanficTagRepository.findByFanfic_IdFanfic(fanfic.getIdFanfic())
                .stream().map(FanficTag::getTag).collect(Collectors.toList());
        dto.setTags(tags);
        return dto;
    }
}