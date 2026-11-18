package com.mori.moamong.event.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;

import com.mori.moamong.event.service.EventService;

@RequiredArgsConstructor
@Controller
public class EventController {
    private final EventService eventService;

}
