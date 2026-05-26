package com.calonuria.backend.shared.config;

import com.calonuria.backend.shared.security.CustomUserDetailsService;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Primary;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

import static org.mockito.Mockito.mock;

/**
 * Configuración de test que desactiva la seguridad completamente para pruebas unitarias.
 * Permite que todos los requests pasen sin autenticación.
 */
@TestConfiguration
@EnableWebSecurity
public class TestSecurityConfig {

    @Bean
    @Primary
    public CustomUserDetailsService customUserDetailsService() {
        return mock(CustomUserDetailsService.class);
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
                .authorizeHttpRequests(authConfig -> authConfig.anyRequest().permitAll())
                .csrf(csrf -> csrf.disable());
        return http.build();
    }
}