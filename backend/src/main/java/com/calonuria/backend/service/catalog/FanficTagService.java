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

/**
 * Servicio para la gestión de tags de fanfictions.
 */
@Service
public class FanficTagService {

    @Autowired
    private FanficTagRepository fanficTagRepository;

    @Autowired
    private FanfictionRepository fanfictionRepository;

    /**
     * Obtiene todos los tags de un fanfic como lista de Strings.
     * @param fanficId ID del fanfiction
     * @return lista de tags
     */
    public List<String> getTagsByFanfic(Long fanficId) {
        return fanficTagRepository.findByFanfic_Id(fanficId)
                .stream()
                .map(FanficTag::getTag)
                .collect(Collectors.toList());
    }

    /**
     * Añade un tag a un fanfic.
     * @param fanficId ID del fanfiction
     * @param tag tag a añadir
     * @return el tag añadido
     */
    public String addTag(Long fanficId, String tag) {
        Fanfiction fanfic = fanfictionRepository.findById(fanficId)
                .orElseThrow(() -> new RuntimeException("Fanfiction no encontrado"));

        FanficTag newTag = new FanficTag();
        newTag.setFanfic(fanfic);
        newTag.setTag(tag);

        fanficTagRepository.save(newTag);
        return tag;
    }

    /**
     * Reemplaza todos los tags de un fanfic (útil para el crawler de AO3).
     * @param fanficId ID del fanfiction
     * @param newTags lista de nuevos tags
     * @return lista de tags actualizados
     */
    @Transactional
    public List<String> updateTags(Long fanficId, List<String> newTags) {
        fanfictionRepository.findById(fanficId)
                .orElseThrow(() -> new RuntimeException("Fanfiction no encontrado"));

        fanficTagRepository.deleteByFanfic_Id(fanficId);

        Fanfiction fanfic = fanfictionRepository.findById(fanficId).get();

        List<FanficTag> tags = newTags.stream().map(t -> {
            FanficTag tag = new FanficTag();
            tag.setFanfic(fanfic);
            tag.setTag(t);
            return tag;
        }).collect(Collectors.toList());

        fanficTagRepository.saveAll(tags);
        return newTags;
    }

    /**
     * Elimina un tag por su ID.
     * @param tagId ID del tag
     */
    public void deleteTag(Long tagId) {
        if (!fanficTagRepository.existsById(tagId)) {
            throw new RuntimeException("Tag no encontrado");
        }
        fanficTagRepository.deleteById(tagId);
    }

    /**
     * Busca fanfics que tengan un tag concreto.
     * @param tag tag a buscar
     * @return lista de IDs de fanfictions
     */
    public List<Long> searchFanficsByTag(String tag) {
        return fanficTagRepository.findByTagIgnoreCase(tag)
                .stream()
                .map(t -> t.getFanfic().getId())
                .collect(Collectors.toList());
    }
}