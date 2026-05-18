package com.calonuria.backend.features.user.controller;

import com.calonuria.backend.features.user.service.ProfileService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/profile/{userId}/goal")
public class ProfileController {

    private final ProfileService profileService;

    public ProfileController(ProfileService profileService) {
        this.profileService = profileService;
    }

    @GetMapping
    public ResponseEntity<Map<String, Integer>> getAnnualGoal(@PathVariable Long userId) {
        return ResponseEntity.ok(profileService.getAnnualGoal(userId));
    }

    @PostMapping
    public ResponseEntity<Void> setAnnualGoal(@PathVariable Long userId, @RequestBody Map<String, Integer> payload) {
        profileService.setAnnualGoal(userId, payload.get("target"));
        return ResponseEntity.ok().build();
    }
}