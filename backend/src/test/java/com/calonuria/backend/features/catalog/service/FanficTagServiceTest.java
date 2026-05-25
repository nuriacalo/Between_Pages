package com.calonuria.backend.features.catalog.service;

import com.calonuria.backend.features.catalog.model.FanficTag;
import com.calonuria.backend.features.catalog.model.Fanfiction;
import com.calonuria.backend.features.catalog.repository.FanficTagRepository;
import com.calonuria.backend.features.catalog.repository.FanfictionRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Collections;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class FanficTagServiceTest {

    @Mock
    private FanficTagRepository fanficTagRepository;

    @Mock
    private FanfictionRepository fanfictionRepository;

    @InjectMocks
    private FanficTagService fanficTagService;

    @Test
    void getTagsByFanfic() {
        when(fanficTagRepository.findByFanfic_Id(1L)).thenReturn(Collections.emptyList());
        assertNotNull(fanficTagService.getTagsByFanfic(1L));
    }

    @Test
    void addTag() {
        Fanfiction fanfic = new Fanfiction();
        when(fanfictionRepository.findById(1L)).thenReturn(Optional.of(fanfic));
        when(fanficTagRepository.save(any(FanficTag.class))).thenReturn(new FanficTag());
        assertNotNull(fanficTagService.addTag(1L, "test"));
    }

    @Test
    void searchFanficsByTag() {
        when(fanficTagRepository.findByTagIgnoreCase("test")).thenReturn(Collections.emptyList());
        assertNotNull(fanficTagService.searchFanficsByTag("test"));
    }
}