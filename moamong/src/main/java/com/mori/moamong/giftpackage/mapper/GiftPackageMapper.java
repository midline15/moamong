package com.mori.moamong.giftpackage.mapper;

import java.util.HashMap;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.mori.moamong.dto.GiftPackage;

@Mapper
public interface GiftPackageMapper {

    // 대상 또는 목적 기준 패키지 목록 조회
    List<GiftPackage> selectPackageList(HashMap<String, Object> map);

    // 패키지 등급별 목록 조회
    List<GiftPackage> selectPackageListByGrade(HashMap<String, Object> map);

    // 패키지 등급별 전체 개수 조회
    int selectPackageCountByGrade(HashMap<String, Object> map);

}
