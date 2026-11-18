package com.mori.moamong.admin.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;

import com.mori.moamong.admin.service.AdminService;

@RequiredArgsConstructor
@Controller
public class AdminController {
    private final AdminService adminService;

}
