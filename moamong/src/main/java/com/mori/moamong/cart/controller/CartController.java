package com.mori.moamong.cart.controller;

import lombok.RequiredArgsConstructor;

import java.util.HashMap;
import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.google.gson.Gson;
import com.mori.moamong.cart.service.CartService;
import com.mori.moamong.dto.CartItem;

@RequiredArgsConstructor
@Controller
public class CartController {
    private final CartService cartService;

    // 테스트용
    @RequestMapping(value = "/product/temp.do")
    public String temp() {
        return "product/temp";
    }

    // 장바구니 리스트 화면 이동
    @RequestMapping(value = "/cart/list.do")
    public String cart() {
        return "cart/cart";
    }

    // 장바구니 리스트 조회
    @RequestMapping(value = "/cart/list.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String cartList(@RequestParam HashMap<String, Object> map) {

        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        List<CartItem> list = cartService.getCartItems(map);

        resultMap.put("list", list);
        resultMap.put("result", "success");

        return new Gson().toJson(resultMap);
    }

    // 장바구니 상품 삭제
    @RequestMapping(value = "/cart/remove.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String removeCart(@RequestParam HashMap<String, Object> map) {

        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        cartService.removeCart(map);

        resultMap.put("result", "success");

        return new Gson().toJson(resultMap);
    }

    // 장바구니 수량 변경
    @RequestMapping(value = "/cart/update.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String updateCart(@RequestParam HashMap<String, Object> map) {

        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        cartService.updateCart(map);

        resultMap.put("result", "success");

        return new Gson().toJson(resultMap);
    }

    @RequestMapping(value = "/cart/add.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String addCart(@RequestParam HashMap<String, Object> map) {

        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        int quantity = Integer.parseInt(map.get("quantity").toString());

        if (quantity < 1) {
            resultMap.put("result", "fail");
            return new Gson().toJson(resultMap);
        }

        int cnt = cartService.addCart(map);

        if (cnt > 0) {
            resultMap.put("result", "success");
        } else {
            resultMap.put("result", "fail");
        }

        return new Gson().toJson(resultMap);
    }

    @RequestMapping(value = "/cart/deleteAll.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String deleteAllCartItems(@RequestParam HashMap<String, Object> map) {

        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        int cnt = cartService.deleteAllCartItems(map);

        if (cnt > 0) {
            resultMap.put("result", "success");
        } else {
            resultMap.put("result", "fail");
        }

        return new Gson().toJson(resultMap);
    }

}
