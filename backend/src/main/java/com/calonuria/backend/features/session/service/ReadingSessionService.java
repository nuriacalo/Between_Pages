package com.calonuria.backend.features.session.service;

import com.calonuria.backend.features.session.dto.ReadingSessionRecordDTO;
import com.calonuria.backend.features.session.dto.ReadingSessionStatsDTO;
import com.calonuria.backend.features.session.model.ReadingSession;
import com.calonuria.backend.features.user.model.User;
import com.calonuria.backend.features.session.repository.ReadingSessionRepository;
import com.calonuria.backend.features.user.repository.UserRepository;
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

        if (dto.getBookId() != null) {
            session.setItemType(ReadingSession.ItemType.BOOK);
            session.setItemId(dto.getBookId());
        } else if (dto.getMangaId() != null) {
            session.setItemType(ReadingSession.ItemType.MANGA);
            session.setItemId(dto.getMangaId());
        } else if (dto.getFanficId() != null) {
            session.setItemType(ReadingSession.ItemType.FANFIC);
            session.setItemId(dto.getFanficId());
        } else {
            throw new IllegalArgumentException("Debe especificar al menos un ID de item (book/manga/fanfic)");
        }

        readingSessionRepository.save(session);
    }

    public ReadingSessionStatsDTO getReadingStats(Long userId, Long bookId, Long mangaId, Long fanficId, int remainingPages) {
        Optional<Double> speedOpt;

        if (bookId != null) {
            speedOpt = readingSessionRepository.findAverageSpeedForItem(userId, bookId, null, null)
                    .or(() -> readingSessionRepository.findAverageSpeedForBookType(userId));
        } else if (mangaId != null) {
            speedOpt = readingSessionRepository.findAverageSpeedForItem(userId, null, mangaId, null)
                    .or(() -> readingSessionRepository.findAverageSpeedForMangaType(userId));
        } else if (fanficId != null) {
            speedOpt = readingSessionRepository.findAverageSpeedForItem(userId, null, null, fanficId)
                    .or(() -> readingSessionRepository.findAverageSpeedForFanficType(userId));
        } else {
            // Si no se especifica un item, se calcula la velocidad global
            speedOpt = readingSessionRepository.findAverageSpeedGlobal(userId);
        }

        // Fallback final a la velocidad global si no se encontró nada específico
        double avgSpeed = speedOpt
                .or(() -> readingSessionRepository.findAverageSpeedGlobal(userId))
                .orElse(DEFAULT_SPEED_PPH);

        // Evitar división por cero si la velocidad es 0
        if (avgSpeed <= 0) {
            avgSpeed = DEFAULT_SPEED_PPH;
        }

        long estimatedSeconds = (long) Math.ceil((remainingPages / avgSpeed) * 3600);

        return new ReadingSessionStatsDTO(avgSpeed, estimatedSeconds);
    }
}
