package com.calonuria.backend.service.journal;

import com.calonuria.backend.exception.ResourceNotFoundException;
import com.calonuria.backend.model.journal.BaseJournal;
import com.calonuria.backend.model.user.User;
import com.calonuria.backend.repository.journal.BaseJournalRepository;
import com.calonuria.backend.repository.user.UserRepository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Servicio base para la gestión del diario de lectura.
 * Elimina la duplicación de código entre BookJournalService, MangaJournalService y FanficJournalService.
 *
 * @param <T> Tipo de entidad del diario (BookJournal, MangaJournal, FanficJournal)
 * @param <D> Tipo de DTO de respuesta
 */
public abstract class BaseJournalService<T extends BaseJournal, D> {

    protected final BaseJournalRepository<T> journalRepository;
    protected final UserRepository userRepository;

    protected BaseJournalService(BaseJournalRepository<T> journalRepository, UserRepository userRepository) {
        this.journalRepository = journalRepository;
        this.userRepository = userRepository;
    }

    /**
     * Mapea una entidad de diario a su DTO correspondiente.
     */
    protected abstract D mapToDTO(T journal);

    /**
     * Obtiene el journal de un usuario.
     * @param userId ID del usuario
     * @return lista de entradas del journal
     */
    @Transactional(readOnly = true)
    public List<D> getUserJournal(Long userId) {
        return journalRepository.findByUserId(userId)
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    /**
     * Obtiene entradas del journal filtradas por estado.
     * @param userId ID del usuario
     * @param status estado de lectura
     * @return lista de entradas filtradas
     */
    @Transactional(readOnly = true)
    public List<D> getByStatus(Long userId, String status) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Usuario no encontrado con id: " + userId));
        return journalRepository.findByUserAndStatus(user, status)
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    /**
     * Obtiene las relecturas de un usuario.
     * @param userId ID del usuario
     * @return lista de relecturas
     */
    @Transactional(readOnly = true)
    public List<D> getRereadings(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Usuario no encontrado con id: " + userId));
        return journalRepository.findByUserAndRereadingTrue(user)
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    /**
     * Elimina una entrada del journal.
     * @param journalId ID de la entrada
     */
    public void deleteJournal(Long journalId) {
        journalRepository.deleteById(journalId);
    }
}
