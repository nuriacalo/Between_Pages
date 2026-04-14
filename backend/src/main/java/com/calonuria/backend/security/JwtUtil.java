package com.calonuria.backend.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;
import javax.crypto.SecretKey;
import java.util.Date;

/**
 * Utilidad para la generación y validación de tokens JWT.
 */
@Component
public class JwtUtil {

    @Value("${jwt.secret}")
    private String secret;

    @Value("${jwt.expiration}")
    private Long expiration;

    private SecretKey getKey() {
        return Keys.hmacShaKeyFor(secret.getBytes());
    }

    /**
     * Genera un token de acceso JWT.
     * @param email email del usuario
     * @return token JWT generado
     */
    public String generateAccessToken(String email) {
        return Jwts.builder()
                .subject(email)
                .issuedAt(new Date())
                .expiration(new Date(System.currentTimeMillis() + expiration))
                .signWith(getKey())
                .compact();
    }

    /**
     * Genera un token de refresco JWT.
     * @param email email del usuario
     * @return token JWT de refresco generado
     */
    public String generateRefreshToken(String email) {
        return Jwts.builder()
                .subject(email)
                .issuedAt(new Date())
                .expiration(new Date(System.currentTimeMillis() + 1000L * 60 * 60 * 24 * 7))
                .signWith(getKey())
                .compact();
    }

    /**
     * Extrae el email del token.
     * @param token token JWT
     * @return email extraído
     */
    public String extractEmail(String token) {
        return extractClaims(token).getSubject();
    }

    /**
     * Verifica si el token es válido para un usuario.
     * @param token token JWT
     * @param userDetails detalles del usuario
     * @return true si el token es válido
     */
    public boolean isTokenValid(String token, UserDetails userDetails) {
        try {
            String email = extractEmail(token);
            return email.equals(userDetails.getUsername()) && !isExpired(token);
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Sobrecarga para validar token sin UserDetails — para el endpoint /refresh.
     * @param token token JWT
     * @return true si el token es válido
     */
    public boolean isTokenValid(String token) {
        try { extractClaims(token); return true; }
        catch (Exception e) { return false; }
    }

    private Claims extractClaims(String token) {
        return Jwts.parser()
                .verifyWith(getKey())
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    private boolean isExpired(String token) {
        return extractClaims(token).getExpiration().before(new Date());
    }
}