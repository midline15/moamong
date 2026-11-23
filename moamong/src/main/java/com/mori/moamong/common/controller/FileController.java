package com.mori.moamong.common.controller;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import com.google.gson.Gson;

@Controller
public class FileController {

    @Value("${file.upload-dir:C:/moamong/upload}")
    private String uploadDir;

    // 허용 확장자 (svg는 스크립트가 들어갈 수 있어서 제외)
    private static final List<String> ALLOW_EXT = Arrays.asList("jpg", "jpeg", "png", "gif", "webp");

    // 에디터 이미지 업로드
    @RequestMapping(value = "/common/image-upload.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String imageUpload(@RequestParam("file") MultipartFile file) throws Exception {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        try {
            if (file.isEmpty()) {
                resultMap.put("result", "fail");
                resultMap.put("msg", "파일이 없습니다.");
                return new Gson().toJson(resultMap);
            }

            // 확장자 / 형식 검사
            String originName = file.getOriginalFilename();
            String ext = "";
            if (originName != null && originName.lastIndexOf(".") > -1) {
                ext = originName.substring(originName.lastIndexOf(".") + 1).toLowerCase();
            }
            String contentType = file.getContentType();

            if (!ALLOW_EXT.contains(ext) || contentType == null || !contentType.startsWith("image/")) {
                resultMap.put("result", "fail");
                resultMap.put("msg", "jpg, png, gif, webp 이미지만 올릴 수 있습니다.");
                return new Gson().toJson(resultMap);
            }

            // 저장 폴더 (월별로 분리)
            String month = new SimpleDateFormat("yyyyMM").format(new Date());
            File dir = new File(uploadDir + "/editor/" + month);
            if (!dir.exists()) dir.mkdirs();

            // 파일명은 UUID로 새로 생성 (원본 이름 그대로 쓰지 않음)
            String saveName = UUID.randomUUID().toString().replace("-", "") + "." + ext;
            file.transferTo(new File(dir, saveName));

            resultMap.put("result", "success");
            resultMap.put("imageUrl", "/upload/editor/" + month + "/" + saveName);
            resultMap.put("imageOriginName", originName);
            resultMap.put("imageName", saveName);
            resultMap.put("imageSize", String.valueOf(file.getSize()));
            resultMap.put("imageType", ext);
        } catch (Exception e) {
            resultMap.put("result", "fail");
            resultMap.put("msg", "업로드에 실패했습니다.");
            e.printStackTrace();
        }

        return new Gson().toJson(resultMap);
    }

}