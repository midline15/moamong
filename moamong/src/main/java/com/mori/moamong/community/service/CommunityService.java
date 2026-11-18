package com.mori.moamong.community.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import com.mori.moamong.community.mapper.CommunityMapper;

@RequiredArgsConstructor
@Service
public class CommunityService {
    private final CommunityMapper communityMapper;

}
