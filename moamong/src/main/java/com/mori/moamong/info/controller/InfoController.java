package com.mori.moamong.info.controller;

import java.util.HashMap;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import com.mori.moamong.info.mapper.InfoMapper;

@Controller
@RequestMapping("/info")
public class InfoController {

    @Autowired
    private InfoMapper infoMapper;

    @GetMapping("/about.do")
    public String about() { return "info/about"; }

    @GetMapping("/terms.do")
    public String terms() { return "info/terms"; }

    @GetMapping("/privacy.do")
    public String privacy() { return "info/privacy"; }

    @GetMapping("/guide.do")
    public String guide() { return "info/guide"; }

    @GetMapping("/shipping.do")
    public String shipping() { return "info/shipping"; }

    @PostMapping("/policies.dox")
    @ResponseBody
    public HashMap<String, Object> getPolicies() {
        HashMap<String, Object> resultMap = new HashMap<>();
        resultMap.put("result", "success");
        resultMap.put("list", infoMapper.selectActivePolicies());
        return resultMap;
    }
}

