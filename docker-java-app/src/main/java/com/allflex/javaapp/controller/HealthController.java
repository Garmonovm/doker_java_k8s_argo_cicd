package com.allflex.javaapp.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;
import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.Map;

@RestController
public class HealthController {

    @Value("${spring.application.name:java-app}")
    private String appName;

    @Value("${app.version:1.0.0}")
    private String appVersion;

    /**
     * Health check endpoint — used by ALB/ECS/EKS health probes.
     * Returns same JSON format as the PHP app for consistency.
     */
    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> response = new LinkedHashMap<>();
        response.put("status", "healthy");
        response.put("timestamp", DateTimeFormatter.ISO_INSTANT.format(Instant.now()));
        response.put("service", appName);
        response.put("version", appVersion);
        return ResponseEntity.ok(response);
    }

    /**
     * Root endpoint — basic service info.
     */
    @GetMapping("/")
    public ResponseEntity<Map<String, Object>> root() {
        Map<String, Object> response = new LinkedHashMap<>();
        response.put("message", "Java Application is running");
        response.put("service", appName);
        return ResponseEntity.ok(response);
    }
}
