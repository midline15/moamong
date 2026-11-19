package com.mori.moamong.inquiry.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import com.mori.moamong.inquiry.mapper.InquiryMapper;

@RequiredArgsConstructor
@Service
public class InquiryService {
    private final InquiryMapper inquiryMapper;

}
