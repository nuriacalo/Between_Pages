package com.calonuria.backend.features.user.application.events;

import org.springframework.context.ApplicationEvent;

/**
 * Evento que se publica cuando un usuario registra una actividad de lectura
 * (ej. al guardar progreso en un journal).
 */
public class ReadingActivityEvent extends ApplicationEvent {

    private final String username;

    public ReadingActivityEvent(Object source, String username) {
        super(source);
        this.username = username;
    }

    public String getUsername() {
        return username;
    }
}
