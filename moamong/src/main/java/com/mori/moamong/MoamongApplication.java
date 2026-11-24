package com.mori.moamong;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@EnableScheduling
@SpringBootApplication
public class MoamongApplication {

	public static void main(String[] args) {
		SpringApplication.run(MoamongApplication.class, args);
	}

}