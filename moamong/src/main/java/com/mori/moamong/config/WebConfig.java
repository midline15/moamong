package com.mori.moamong.config;

import java.nio.file.Path;
import java.nio.file.Paths;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // 업로드 폴더(webapp/resources/upload)를 /resources/upload/** 주소로 연결
        Path upload = Paths.get("src/main/webapp/resources/upload").toAbsolutePath().normalize();
        registry.addResourceHandler("/resources/upload/**")
                .addResourceLocations(upload.toUri().toString());
    }

}