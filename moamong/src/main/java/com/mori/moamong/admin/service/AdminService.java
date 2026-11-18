package com.mori.moamong.admin.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import com.mori.moamong.admin.mapper.AdminMapper;

@RequiredArgsConstructor
@Service
public class AdminService {
    private final AdminMapper adminMapper;

}
