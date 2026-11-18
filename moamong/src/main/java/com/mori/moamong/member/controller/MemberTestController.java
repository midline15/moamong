package com.mori.moamong.member.controller;

import java.util.List;
import java.util.Map;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import com.mori.moamong.member.mapper.MemberMapper;

@RestController
public class MemberTestController {

    private final MemberMapper memberMapper;

    public MemberTestController(MemberMapper memberMapper) {
        this.memberMapper = memberMapper;
    }

    @GetMapping("/test/db")
    public List<Map<String, Object>> testDb() {
        return memberMapper.findAll();
    }
}