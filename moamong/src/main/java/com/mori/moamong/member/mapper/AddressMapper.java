package com.mori.moamong.member.mapper;

import java.util.HashMap;
import java.util.List;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface AddressMapper {
    List<HashMap<String, Object>> selectAddressList(Long memberId);
    HashMap<String, Object> selectAddressOne(HashMap<String, Object> map);
    HashMap<String, Object> selectDefaultAddress(Long memberId);
    int countAddressByMemberId(Long memberId);
    int resetDefaultAddress(Long memberId);
    int updateDefaultAddress(HashMap<String, Object> map);
    int insertAddress(HashMap<String, Object> map);
    int updateAddress(HashMap<String, Object> map);
    int deleteAddress(HashMap<String, Object> map);
}
