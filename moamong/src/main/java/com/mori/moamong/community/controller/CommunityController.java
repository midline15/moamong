package com.mori.moamong.community.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;

import com.mori.moamong.community.service.CommunityService;

@RequiredArgsConstructor
@Controller
public class CommunityController {
    private final CommunityService communityService;

}
