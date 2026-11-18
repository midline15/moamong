package com.mori.moamong.point.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import com.mori.moamong.point.mapper.PointMapper;

@RequiredArgsConstructor
@Service
public class PointService {
    private final PointMapper pointMapper;

}
