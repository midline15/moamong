package com.mori.moamong.member.controller;

import java.util.List;
import java.util.Map;

import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import com.mori.moamong.member.service.MemberService;

@RestController
@RequiredArgsConstructor
public class MemberTestController {
    private final MemberService memberService;

    @GetMapping("/test/db")
    public List<Map<String, Object>> testDb() {
        return memberService.findAll();
    }
}
