package com.mori.moamong.member.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;

import com.mori.moamong.member.service.MemberService;

@RequiredArgsConstructor
@Controller
public class MemberController {
    private final MemberService memberService;

}
