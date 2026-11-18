package com.mori.moamong.giftpackage.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;

import com.mori.moamong.giftpackage.service.GiftPackageService;

@RequiredArgsConstructor
@Controller
public class GiftPackageController {
    private final GiftPackageService giftPackageService;

}
