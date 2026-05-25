package com.calonuria.backend.features.journal.service;

import com.calonuria.backend.features.journal.model.JournalType;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

import java.util.HashSet;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

class JournalServiceFactoryTest {

    private JournalServiceFactory factory;
    private BookJournalService bookJournalService;
    private MangaJournalService mangaJournalService;
    private FanficJournalService fanficJournalService;

    @BeforeEach
    void setUp() {
        bookJournalService = Mockito.mock(BookJournalService.class);
        mangaJournalService = Mockito.mock(MangaJournalService.class);
        fanficJournalService = Mockito.mock(FanficJournalService.class);

        Set<JournalService<?, ?>> services = new HashSet<>();
        services.add(bookJournalService);
        services.add(mangaJournalService);
        services.add(fanficJournalService);

        factory = new JournalServiceFactory(services);
    }

    @Test
    void getBookService() {
        JournalService<?, ?> service = factory.getService(JournalType.BOOK);
        assertNotNull(service);
        assertTrue(service instanceof BookJournalService);
    }

    @Test
    void getMangaService() {
        JournalService<?, ?> service = factory.getService(JournalType.MANGA);
        assertNotNull(service);
        assertTrue(service instanceof MangaJournalService);
    }

    @Test
    void getFanficService() {
        JournalService<?, ?> service = factory.getService(JournalType.FANFIC);
        assertNotNull(service);
        assertTrue(service instanceof FanficJournalService);
    }
}