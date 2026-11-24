package com.mori.moamong.member.service;

import java.util.HashMap;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.mori.moamong.member.mapper.AddressMapper;
import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Service
public class AddressService {

    private final AddressMapper addressMapper;

    // 내 배송지 전체 목록 조회
    public HashMap<String, Object> getAddressList(Long memberId) {
        HashMap<String, Object> res = new HashMap<>();
        List<HashMap<String, Object>> list = addressMapper.selectAddressList(memberId);
        res.put("result", "success");
        res.put("list", list);
        return res;
    }

    // 주문서(Checkout)용 기본 배송지 1건 조회
    public HashMap<String, Object> getDefaultAddress(Long memberId) {
        HashMap<String, Object> res = new HashMap<>();
        HashMap<String, Object> address = addressMapper.selectDefaultAddress(memberId);
        res.put("result", "success");
        res.put("address", address);
        return res;
    }

    // 신규 배송지 등록 (첫 등록 시 자동 기본 배송지 지정)
    @Transactional
    public HashMap<String, Object> addAddress(HashMap<String, Object> paramMap) {
        HashMap<String, Object> res = new HashMap<>();
        Long memberId = Long.parseLong(String.valueOf(paramMap.get("memberId")));

        int existingCount = addressMapper.countAddressByMemberId(memberId);
        int isDefault = paramMap.get("isDefault") != null
                ? Integer.parseInt(String.valueOf(paramMap.get("isDefault"))) : 0;

        if (existingCount == 0) {
            isDefault = 1;
        }
        if (isDefault == 1) {
            addressMapper.resetDefaultAddress(memberId);
        }

        paramMap.put("isDefault", isDefault);
        addressMapper.insertAddress(paramMap);

        res.put("result", "success");
        res.put("addressId", paramMap.get("addressId"));
        res.put("message", "배송지가 등록되었습니다.");
        return res;
    }

    // 기존 배송지 정보 수정 및 기본 배송지 여부 갱신
    @Transactional
    public HashMap<String, Object> editAddress(HashMap<String, Object> paramMap) {
        HashMap<String, Object> res = new HashMap<>();
        Long memberId = Long.parseLong(String.valueOf(paramMap.get("memberId")));

        HashMap<String, Object> origin = addressMapper.selectAddressOne(paramMap);
        if (origin == null) {
            res.put("result", "fail");
            res.put("message", "존재하지 않거나 접근 권한이 없는 배송지입니다.");
            return res;
        }

        int isDefault = paramMap.get("isDefault") != null
                ? Integer.parseInt(String.valueOf(paramMap.get("isDefault"))) : 0;

        if (isDefault == 1) {
            addressMapper.resetDefaultAddress(memberId);
        }

        paramMap.put("isDefault", isDefault);
        addressMapper.updateAddress(paramMap);

        res.put("result", "success");
        res.put("message", "배송지가 수정되었습니다.");
        return res;
    }
    // 특정 배송지를 기본 배송지로 단독 변경
    @Transactional
    public HashMap<String, Object> setDefaultAddress(HashMap<String, Object> paramMap) {
        HashMap<String, Object> res = new HashMap<>();
        Long memberId = Long.parseLong(String.valueOf(paramMap.get("memberId")));

        HashMap<String, Object> origin = addressMapper.selectAddressOne(paramMap);
        if (origin == null) {
            res.put("result", "fail");
            res.put("message", "존재하지 않는 배송지입니다.");
            return res;
        }

        addressMapper.resetDefaultAddress(memberId);
        addressMapper.updateDefaultAddress(paramMap);

        res.put("result", "success");
        res.put("message", "기본 배송지로 설정되었습니다.");
        return res;
    }

    // 배송지 삭제 (기본 배송지 삭제 시 남은 최신 배송지를 기본으로 자동 승격)
    @Transactional
    public HashMap<String, Object> removeAddress(HashMap<String, Object> paramMap) {
        HashMap<String, Object> res = new HashMap<>();
        Long memberId = Long.parseLong(String.valueOf(paramMap.get("memberId")));

        HashMap<String, Object> origin = addressMapper.selectAddressOne(paramMap);
        if (origin == null) {
            res.put("result", "fail");
            res.put("message", "존재하지 않는 배송지입니다.");
            return res;
        }

        int wasDefault = Integer.parseInt(String.valueOf(origin.get("isDefault")));
        addressMapper.deleteAddress(paramMap);

        if (wasDefault == 1) {
            HashMap<String, Object> nextDefault = addressMapper.selectDefaultAddress(memberId);
            if (nextDefault != null) {
                HashMap<String, Object> updateMap = new HashMap<>();
                updateMap.put("memberId", memberId);
                updateMap.put("addressId", nextDefault.get("addressId"));
                addressMapper.updateDefaultAddress(updateMap);
            }
        }

        res.put("result", "success");
        res.put("message", "배송지가 삭제되었습니다.");
        return res;
    }
}

