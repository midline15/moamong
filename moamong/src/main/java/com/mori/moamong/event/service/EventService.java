package com.mori.moamong.event.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import com.mori.moamong.event.mapper.EventMapper;

@RequiredArgsConstructor
@Service
public class EventService {
    private final EventMapper eventMapper;

}
