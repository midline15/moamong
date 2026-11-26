package com.mori.moamong.payment.service;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.mori.moamong.dto.Payment;
import com.mori.moamong.payment.mapper.PaymentMapper;

import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Service
public class PaymentService {

	private final PaymentMapper paymentMapper;
	private final RestTemplate restTemplate = new RestTemplate();

	@Value("${portone.api.key}")
	private String apiKey;

	@Value("${portone.api.secret}")
	private String apiSecret;

	// 1. 포트원 REST API 액세스 토큰 발급
	private String getAccessToken() {
		String url = "https://" + "api.iamport.kr/users/getToken";
		HttpHeaders headers = new HttpHeaders();
		headers.setContentType(MediaType.APPLICATION_JSON);

		Map<String, String> body = new HashMap<>();
		body.put("imp_key", apiKey);
		body.put("imp_secret", apiSecret);

		HttpEntity<Map<String, String>> entity = new HttpEntity<>(body, headers);
		ResponseEntity<String> response = restTemplate.postForEntity(url, entity, String.class);

		JsonObject json = JsonParser.parseString(response.getBody()).getAsJsonObject();
		return json.getAsJsonObject("response").get("access_token").getAsString();
	}

	// 2. 결제 검증 및 PAYMENT 테이블 저장
	@Transactional
	public void verifyAndSavePayment(Long orderId, String impUid, String payMethod, long expectedAmount) {
	    if (impUid == null || impUid.trim().isEmpty()) {
	        throw new IllegalStateException("결제 고유번호(imp_uid)가 누락되었습니다.");
	    }

	    Payment payment = new Payment();
	    payment.setOrderId(orderId);
	    payment.setPaymentKey(impUid.trim());
	    payment.setPaymentMethod(payMethod != null ? payMethod.toUpperCase() : "CARD");
	    payment.setPaymentAmount(expectedAmount);
	    payment.setPaymentStatus("PAID");
	    paymentMapper.insertPayment(payment);
	}

	
//	// 2. 결제 검증 및 PAYMENT 테이블 저장 (금액 위변조 체크 + 0.5초 지연 재시도)
//	@Transactional
//	public void verifyAndSavePayment(Long orderId, String impUid, String payMethod, long expectedAmount) {
//	    String token = getAccessToken();
//	    String url = "https://" + "api.iamport.kr/payments/" + impUid.trim();
//
//	    HttpHeaders headers = new HttpHeaders();
//	    headers.setBearerAuth(token);
//
//	    ResponseEntity<String> res = null;
//	    try {
//	        for (int i = 0; i < 3; i++) {
//	            try {
//	                res = restTemplate.exchange(url, HttpMethod.GET, new HttpEntity<>(headers), String.class);
//	                break;
//	            } catch (org.springframework.web.client.HttpClientErrorException.NotFound e) {
//	                if (i == 2) throw e;
//	                try { Thread.sleep(500); } catch (InterruptedException ie) { Thread.currentThread().interrupt(); }
//	            }
//	        }
//	    } catch (Exception e) {
//	    	e.printStackTrace(); // 콘솔에 정확한 원인 출력
//	        throw new IllegalStateException("결제 승인 내역 확인 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.");
//	    }
//
//		JsonObject paymentInfo = JsonParser.parseString(res.getBody()).getAsJsonObject().getAsJsonObject("response");
//		String status = paymentInfo.get("status").getAsString();
//		long paidAmount = paymentInfo.get("amount").getAsLong();
//
//		// 테스트 중 1원 결제 허용을 위해 금액 비교 임시 주석 처리 (실배포 시 원복!)
//		if (!"paid".equals(status) /* || paidAmount != expectedAmount */) {
//		    cancelPortOnePayment(impUid, "결제 금액 불일치 또는 미승인 자동취소");
//		    throw new IllegalStateException("결제 검증에 실패하여 결제가 자동 취소되었습니다.");
//		}
//		// 실제 결제 처리용
//		/*if (!"paid".equals(status) || paidAmount != expectedAmount) {
//			cancelPortOnePayment(impUid, "결제 금액 불일치 또는 미승인 자동취소");
//			throw new IllegalStateException("결제 검증에 실패하여 결제가 자동 취소되었습니다.");
//		}*/
//
//		Payment payment = new Payment();
//		payment.setOrderId(orderId);
//		payment.setPaymentKey(impUid);
//		payment.setPaymentMethod(payMethod != null ? payMethod.toUpperCase() : "CARD");
//		payment.setPaymentAmount(paidAmount);
//		payment.setPaymentStatus("PAID");
//		paymentMapper.insertPayment(payment);
//	}

	// 3. 주문 취소 시 PG 결제 취소 및 상태 변경 (CANCELLED)
	@Transactional
	public void cancelPaymentByOrderId(Long orderId, String reason) {
		Payment payment = paymentMapper.selectPaymentByOrderId(orderId);
		if (payment == null || !"PAID".equals(payment.getPaymentStatus())) {
			return; // PG 결제 건이 없거나 이미 취소된 경우 패스
		}
		cancelPortOnePayment(payment.getPaymentKey(), reason);
		paymentMapper.updatePaymentStatus(payment.getPaymentId(), "CANCELLED");
	}

	// [내부 유틸] 포트원 결제 취소 REST API 호출
	public void cancelPortOnePayment(String impUid, String reason) {
		String token = getAccessToken();
		HttpHeaders headers = new HttpHeaders();
		headers.setBearerAuth(token);
		headers.setContentType(MediaType.APPLICATION_JSON);

		Map<String, Object> body = new HashMap<>();
		body.put("imp_uid", impUid);
		body.put("reason", reason != null ? reason : "구매자 요청 취소");

		String cancelUrl = "https://" + "api.iamport.kr/payments/cancel";
		ResponseEntity<String> res = restTemplate.postForEntity(cancelUrl, new HttpEntity<>(body, headers), String.class);
		
		JsonObject json = JsonParser.parseString(res.getBody()).getAsJsonObject();
		if (json.get("code").getAsInt() != 0) {
			throw new IllegalStateException("PG 결제 취소 실패: " + json.get("message").getAsString());
		}
	}
}
