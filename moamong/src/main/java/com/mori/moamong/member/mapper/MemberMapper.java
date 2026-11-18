package com.mori.moamong.member.mapper;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;

import com.mori.moamong.dto.Member;

@Mapper
public interface MemberMapper {
    List<Map<String, Object>> findAll();

    // 멤버조회
    Member selectMember(HashMap<String, Object> map);
}
