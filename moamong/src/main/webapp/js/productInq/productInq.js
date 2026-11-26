// 상품 및 패키지 문의 공통 기능
window.inquiryMixin = {

    // 문의 데이터
    data() {
        return {
            inquiryList: [],
            inquiryTotalCount: 0,
            inquiryAnsweredCount: 0,
            inquiryWaitingCount: 0,

            selectedInqStatus: "ALL",

            inquiryPage: 1,
            inquiryLimit: 5,
            inquiryMaxPage: 0,

            showInqWrite: false,

            inqContent: "",
            isSecret: "N",

            showInqAnswer: false,
            answerInqId: "",
            answerContent: "",

            showInqEdit: false,
            editInqId: "",
            editInqContent: "",
            editIsSecret: "N",

            showInqAnswerEdit: false,
            editAnswerInqId: "",
            editAnswerContent: ""
        };
    },

    methods: {

        // 문의 탭 클릭
        fnInqTab: function () {
            this.activeTab = "inquiry";
            this.fnInqList(1);
        },

        // 문의 목록 조회
        fnInqList: function (page) {
            let self = this;

            let param = {
                page: page,
                inqStatus: self.selectedInqStatus
            };

            if (self.productId) {
                param.productId = self.productId;
            } else if (self.packageId) {
                param.packageId = self.packageId;
            }

            $.ajax({
                url: window.contextPath + "/productInq/list.dox",
                dataType: "json",
                type: "POST",
                data: param,
                success: function (data) {

                    self.inquiryList = data.inquiryList || [];
                    self.inquiryTotalCount = data.totalCount || 0;
                    self.inquiryAnsweredCount = data.answeredCount || 0;
                    self.inquiryWaitingCount = data.waitingCount || 0;

                    self.inquiryPage = page;
                    self.inquiryMaxPage = Math.ceil(
                        (data.filteredCount || 0) / self.inquiryLimit
                    );

                },
                error: function (xhr) {
                    console.log(xhr.responseText);
                    alert("문의 목록을 불러오지 못했습니다.");
                }
            });
        },
        // 문의 상태 필터 변경
        fnInqStatus: function (status) {
            if (this.selectedInqStatus === status) {
                return;
            }

            this.selectedInqStatus = status;
            this.fnInqList(1);
        },

        // 문의 페이지 변경
        fnInqPage: function (page) {
            if (page < 1 || page > this.inquiryMaxPage) {
                return;
            }

            this.fnInqList(page);
        },

        // 상품 문의 등록
        fnInqAdd: function () {
            let self = this;

            if (!self.inqContent.trim()) {
                alert("문의 내용을 입력해 주세요.");
                return;
            }

            let param = {
                inqContent: self.inqContent,
                isSecret: self.isSecret
            };

            if (self.productId) {
                param.productId = self.productId;
            } else if (self.packageId) {
                param.packageId = self.packageId;
            }

            $.ajax({
                url: window.contextPath + "/productInq/add.dox",
                dataType: "json",
                type: "POST",
                data: param,
                success: function (data) {

                    if (data.result === "success") {
                        alert("문의가 등록되었습니다.");

                        self.inqContent = "";
                        self.isSecret = "N";
                        self.showInqWrite = false;

                        self.selectedInqStatus = "ALL";
                        self.fnInqList(1);

                    } else {
                        alert("문의 등록에 실패했습니다.");
                    }
                },
                error: function (xhr) {
                    console.log(xhr.responseText);
                    alert("문의 등록 중 오류가 발생했습니다.");
                }
            });
        },
        // 문의 작성 창 열기
        fnInqWrite: function () {

            if (this.isLogin !== "true") {
                alert("로그인 후 문의를 작성할 수 있습니다.");
                return;
            }

            this.showInqWrite = true;
        },
        // 문의 작성 창 닫기
        fnInqWriteClose: function () {
            this.showInqWrite = false;
            this.inqContent = "";
            this.isSecret = "N";
        },

        // 문의 답변 작성창 열기
        fnInqAnswerWrite: function (inquiry) {
            this.answerInqId = inquiry.inqId;
            this.answerContent = "";
            this.showInqAnswer = true;
        },

        // 상품 문의 답변 등록
        fnInqAnswerAdd: function () {
            let self = this;

            if (!self.answerContent.trim()) {
                alert("답변 내용을 입력해 주세요.");
                return;
            }

            let param = {
                inqId: self.answerInqId,
                answerContent: self.answerContent
            };

            $.ajax({
                url: window.contextPath + "/productInq/answer.dox",
                dataType: "json",
                type: "POST",
                data: param,
                success: function (data) {
                    if (data.result === "success") {
                        alert("답변이 등록되었습니다.");
                        self.showInqAnswer = false;
                        self.answerContent = "";
                        self.answerInqId = "";
                        self.fnInqList(self.inquiryPage);
                    } else {
                        alert(data.message || "답변 등록에 실패했습니다.");
                    }
                },
                error: function (xhr) {
                    console.log(xhr.responseText);
                    alert("답변 등록 중 오류가 발생했습니다.");
                }
            });
        },

        // 문의 수정창 열기
        fnInqEdit: function (inquiry) {
            this.editInqId = inquiry.inqId;
            this.editInqContent = inquiry.inqContent;
            this.editIsSecret = inquiry.isSecret;
            this.showInqEdit = true;
        },

        // 상품 문의 수정
        fnInqEditSave: function () {
            let self = this;

            if (!self.editInqContent.trim()) {
                alert("문의 내용을 입력해 주세요.");
                return;
            }

            let param = {
                inqId: self.editInqId,
                inqContent: self.editInqContent,
                isSecret: self.editIsSecret
            };

            $.ajax({
                url: window.contextPath + "/productInq/edit.dox",
                dataType: "json",
                type: "POST",
                data: param,
                success: function (data) {
                    if (data.result === "success") {
                        alert("문의가 수정되었습니다.");
                        self.showInqEdit = false;
                        self.editInqId = "";
                        self.editInqContent = "";
                        self.editIsSecret = "N";
                        self.fnInqList(self.inquiryPage);
                    } else {
                        alert(data.message || "문의 수정에 실패했습니다.");
                    }
                },
                error: function (xhr) {
                    console.log(xhr.responseText);
                    alert("문의 수정 중 오류가 발생했습니다.");
                }
            });
        },

        // 상품 문의 삭제
        fnInqDelete: function (inqId) {
            let self = this;

            if (!confirm("문의를 삭제하시겠습니까?")) {
                return;
            }

            $.ajax({
                url: window.contextPath + "/productInq/remove.dox",
                dataType: "json",
                type: "POST",
                data: {
                    inqId: inqId
                },
                success: function (data) {
                    if (data.result === "success") {
                        alert("문의가 삭제되었습니다.");
                        self.fnInqList(self.inquiryPage);
                    } else {
                        alert(data.message || "문의 삭제에 실패했습니다.");
                    }
                },
                error: function (xhr) {
                    console.log(xhr.responseText);
                    alert("문의 삭제 중 오류가 발생했습니다.");
                }
            });
        },

        // 관리자 답변 수정창 열기
        fnInqAnswerEdit: function (inquiry) {
            this.editAnswerInqId = inquiry.inqId;
            this.editAnswerContent = inquiry.answerContent;
            this.showInqAnswerEdit = true;
        },

        // 상품 문의 답변 수정
        fnInqAnswerEditSave: function () {
            let self = this;

            if (!self.editAnswerContent.trim()) {
                alert("답변 내용을 입력해 주세요.");
                return;
            }

            let param = {
                inqId: self.editAnswerInqId,
                answerContent: self.editAnswerContent
            };

            $.ajax({
                url: window.contextPath + "/productInq/answerEdit.dox",
                dataType: "json",
                type: "POST",
                data: param,
                success: function (data) {
                    if (data.result === "success") {
                        alert("답변이 수정되었습니다.");
                        self.showInqAnswerEdit = false;
                        self.editAnswerInqId = "";
                        self.editAnswerContent = "";
                        self.fnInqList(self.inquiryPage);
                    } else {
                        alert(data.message || "답변 수정에 실패했습니다.");
                    }
                },
                error: function (xhr) {
                    console.log(xhr.responseText);
                    alert("답변 수정 중 오류가 발생했습니다.");
                }
            });
        },

        // 관리자 답변 삭제
        fnInqAnswerDelete: function (inqId) {
            let self = this;

            if (!confirm("관리자 답변을 삭제하시겠습니까?")) {
                return;
            }

            $.ajax({
                url: window.contextPath + "/productInq/answerRemove.dox",
                dataType: "json",
                type: "POST",
                data: {
                    inqId: inqId
                },
                success: function (data) {
                    if (data.result === "success") {
                        alert("답변이 삭제되었습니다.");
                        self.fnInqList(self.inquiryPage);
                    } else {
                        alert(data.message || "답변 삭제에 실패했습니다.");
                    }
                },
                error: function (xhr) {
                    console.log(xhr.responseText);
                    alert("답변 삭제 중 오류가 발생했습니다.");
                }
            });
        },
    }

};