package com.mori.moamong.point.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;

import com.mori.moamong.point.service.PointService;

@RequiredArgsConstructor
@Controller
public class PointController {
    private final PointService pointService;

}
