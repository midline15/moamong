package com.mori.moamong.giftpackage.service;

import lombok.RequiredArgsConstructor;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.mori.moamong.dto.GiftPackage;
import com.mori.moamong.dto.GiftPackageExtra;
import com.mori.moamong.dto.GiftPackageExtraOption;
import com.mori.moamong.dto.GiftPackageItem;
import com.mori.moamong.dto.GiftPackageItemOption;
import com.mori.moamong.giftpackage.mapper.GiftPackageMapper;

@RequiredArgsConstructor
@Service
public class GiftPackageService {
    private final GiftPackageMapper giftPackageMapper;

    // 패키지 목록 조회
    public List<GiftPackage> getPackageList(HashMap<String, Object> map) throws Exception {

        List<GiftPackage> packageList = null;

        try {

            packageList = giftPackageMapper.selectPackageList(map);

        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        }

        return packageList;
    }

    // 패키지 등급별 목록 조회
    public List<GiftPackage> getPackageListByGrade(HashMap<String, Object> map) throws Exception {

        List<GiftPackage> packageList = null;

        try {

            int page = Integer.parseInt(String.valueOf(map.get("page")));
            int limit = 9;
            int offset = (page - 1) * limit;

            map.put("limit", limit);
            map.put("offset", offset);

            packageList = giftPackageMapper.selectPackageListByGrade(map);

        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        }

        return packageList;
    }

    // 패키지 등급별 전체 개수 조회
    public int getPackageCountByGrade(HashMap<String, Object> map) throws Exception {

        int totalCount = 0;

        try {

            totalCount = giftPackageMapper.selectPackageCountByGrade(map);

        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        }

        return totalCount;
    }

    // 패키지 상세 정보 조회 및 조회수 증가
    @Transactional(rollbackFor = Exception.class)
    public GiftPackage getPackageInfo(HashMap<String, Object> map) throws Exception {

        GiftPackage info = null;

        try {

            // 패키지 조회수 증가
            giftPackageMapper.updatePackageViewCount(map);

            // 패키지 상세 정보 조회
            info = giftPackageMapper.selectPackageInfo(map);

        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        }

        return info;
    }

    // 패키지 구성 상품 조회
    public List<GiftPackageItem> getPackageItemList(HashMap<String, Object> map) throws Exception {

        List<GiftPackageItem> packageItemList = null;

        try {

            packageItemList = giftPackageMapper.selectPackageItemList(map);

        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        }

        return packageItemList;
    }

    // 패키지 구성 상품 교체 옵션 조회
    public List<GiftPackageItemOption> getPackageItemOptionList(HashMap<String, Object> map) throws Exception {

        List<GiftPackageItemOption> packageItemOptionList = null;

        try {

            packageItemOptionList = giftPackageMapper.selectPackageItemOptionList(map);

        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        }

        return packageItemOptionList;
    }

    // 패키지 추가 구성 유형 조회
    public List<GiftPackageExtra> getPackageExtraList(HashMap<String, Object> map) throws Exception {

        List<GiftPackageExtra> packageExtraList = null;

        try {

            packageExtraList = giftPackageMapper.selectPackageExtraList(map);

        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        }

        return packageExtraList;
    }

    // 패키지 추가 구성 옵션 조회
    public List<GiftPackageExtraOption> getPackageExtraOptionList(HashMap<String, Object> map) throws Exception {

        List<GiftPackageExtraOption> packageExtraOptionList = null;

        try {

            packageExtraOptionList = giftPackageMapper.selectPackageExtraOptionList(map);

        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        }

        return packageExtraOptionList;
    }
}
