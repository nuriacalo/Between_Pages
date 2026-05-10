package com.calonuria.backend.features.notes.repository;

import com.calonuria.backend.features.notes.model.Note;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NoteRepository extends JpaRepository<Note, Long> {
    List<Note> findByBookIdAndUserId(String bookId, Long userId);
}