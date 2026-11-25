package com.mori.moamong.giftpackage.mapper;

import java.util.HashMap;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.mori.moamong.dto.GiftPackage;
import com.mori.moamong.dto.GiftPackageExtra;
import com.mori.moamong.dto.GiftPackageExtraOption;
import com.mori.moamong.dto.GiftPackageItem;
import com.mori.moamong.dto.GiftPackageItemOption;

@Mapper
public interface GiftPackageMapper {

    // 대상 또는 목적 기준 패키지 목록 조회
    List<GiftPackage> selectPackageList(HashMap<String, Object> map);

    // 패키지 등급별 목록 조회
    List<GiftPackage> selectPackageListByGrade(HashMap<String, Object> map);

    // 패키지 등급별 전체 개수 조회
    int selectPackageCountByGrade(HashMap<String, Object> map);

    // 패키지 상세 정보 조회
    GiftPackage selectPackageInfo(HashMap<String, Object> map);

    // 패키지 조회수 증가
    int updatePackageViewCount(HashMap<String, Object> map);

    // 패키지 구성 상품 조회
    List<GiftPackageItem> selectPackageItemList(HashMap<String, Object> map);

    // 패키지 구성 상품 교체 옵션 조회
    List<GiftPackageItemOption> selectPackageItemOptionList(HashMap<String, Object> map);

    // 패키지 추가 구성 유형 조회
    List<GiftPackageExtra> selectPackageExtraList(HashMap<String, Object> map);

    // 패키지 추가 구성 옵션 조회
    List<GiftPackageExtraOption> selectPackageExtraOptionList(HashMap<String, Object> map);
}
