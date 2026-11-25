package com.mori.moamong.giftpackage.controller;

import lombok.RequiredArgsConstructor;

import java.util.HashMap;
import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.google.gson.Gson;
import com.mori.moamong.dto.GiftPackage;
import com.mori.moamong.dto.GiftPackageExtra;
import com.mori.moamong.dto.GiftPackageExtraOption;
import com.mori.moamong.dto.GiftPackageItem;
import com.mori.moamong.dto.GiftPackageItemOption;
import com.mori.moamong.giftpackage.service.GiftPackageService;

@RequiredArgsConstructor
@Controller
public class GiftPackageController {
    private final GiftPackageService giftPackageService;
    // 조회수 마구증가 방지추가하기

    // 패키지 카테고리별 목록으로 이동
    @RequestMapping("/package/list.do")
    public String list(@RequestParam HashMap<String, Object> map, Model model) {
        return "giftpackage/list";
    }

    // 패키지 등급별 목록 페이지 이동
    @RequestMapping("/package/grade.do")
    public String grade(@RequestParam HashMap<String, Object> map, Model model) {

        model.addAttribute("packageGrade", map.get("packageGrade"));

        return "giftpackage/grade";
    }

    // 패키지 상세 페이지 이동
    @RequestMapping("/package/view.do")
    public String view(@RequestParam HashMap<String, Object> map, Model model) {

        model.addAttribute("packageId", map.get("packageId"));

        return "giftpackage/view";
    }

    // 대상이나 목적에 해당하는 패키지 리스트 조회
    // FAMILY / COUPLE / FRIEND / COLLEAGUE / SELF
    // BIRTHDAY_ANNIVERSARY / THANKS / CONGRATULATIONS / COMFORT
    @RequestMapping(value = "/package/list.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String list(Model model, @RequestParam HashMap<String, Object> map) throws Exception {

        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        List<GiftPackage> packageList = giftPackageService.getPackageList(map);

        resultMap.put("packageList", packageList);

        return new Gson().toJson(resultMap);
    }

    // 패키지 등급별 목록 조회
    @RequestMapping(value = "/package/grade.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String gradeList(Model model, @RequestParam HashMap<String, Object> map) throws Exception {

        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        List<GiftPackage> packageList = giftPackageService.getPackageListByGrade(map);
        int totalCount = giftPackageService.getPackageCountByGrade(map);

        resultMap.put("packageList", packageList);
        resultMap.put("totalCount", totalCount);

        return new Gson().toJson(resultMap);
    }

    // 패키지 상세 정보 조회
    @RequestMapping(value = "/package/view.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String view(Model model, @RequestParam HashMap<String, Object> map) throws Exception {

        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        // 패키지 상세 정보 조회
        GiftPackage info = giftPackageService.getPackageInfo(map);

        // 패키지 구성 상품 조회
        List<GiftPackageItem> packageItemList = giftPackageService.getPackageItemList(map);

        // 패키지 구성 상품 교체 옵션 조회
        List<GiftPackageItemOption> packageItemOptionList = giftPackageService.getPackageItemOptionList(map);

        // 패키지 추가 구성 유형 조회
        List<GiftPackageExtra> packageExtraList = giftPackageService.getPackageExtraList(map);

        // 패키지 추가 구성 옵션 조회
        List<GiftPackageExtraOption> packageExtraOptionList = giftPackageService.getPackageExtraOptionList(map);

        resultMap.put("info", info);
        resultMap.put("packageItemList", packageItemList);
        resultMap.put("packageItemOptionList", packageItemOptionList);
        resultMap.put("packageExtraList", packageExtraList);
        resultMap.put("packageExtraOptionList", packageExtraOptionList);

        return new Gson().toJson(resultMap);
    }
}
