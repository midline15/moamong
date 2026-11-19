package com.mori.moamong.admin.service;

import java.util.HashMap;
import java.util.List;

import org.springframework.stereotype.Service;

import com.mori.moamong.admin.mapper.AdminMapper;
import com.mori.moamong.admin.model.Admin;

import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Service
public class AdminService {
	private final AdminMapper adminMapper;

	public HashMap<String, Object> getAdminList(HashMap<String, Object> map) {
		HashMap<String, Object> resultMap = new HashMap();
		try {
			List<Admin> list = adminMapper.selectAdminList(map);
			Admin stats = adminMapper.selectStats(map);	
			resultMap.put("list", list);
			resultMap.put("stats", stats);
			resultMap.put("result", "success");
		} catch (Exception e) {
			// TODO: handle exception
			resultMap.put("result", "fail");
			System.out.println(e.getMessage());
		}
		return resultMap;
	}

}
