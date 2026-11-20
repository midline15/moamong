package com.mori.moamong.product.controller;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import com.google.gson.Gson;
import com.mori.moamong.category.service.CategoryService;
import com.mori.moamong.dto.Category;
import com.mori.moamong.dto.Product;
import com.mori.moamong.product.service.ProductService;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Controller
public class ProductController {
    private final ProductService productService;
    private final CategoryService categoryService;

    // 상품 카테고리별 목록으로 이동
    @RequestMapping("/product/list.do")
    public String list(@RequestParam HashMap<String, Object> map, Model model) {

        return "product/list";
    }

    // 세부 카테고리 상품 목록으로 이동
    @RequestMapping("/product/subList.do")
    public String subList(@RequestParam HashMap<String, Object> map, Model model) {

        model.addAttribute("categoryId", map.get("categoryId"));

        return "product/subList";
    }

    // 상품 상세 페이지로 이동
    // 세션에 상품아이디 등록해서 무분별한 조회수 증가 방지
    @RequestMapping("/product/view.do")
    public String view(@RequestParam HashMap<String, Object> map, Model model, HttpSession session) {

        String productId = map.get("productId").toString();

        ArrayList<String> viewList = (ArrayList<String>) session.getAttribute("viewList");

        if (viewList == null) {
            viewList = new ArrayList<String>();
        }

        if (!viewList.contains(productId)) {
            productService.updateProductViewCount(map);
            viewList.add(productId);
        }

        session.setAttribute("viewList", viewList);

        model.addAttribute("productId", productId);

        return "product/view";
    }

    // 상품 추가, 관리자 권한 설정 추가 필요
    @RequestMapping("/product/add.do")
    public String add(Model model) {
        return "product/add";
    }

    // 상품 수정페이지로 이동
    @RequestMapping("/product/edit.do")
    public String edit(@RequestParam HashMap<String, Object> map, Model model) {
        model.addAttribute("productId", map.get("productId"));
        return "product/edit";
    }

    // 메인카테고리, 서브카테고리, 메인카테고리에 해당하는 상품리스트 조회
    @RequestMapping(value = "/product/list.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String login(Model model, @RequestParam HashMap<String, Object> map) throws Exception {

        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        List<Category> mainCategoryList = categoryService.getMainCategoryList(map);
        List<Category> subCategoryList = categoryService.getSubCategoryList(map);
        List<Product> productList = productService.getProductListByMainCategory(map);

        resultMap.put("mainCategoryList", mainCategoryList);
        resultMap.put("subCategoryList", subCategoryList);
        resultMap.put("productList", productList);

        return new Gson().toJson(resultMap);
    }

    // 세부 카테고리에 해당하는 상품 목록조회, 페이징을 위해 상품 수 조회
    @RequestMapping(value = "/product/subList.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String subList(Model model, @RequestParam HashMap<String, Object> map) throws Exception {

        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        List<Product> productList = productService.getProductListBySubCategory(map);
        int totalCount = productService.getProductCountBySubCategory(map);

        resultMap.put("productList", productList);
        resultMap.put("totalCount", totalCount);

        return new Gson().toJson(resultMap);
    }

    // 상품 상세 정보 조회
    @RequestMapping(value = "/product/view.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String view(Model model, @RequestParam HashMap<String, Object> map) throws Exception {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        Product info = productService.getProductInfo(map);

        resultMap.put("info", info);

        return new Gson().toJson(resultMap);
    }

    // 상품 추가, 이미지 업로드
    @RequestMapping(value = "/product/add.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String add(Model model,
            @RequestParam HashMap<String, Object> map,
            @RequestParam(value = "productImageList", required = false) MultipartFile[] productImageList,
            @RequestParam(value = "thumbnailImage", required = false) MultipartFile thumbnailImage)
            throws Exception {

        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        // 상품 등록 및 이미지 업로드 처리
        int result = productService.addProduct(map, thumbnailImage, productImageList);

        resultMap.put("result", result);

        return new Gson().toJson(resultMap);
    }

    // 상품 수정, 이미지교체
    @RequestMapping(value = "/product/edit.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String editDox(
            Model model,
            @RequestParam HashMap<String, Object> map,
            @RequestParam(value = "productImageList", required = false) MultipartFile[] productImageList,
            @RequestParam(value = "thumbnailImage", required = false) MultipartFile thumbnailImage)
            throws Exception {

        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        int result = productService.editProduct(map, thumbnailImage, productImageList);

        resultMap.put("result", result);

        return new Gson().toJson(resultMap);
    }

}
