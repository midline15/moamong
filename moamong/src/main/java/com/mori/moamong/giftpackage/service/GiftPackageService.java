package com.mori.moamong.giftpackage.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import com.mori.moamong.giftpackage.mapper.GiftPackageMapper;

@RequiredArgsConstructor
@Service
public class GiftPackageService {
    private final GiftPackageMapper giftPackageMapper;

}
