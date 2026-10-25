package com.fastshop.net.controller;

import org.springframework.boot.actuate.health.HealthEndpoint;
import org.springframework.boot.actuate.health.Status;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.Map;

public class HealthController {
    private final HealthEndpoint healthEndpoint;

    public HealthController(HealthEndpoint healthEndpoint) {
        this.healthEndpoint = healthEndpoint;
    }

    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> health() {

        boolean healthy = Status.UP.equals(
                healthEndpoint.health().getStatus()
        );

        return ResponseEntity
                .status(healthy ? HttpStatus.OK
                        : HttpStatus.SERVICE_UNAVAILABLE)
                .body(Map.of("status", healthy ? "ok" : "down"));
    }
}
