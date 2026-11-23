package com.mori.moamong.payment.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class PaymentController {

	@Value("${portone.imp.code}")
	private String impCode;

	@RequestMapping("/payment/index.do")
	public String paymentIndex(Model model) {
		model.addAttribute("impCode", impCode);
		return "payment/index";
	}
}
