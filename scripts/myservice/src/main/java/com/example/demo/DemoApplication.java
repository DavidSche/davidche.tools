package com.example.demo;

import org.springframework.boot.*;
import org.springframework.boot.autoconfigure.*;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.web.bind.annotation.*;

@SpringBootApplication
@RestController
@EnableScheduling
public class DemoApplication {

    @GetMapping("/")
    String home() {
        return "我的第一个Spring RESTful 微服务Demo,run in docker!";
    }

    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }
}