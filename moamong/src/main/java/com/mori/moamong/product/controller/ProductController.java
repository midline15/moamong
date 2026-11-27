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

		Category category = categoryService.getCategoryById(map);

		model.addAttribute("categoryId", map.get("categoryId"));
		model.addAttribute("categoryName", category.getCategoryName());

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

	// 메인카테고리, 서브카테고리, 메인카테고리에 해당하는 상품리스트 조회
	@RequestMapping(value = "/product/list.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public String list(Model model, @RequestParam HashMap<String, Object> map) throws Exception {

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
	public String add(Model model, @RequestParam HashMap<String, Object> map,
			@RequestParam(value = "productImageList", required = false) MultipartFile[] productImageList,
			@RequestParam(value = "thumbnailImage", required = false) MultipartFile thumbnailImage) throws Exception {

		HashMap<String, Object> resultMap = new HashMap<String, Object>();

		// 상품 등록 및 이미지 업로드 처리
		int result = productService.addProduct(map, thumbnailImage, productImageList);

		resultMap.put("result", result);

		return new Gson().toJson(resultMap);
	}

	// 상품 수정, 이미지교체
	@RequestMapping(value = "/product/edit.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public String editDox(Model model, @RequestParam HashMap<String, Object> map,
			@RequestParam(value = "productImageList", required = false) MultipartFile[] productImageList,
			@RequestParam(value = "thumbnailImage", required = false) MultipartFile thumbnailImage) throws Exception {

		HashMap<String, Object> resultMap = new HashMap<String, Object>();

		int result = productService.editProduct(map, thumbnailImage, productImageList);

		resultMap.put("result", result);

		return new Gson().toJson(resultMap);
	}

	// 관리자 콘솔 - 상품(단품) 조회
	@ResponseBody
	@RequestMapping(value = "/admin/product/list.dox", method = RequestMethod.POST)
	public HashMap<String, Object> adminProductList(@RequestParam HashMap<String, Object> map) {

		HashMap<String, Object> result = new HashMap<>();

		// 페이지 정보
		int page = Integer.parseInt(map.get("page").toString());
		int pageSize = Integer.parseInt(map.get("pageSize").toString());

		// 검색 조건 전달
		map.put("pageSize", pageSize);
		map.put("offset", (page - 1) * pageSize);

		// 상품 목록 및 전체 개수
		result.put("productList", productService.getAdminProductList(map));
		result.put("totalCount", productService.getAdminProductCount(map));

		return result;
	}

	// 관리자 콘솔 - 상품(단품) 삭제
	@ResponseBody
	@RequestMapping(value = "/admin/product/remove.dox", method = RequestMethod.POST)
	public HashMap<String, Object> adminProductRemove(@RequestParam HashMap<String, Object> map) {

		HashMap<String, Object> result = new HashMap<>();

		if (map.get("productId") == null) {
			result.put("result", "fail");
			result.put("msg", "상품 정보가 없습니다.");
			return result;
		}

		// 삭제 상태로 변경
		map.put("productStatus", "DELETE");

		int count = productService.editProductStatus(map);

		if (count > 0) {
			result.put("result", "success");
			result.put("msg", "상품이 삭제되었습니다.");
		} else {
			result.put("result", "fail");
			result.put("msg", "상품 삭제에 실패했습니다.");
		}

		return result;
	}

}
// // 상품 상태 수정(SELLING / SOLD_OUT / HIDDEN / DELETE)
// @RequestMapping(value = "/product/statusEdit.dox", method =
// RequestMethod.POST, produces = "application/json;charset=UTF-8")
// @ResponseBody
// public String statusEdit(
// Model model,
// @RequestParam HashMap<String, Object> map) throws Exception {

// HashMap<String, Object> resultMap = new HashMap<String, Object>();

// int result = productService.editProductStatus(map);

// resultMap.put("result", result);

// return new Gson().toJson(resultMap);
// }
