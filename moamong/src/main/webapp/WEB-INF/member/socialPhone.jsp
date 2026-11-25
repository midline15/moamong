<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>모아몽 - 휴대폰 본인인증</title>
    <script src="https://code.jquery.com/jquery-3.7.1.js" integrity="sha256-eKhayi8LEQwp4NKxN+CfCh+3qOVUtJn3QNZ0TciWLP4=" crossorigin="anonymous"></script>
    <script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
    <script src="/js/page-change.js"></script>
    <script src="https://cdn.iamport.kr/v1/iamport.js"></script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/footer.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/member/auth.css">
</head>
<body>
    <%@ include file="/WEB-INF/common/header.jsp"%>

    <main id="app" class="auth-wrap">
        <div class="auth-card">
            <span class="auth-eyebrow">ADDITIONAL VERIFICATION</span>
            <h2 class="auth-title">휴대폰 본인인증</h2>
            <p style="font-size:13px; color:#5c5346; text-align:center; line-height:1.6; margin-bottom:22px;">
                안전한 주문·배송 안내 및 서비스 이용을 위해<br>최초 1회 휴대폰 본인인증이 필요합니다.
            </p>

            <div class="auth-group">
                <label class="auth-label">휴대폰 번호 *</label>
                <div class="auth-input-row">
                    <input class="auth-input" v-model="phone" placeholder="본인인증을 진행해주세요" readonly style="background:#f0e8da;">
                    <button type="button" class="auth-btn auth-btn-gold auth-btn-sm" @click="fnCertPhone">본인인증</button>
                </div>
                <div v-if="isPhoneVerified" style="font-size:12px; color:#2b8a3e; margin-top:5px;">✓ 본인인증 완료</div>
            </div>

            <button class="auth-btn auth-btn-gold" @click="fnSave" style="margin-top:12px;">인증 완료 및 시작하기</button>
        </div>
    </main>

    <%@ include file="/WEB-INF/common/footer.jsp"%>
</body>
</html>
<script>
    const app = Vue.createApp({
        data() { return { phone: "", isPhoneVerified: false }; },
        methods: {
            fnCertPhone() {
                let self = this;
                const IMP = window.IMP;
                IMP.init("${impCode}");
                IMP.certification({
                    pg: "inicis_unified.MIIiasTest",
                    merchant_uid: "CERT_" + new Date().getTime(),
                    popup: true
                }, function (rsp) {
                    if (rsp.success) {
                        const verifiedPhone = rsp.phone || prompt("본인인증이 완료되었습니다. 등록할 휴대폰 번호(010-0000-0000)를 확인해주세요:", "010-");
                        if (!verifiedPhone || !/^01[0-9]-?[0-9]{3,4}-?[0-9]{4}$/.test(verifiedPhone.trim())) {
                            alert("올바른 휴대폰 번호 형식이 아닙니다.");
                            return;
                        }
                        self.phone = verifiedPhone.trim();
                        self.isPhoneVerified = true;
                    } else {
                        alert("본인인증에 실패했습니다.\n(" + (rsp.error_msg || "") + ")");
                    }
                });
            },
            fnSave() {
                if (!this.isPhoneVerified || !this.phone) { alert("휴대폰 본인인증을 먼저 완료해주세요."); return; }
                $.post("/member/save-social-phone.dox", { phone: this.phone }, function (data) {
                    alert(data.message);
                    if (data.result === "success") location.href = "/";
                }, "json");
            }
        }
    });
    app.mount("#app");
</script>
