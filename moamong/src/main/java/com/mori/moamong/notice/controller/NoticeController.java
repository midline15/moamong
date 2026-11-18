package com.mori.moamong.notice.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;

import com.mori.moamong.notice.service.NoticeService;

@RequiredArgsConstructor
@Controller
public class NoticeController {
    private final NoticeService noticeService;

}
