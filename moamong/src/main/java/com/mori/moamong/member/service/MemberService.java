package com.mori.moamong.member.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import com.mori.moamong.member.mapper.MemberMapper;

@Service
@RequiredArgsConstructor
public class MemberService {
    private final MemberMapper memberMapper;

    public List<Map<String, Object>> findAll() {
        return memberMapper.findAll();
    }

}
