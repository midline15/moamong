package com.mori.moamong.admin.controller;

import java.util.HashMap;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.google.gson.Gson;
import com.mori.moamong.admin.service.AdminService;

import ch.qos.logback.core.model.Model;
import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Controller
public class AdminController {
    private final AdminService adminService;
    
    @RequestMapping("/admin/list.do")
    public String admin(Model model) throws Exception {

        // WEB-INF/product/add.jsp 파일을 화면에 보여줍니다.
        return "/admin/list";
    }
    
    
    
    @RequestMapping("/admin/view.do")
    public String view(Model model) throws Exception {

        // WEB-INF/product/add.jsp 파일을 화면에 보여줍니다.
        return "/admin/view";
    }
    
    
    @RequestMapping(value = "/admin/list.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public String admin(Model model, @RequestParam HashMap<String, Object> map) throws Exception {
		HashMap<String, Object> resultMap = new HashMap<String, Object>();	
		resultMap = adminService.getAdminList(map);	
		return new Gson().toJson(resultMap); 
	}
	
    

 
}




