package com.calonuria.backend.features.journal.service;

import com.calonuria.backend.features.journal.model.JournalType;
import org.springframework.stereotype.Component;

import java.util.EnumMap;
import java.util.Map;
import java.util.Set;

@Component
public class JournalServiceFactory {

    private final Map<JournalType, JournalService<?, ?>> services = new EnumMap<>(JournalType.class);

    public JournalServiceFactory(Set<JournalService<?, ?>> journalServices) {
        for (JournalService<?, ?> service : journalServices) {
            if (service instanceof BookJournalService) {
                services.put(JournalType.BOOK, service);
            } else if (service instanceof MangaJournalService) {
                services.put(JournalType.MANGA, service);
            } else if (service instanceof FanficJournalService) {
                services.put(JournalType.FANFIC, service);
            }
        }
    }

    @SuppressWarnings("unchecked")
    public <D, R> JournalService<D, R> getService(JournalType type) {
        return (JournalService<D, R>) services.get(type);
    }
}
