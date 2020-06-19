package com.example.demo;

import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.beans.factory.annotation.Value;

import java.text.SimpleDateFormat;
import java.util.Date;

@Slf4j
@Component
public class ScheduledLogger {

    private static final SimpleDateFormat dateFormat = new SimpleDateFormat("HH:mm:ss");

    @Value("${david.init.welcome-message}")
    private String message;

    @Value("${david.init.welcome-url}")
    private String url;


    @Value("${spring.application.name}")
    private String applicationName;


    @Scheduled(fixedRate = 50000)
    public void reportCurrentTime() {
        Date date = new Date();
        log.info("welcome-to-app: {}", applicationName);
        log.info("welcome-message: {}", message);
        log.info("welcome-url: {}", url);
        log.info("The time is now {}", dateFormat.format(date));
    }
}