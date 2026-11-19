package com.mori.moamong.notice.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import com.mori.moamong.notice.mapper.NoticeMapper;

@RequiredArgsConstructor
@Service
public class NoticeService {
    private final NoticeMapper noticeMapper;

}
