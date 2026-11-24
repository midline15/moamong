<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<style>
    #moamong-chatbot-widget { position: fixed; right: 24px; bottom: 24px; z-index: 9999; font-family: sans-serif; }
    .mcb-fab { width: 58px; height: 58px; border-radius: 50%; background: #222; color: #fff; border: none; font-size: 24px; cursor: pointer; box-shadow: 0 4px 14px rgba(0,0,0,0.22); }
    .mcb-panel { position: absolute; right: 0; bottom: 72px; width: 350px; background: #fff; border-radius: 14px; box-shadow: 0 8px 28px rgba(0,0,0,0.18); overflow: hidden; border: 1px solid #eee; }
    .mcb-head { background: #222; color: #fff; padding: 13px 16px; display: flex; justify-content: space-between; align-items: center; font-size: 14px; font-weight: bold; }
    .mcb-head-btns button { background: #444; color: #fff; border: none; padding: 4px 8px; border-radius: 5px; font-size: 11px; cursor: pointer; margin-left: 4px; }
    .mcb-body { height: 370px; overflow-y: auto; padding: 14px; display: flex; flex-direction: column; gap: 9px; background: #fafafa; }
    .mcb-msg { max-width: 78%; padding: 9px 13px; border-radius: 12px; font-size: 13px; line-height: 1.45; white-space: pre-wrap; word-break: break-word; }
    .mcb-msg.USER { align-self: flex-end; background: #ff6b6b; color: #fff; }
    .mcb-msg.BOT { align-self: flex-start; background: #e9ecef; color: #222; }
    .mcb-foot { display: flex; border-top: 1px solid #eee; background: #fff; }
    .mcb-foot input { flex: 1; border: none; padding: 12px; font-size: 13px; outline: none; }
    .mcb-foot button { background: #222; color: #fff; border: none; padding: 0 16px; font-size: 13px; cursor: pointer; }
</style>

<div id="moamong-chatbot-widget">
    <div v-if="isOpen" class="mcb-panel">
        <div class="mcb-head">
            <span>🤖 모아몽 AI 상담원</span>
            <div class="mcb-head-btns">
                <button type="button" @click="endChat">초기화</button>
                <button type="button" @click="isOpen = false">✕</button>
            </div>
        </div>
        <div class="mcb-body" ref="chatBox">
            <div v-if="messages.length === 0" class="mcb-msg BOT">안녕하세요! 선물 추천이나 배송비 등 궁금한 점을 물어보세요.</div>
            <div v-for="(m, idx) in messages" :key="idx" :class="['mcb-msg', m.sender_type]">{{ m.message_content }}</div>
            <div v-if="loading" class="mcb-msg BOT">답변 작성 중...</div>
        </div>
        <div class="mcb-foot">
            <input type="text" v-model="inputMsg" @keyup.enter="sendMsg" placeholder="메시지 입력..." :disabled="loading">
            <button type="button" @click="sendMsg" :disabled="loading">전송</button>
        </div>
    </div>
    <button type="button" class="mcb-fab" @click="toggleChat">{{ isOpen ? '✕' : '💬' }}</button>
</div>
<script>
    (function() {
        function initChatbotWidget() {
            Vue.createApp({
                data: function() {
                    return { isOpen: false, loaded: false, messages: [], inputMsg: "", loading: false };
                },
                methods: {
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
