package com.mori.moamong.inquiry.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;

import com.mori.moamong.inquiry.service.InquiryService;

@RequiredArgsConstructor
@Controller
public class InquiryController {
    private final InquiryService inquiryService;

}
