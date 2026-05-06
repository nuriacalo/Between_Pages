package com.calonuria.backend.service.session;

import com.calonuria.backend.dto.session.ReadingSessionRecordDTO;
import com.calonuria.backend.dto.session.ReadingSessionStatsDTO;
import com.calonuria.backend.model.session.ReadingSession;
import com.calonuria.backend.model.session.ReadingSession.ItemType;
import com.calonuria.backend.model.user.User;
import com.calonuria.backend.repository.session.ReadingSessionRepository;
import com.calonuria.backend.repository.user.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

/**
 * Servicio para gestión de sesiones de lectura y cálculo de velocidad.
 */
@Service
@RequiredArgsConstructor
public class ReadingSessionService {

    private final ReadingSessionRepository readingSessionRepository;
    private final UserRepository userRepository;

    private static final double DEFAULT_SPEED_PPH = 30.0; // Default 30 páginas/hora

    @Transactional
    public void saveSession(ReadingSessionRecordDTO dto) {
        User user = userRepository.findById(dto.getUserId())
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado: " + dto.getUserId()));

        ReadingSession session = new ReadingSession();
        session.setUser(user);
        session.setDurationSeconds(dto.getDurationSeconds());
        session.setPagesRead(dto.getPagesRead());

        // Determinar tipo e ID del item
        if (dto.getBookId() != null) {
            session.setItemType(ItemType.BOOK);
            session.setItemId(dto.getBookId());
        } else if (dto.getMangaId() != null) {
            session.setItemType(ItemType.MANGA);
            session.setItemId(dto.getMangaId());
        } else if (dto.getFanficId() != null) {
            session.setItemType(ItemType.FANFIC);
            session.setItemId(dto.getFanficId());
        } else {
            throw new IllegalArgumentException("Debe especificar al menos un ID de item (book/manga/fanfic)");
        }

        readingSessionRepository.save(session);
    }

    public ReadingSessionStatsDTO getReadingStats(Long userId, ItemType itemType, Long itemId, int remainingPages) {
        // Buscar avg speed para item específico, luego tipo, luego global
        Double avgSpeed = readingSessionRepository.findAverageSpeedPagesPerHour(userId, itemType, itemId)
                .orElseGet(() -> readingSessionRepository.findAverageSpeedPagesPerHour(userId, itemType, null)
                        .orElse(DEFAULT_SPEED_PPH));

        long estimatedSeconds = (long) Math.ceil((remainingPages / avgSpeed) * 3600);

        return new ReadingSessionStatsDTO(avgSpeed, estimatedSeconds);
    }
}
