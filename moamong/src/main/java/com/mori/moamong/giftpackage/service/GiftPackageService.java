package com.mori.moamong.giftpackage.service;

import lombok.RequiredArgsConstructor;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import org.springframework.stereotype.Service;

import com.mori.moamong.dto.GiftPackage;
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

}
