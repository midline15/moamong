package com.mori.moamong.member.controller;

import java.util.HashMap;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import com.mori.moamong.member.service.AddressService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Controller
public class AddressController {

    private final AddressService addressService;

    @RequestMapping(value = "/address/list.do")
    public String addressPage(HttpSession session) {
        if (session.getAttribute("sessionId") == null) {
            return "redirect:/member/login.do";
        }
        return "member/address";
    }

    @RequestMapping(value = "/address/list.dox", method = RequestMethod.POST)
    @ResponseBody
    public HashMap<String, Object> addressList(HttpSession session) {
        Long memberId = getSessionMemberId(session);
        if (memberId == null) return unauthorizedMap();
        return addressService.getAddressList(memberId);
    }

    @RequestMapping(value = "/address/default.dox", method = RequestMethod.POST)
    @ResponseBody
    public HashMap<String, Object> defaultAddress(HttpSession session) {
        Long memberId = getSessionMemberId(session);
        if (memberId == null) return unauthorizedMap();
        return addressService.getDefaultAddress(memberId);
    }

    @RequestMapping(value = "/address/add.dox", method = RequestMethod.POST, consumes = "application/json")
    @ResponseBody
    public HashMap<String, Object> addAddress(@RequestBody HashMap<String, Object> paramMap, HttpSession session) {
        Long memberId = getSessionMemberId(session);
        if (memberId == null) return unauthorizedMap();
        paramMap.put("memberId", memberId);
        return addressService.addAddress(paramMap);
    }

    @RequestMapping(value = "/address/update.dox", method = RequestMethod.POST, consumes = "application/json")
    @ResponseBody
    public HashMap<String, Object> updateAddress(@RequestBody HashMap<String, Object> paramMap, HttpSession session) {
        Long memberId = getSessionMemberId(session);
        if (memberId == null) return unauthorizedMap();
        paramMap.put("memberId", memberId);
        return addressService.editAddress(paramMap);
    }

    @RequestMapping(value = "/address/setDefault.dox", method = RequestMethod.POST)
    @ResponseBody
    public HashMap<String, Object> setDefaultAddress(@RequestParam("addressId") Long addressId, HttpSession session) {
        Long memberId = getSessionMemberId(session);
        if (memberId == null) return unauthorizedMap();
        HashMap<String, Object> paramMap = new HashMap<>();
        paramMap.put("memberId", memberId);
        paramMap.put("addressId", addressId);
        return addressService.setDefaultAddress(paramMap);
    }

    @RequestMapping(value = "/address/remove.dox", method = RequestMethod.POST)
    @ResponseBody
    public HashMap<String, Object> removeAddress(@RequestParam("addressId") Long addressId, HttpSession session) {
        Long memberId = getSessionMemberId(session);
        if (memberId == null) return unauthorizedMap();
        HashMap<String, Object> paramMap = new HashMap<>();
        paramMap.put("memberId", memberId);
        paramMap.put("addressId", addressId);
        return addressService.removeAddress(paramMap);
    }

    private Long getSessionMemberId(HttpSession session) {
        Object idObj = session.getAttribute("sessionId");
        return idObj == null ? null : Long.parseLong(String.valueOf(idObj));
    }

    private HashMap<String, Object> unauthorizedMap() {
        HashMap<String, Object> map = new HashMap<>();
        map.put("result", "fail");
        map.put("message", "로그인이 필요합니다.");
        return map;
    }
}
