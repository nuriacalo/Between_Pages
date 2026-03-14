package com.calonuria.backend.service.catalog;

import com.calonuria.backend.model.catalog.Fanfiction;
import com.calonuria.backend.model.catalog.FanficTag;
import com.calonuria.backend.repository.catalog.FanficTagRepository;
import com.calonuria.backend.repository.catalog.FanfictionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class FanficTagService {

    @Autowired
    private FanficTagRepository fanficTagRepository;

    @Autowired
    private FanfictionRepository fanfictionRepository;

    // Obtener todos los tags de un fanfic como lista de Strings
    public List<String> obtenerTagsDeFanfic(Long idFanfic) {
        return fanficTagRepository.findByFanfic_IdFanfic(idFanfic)
                .stream()
                .map(FanficTag::getTag)
                .collect(Collectors.toList());
    }

    // Añadir un tag a un fanfic
    public String añadirTag(Long idFanfic, String tag) {
        Fanfiction fanfic = fanfictionRepository.findById(idFanfic)
                .orElseThrow(() -> new RuntimeException("Fanfiction no encontrado"));

        FanficTag nuevoTag = new FanficTag();
        nuevoTag.setFanfic(fanfic);
        nuevoTag.setTag(tag);

        fanficTagRepository.save(nuevoTag);
        return tag;
    }

    // Reemplazar todos los tags de un fanfic (útil para el crawler de AO3)
    @Transactional
    public List<String> actualizarTags(Long idFanfic, List<String> nuevosTags) {
        fanfictionRepository.findById(idFanfic)
                .orElseThrow(() -> new RuntimeException("Fanfiction no encontrado"));

        fanficTagRepository.deleteByFanfic_IdFanfic(idFanfic);

        Fanfiction fanfic = fanfictionRepository.findById(idFanfic).get();

        List<FanficTag> tags = nuevosTags.stream().map(t -> {
            FanficTag tag = new FanficTag();
            tag.setFanfic(fanfic);
            tag.setTag(t);
            return tag;
        }).collect(Collectors.toList());

        fanficTagRepository.saveAll(tags);
        return nuevosTags;
    }

    // Eliminar un tag por su ID
    public void eliminarTag(Long idTag) {
        if (!fanficTagRepository.existsById(idTag)) {
            throw new RuntimeException("Tag no encontrado");
        }
        fanficTagRepository.deleteById(idTag);
    }

    // Buscar fanfics que tengan un tag concreto
    public List<Long> buscarFanficsPorTag(String tag) {
        return fanficTagRepository.findByTagIgnoreCase(tag)
                .stream()
                .map(t -> t.getFanfic().getIdFanfic())
                .collect(Collectors.toList());
    }
}