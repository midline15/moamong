package com.mori.moamong.common.controller;

import java.io.File;
import java.nio.file.Path;
import java.nio.file.Paths;
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
import com.google.gson.reflect.TypeToken;
import com.mori.moamong.common.mapper.FileMapper;

import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Controller
public class FileController {

    private final FileMapper fileMapper;

    @Value("${file.upload-dir:src/main/webapp/resources/upload}")
    private String uploadDir;

    // 허용 확장자 (svg는 스크립트가 들어갈 수 있어서 제외)
    private static final List<String> ALLOW_EXT = Arrays.asList("jpg", "jpeg", "png", "gif", "webp");

    // 내가 저장할 수 있는 폴더 (다른 팀원 폴더는 허용하지 않음)
    private static final List<String> ALLOW_TYPE = Arrays.asList("community", "inquiry", "notice","event");

    // 에디터 이미지 업로드 (type: community / inquiry / notice)
    @RequestMapping(value = "/common/image-upload.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String imageUpload(@RequestParam("file") MultipartFile file,
            @RequestParam(value = "type", defaultValue = "") String type) throws Exception {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        try {
            if (!ALLOW_TYPE.contains(type)) {
                resultMap.put("result", "fail");
                resultMap.put("msg", "허용되지 않은 업로드 위치입니다.");
                return new Gson().toJson(resultMap);
            }
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

            // 저장 폴더: upload/기능/연월
            String month = new SimpleDateFormat("yyyyMM").format(new Date());
            File dir = new File(new File(uploadDir).getAbsoluteFile(), type + "/" + month);
            if (!dir.exists()) dir.mkdirs();

            // 파일명은 UUID로 새로 생성 (원본 이름 그대로 쓰지 않음)
            String saveName = UUID.randomUUID().toString().replace("-", "") + "." + ext;
            file.transferTo(new File(dir, saveName));

            resultMap.put("result", "success");
            resultMap.put("imageUrl", "/resources/upload/" + type + "/" + month + "/" + saveName);
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

    // 에디터 이미지 삭제 (작성 취소 시, 아직 글에 연결되지 않은 임시 파일만)
    @RequestMapping(value = "/common/image-delete.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String imageDelete(@RequestParam("urls") String urls) throws Exception {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        try {
            List<String> list = new Gson().fromJson(urls, new TypeToken<List<String>>() {}.getType());
            Path base = Paths.get(uploadDir).toAbsolutePath().normalize();
            int deleted = 0;

            for (String url : list) {
                if (url == null || !url.startsWith("/resources/upload/")) continue;

                // 내 폴더(community / inquiry / notice) 파일만 삭제 가능
                String rel = url.substring("/resources/upload/".length());
                String top = rel.contains("/") ? rel.substring(0, rel.indexOf("/")) : "";
                if (!ALLOW_TYPE.contains(top)) continue;

                // ../ 같은 경로 조작 차단
                Path target = base.resolve(rel).normalize();
                if (!target.startsWith(base.resolve(top))) continue;

                // 이미 DB에 연결된 이미지면 지우지 않음
                if (fileMapper.selectImageUsedCnt(url) > 0) continue;

                if (target.toFile().delete()) deleted++;
            }

            resultMap.put("deleted", deleted);
            resultMap.put("result", "success");
        } catch (Exception e) {
            resultMap.put("result", "fail");
            e.printStackTrace();
        }

        return new Gson().toJson(resultMap);
    }

}