<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/chatbot/chatbot.css">

<div id="moamong-chatbot-widget">
    <div v-if="isOpen" class="mcb-panel">
        <div class="mcb-head">
            <span>모아몽 AI 컨시어지</span>
            <div class="mcb-head-btns">
                <button type="button" @click="endChat">초기화</button>
                <button type="button" @click="isOpen = false">✕</button>
            </div>
        </div>
        <div class="mcb-body" ref="chatBox" style="white-space: pre-line;">
            <div v-if="messages.length === 0" class="mcb-msg BOT">안녕하세요! 모아몽 AI 컨시어지입니다 😊
                선물 추천이나 배송비, 주문/환불 등 궁금한 점을 아래 버튼으로 바로 물어보시거나 직접 입력해 주세요!</div>

                <!-- 원클릭 추천 질문 칩 -->
                <div v-if="messages.length === 0 && !loading" style="display:flex; flex-wrap:wrap; gap:6px; margin:8px 0 4px;">
                    <button v-for="(q, idx) in quickQuestions" :key="idx" type="button"
                    @click="sendQuickMsg(q)"
                    style="padding:6px 11px; font-size:12px; border-radius:999px; border:1px solid #d8c7ae; background:#fffaf2; color:#765a36; cursor:pointer; font-weight:600;">
                    {{ q }}
                </button>
            </div>

            <div v-for="(m, idx) in messages" :key="idx" :class="['mcb-msg', m.sender_type]">{{ m.message_content }}</div>
            <div v-if="loading" class="mcb-msg BOT">답변을 작성하고 있습니다...</div>
        </div>

        <div class="mcb-foot">
            <input type="text" v-model="inputMsg" @keyup.enter="sendMsg" placeholder="메시지를 입력해주세요..." :disabled="loading">
            <button type="button" @click="sendMsg" :disabled="loading">전송</button>
        </div>
    </div>
    <button type="button" class="mcb-fab" @click="toggleChat" title="모아몽 AI 상담">
        {{ isOpen ? '✕' : '💬' }}
    </button>
</div>

<script>
    (function() {
        function initChatbotWidget() {
            Vue.createApp({
                data: function() {
                    return {
                        isOpen: false,
                        loaded: false,
                        messages: [],
                        quickQuestions: [
                        "🎁 3만원대 생일 선물 추천해줘",
                        "🚚 무료배송 기준이 얼마야?",
                        "💌 선물 포장 및 메시지 카드 안내",
                        "🔄 주문 취소 및 반품 규정 알려줘"
                        ],
                        inputMsg: "",
                        loading: false
                    };
                },
                methods: {
                    sendQuickMsg: function(text) {
                        this.inputMsg = text;
                        this.sendMsg();
                    },
                    toggleChat: function() {
                        this.isOpen = !this.isOpen;
                        if (this.isOpen && !this.loaded) { this.loadHistory(); }
                        else if (this.isOpen) { this.scrollBottom(); }
                    },
                    scrollBottom: function() {
                        var self = this;
                        this.$nextTick(function() {
                            var box = self.$refs.chatBox;
                            if (box) box.scrollTop = box.scrollHeight;
                        });
                    },
                    loadHistory: function() {
                        var self = this;
                        fetch("/chatbot/history.dox", { method: "POST" })
                        .then(function(r) { return r.json(); })
                        .then(function(res) {
                            self.loaded = true;
                            if (res.result === "success") { self.messages = res.list || []; self.scrollBottom(); }
                        });
                    },
                    sendMsg: function() {
                        var text = this.inputMsg.trim();
                        if (!text || this.loading) return;
                        this.messages.push({ sender_type: "USER", message_content: text });
                        this.inputMsg = ""; this.loading = true; this.scrollBottom();
                        var self = this;
                        fetch("/chatbot/send.dox", {
                            method: "POST", headers: { "Content-Type": "application/json" },
                            body: JSON.stringify({ message: text })
                        }).then(function(r) { return r.json(); })
                        .then(function(res) {
                            self.loading = false;
                            var reply = res.result === "success" ? res.reply : (res.message || "오류가 발생했습니다.");
                            self.messages.push({ sender_type: "BOT", message_content: reply });
                            self.scrollBottom();
                        });
                    },
                    endChat: function() {
                        var self = this;
                        fetch("/chatbot/end.dox", { method: "POST" })
                        .then(function(r) { return r.json(); })
                        .then(function() { self.messages = []; });
                    }
                }
            }).mount("#moamong-chatbot-widget");
        }
        if (window.Vue) { initChatbotWidget(); }
        else {
            var s = document.createElement("script");
            s.src = "https://" + "unpkg.com" + "/vue@3/dist/vue.global.js";
            s.onload = initChatbotWidget;
            document.head.appendChild(s);
        }
    })();
</script>
