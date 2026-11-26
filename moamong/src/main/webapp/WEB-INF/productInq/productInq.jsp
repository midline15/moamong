<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/productInq/productInq.css">
<div class="inquiry-section" v-show="activeTab === 'inquiry'">

                                <!-- 문의 제목 -->
                                <div class="inquiry-heading">
                                    <div>
                                        <strong>상품 문의</strong>
                                        <span>{{ inquiryTotalCount }}</span>
                                    </div>

                                    <button type="button" class="inquiry-write-btn" @click="fnInqWrite">
                                        문의 작성
                                    </button>
                                </div>

                                <!-- 문의 상태 필터 -->
                                <div class="inquiry-filter">

                                    <button type="button" :class="{ active: selectedInqStatus === 'ALL' }"
                                        @click="fnInqStatus('ALL')">
                                        전체 ({{ inquiryTotalCount }})
                                    </button>

                                    <button type="button" :class="{ active: selectedInqStatus === 'ANSWERED' }"
                                        @click="fnInqStatus('ANSWERED')">
                                        답변완료 ({{ inquiryAnsweredCount }})
                                    </button>

                                    <button type="button" :class="{ active: selectedInqStatus === 'WAITING' }"
                                        @click="fnInqStatus('WAITING')">
                                        미답변 ({{ inquiryWaitingCount }})
                                    </button>

                                </div>

                                <!-- 문의가 없는 경우 -->
                                <div class="empty-message" v-if="inquiryList.length === 0">
                                    등록된 문의가 없습니다.
                                </div>

                                <template v-else>

                                    <!-- 문의 목록 -->
                                    <div class="inquiry-list">

                                        <div class="inquiry-item" v-for="inquiry in inquiryList" :key="inquiry.inqId">

                                            <!-- 문의 작성자 및 상태 -->
                                            <div class="inquiry-info">
                                                <span class="inquiry-status"
                                                    :class="inquiry.inqStatus === 'ANSWERED' ? 'answered' : 'waiting'">
                                                    {{ inquiry.inqStatus === 'ANSWERED' ? '답변완료' : '미답변' }}
                                                </span>

                                                <span class="inquiry-member">
                                                    {{ inquiry.memberName }}
                                                </span>

                                                <span class="inquiry-date">
                                                    {{ inquiry.createdAt ? inquiry.createdAt.substring(0, 10) : '' }}
                                                </span>
                                            </div>

                                            <!-- 문의 상품 및 제목 -->
                                            <div class="inquiry-content">
                                                <span class="inquiry-product-name">
                                                    {{ inquiry.productName }}
                                                </span>

                                                <div class="inquiry-text">
                                                    <span class="inquiry-secret" v-if="inquiry.isSecret === 'Y'">
                                                        비밀 문의
                                                    </span>

                                                    <strong>{{ inquiry.inqContent }}</strong>
                                                </div>
                                            </div>

                                            <!-- 문의 수정 및 삭제 버튼 -->
                                            <div class="inquiry-manage-btn"
                                                v-if="!isAdmin && inquiry.memberId == '${sessionScope.sessionId}'">

                                                <!-- 미답변 문의만 수정 가능 -->
                                                <button type="button" v-if="inquiry.inqStatus === 'WAITING'"
                                                    @click="fnInqEdit(inquiry)">
                                                    수정
                                                </button>

                                                <!-- 답변 상태와 관계없이 본인 문의 삭제 가능 -->
                                                <button type="button" @click="fnInqDelete(inquiry.inqId)">
                                                    삭제
                                                </button>
                                            </div>

                                            <!-- 관리자 답변 작성 버튼 -->
                                            <button type="button" class="inquiry-answer-write-btn"
                                                v-if="isAdmin && inquiry.inqStatus === 'WAITING'"
                                                @click="fnInqAnswerWrite(inquiry)">
                                                답변 작성
                                            </button>

                                            <!-- 답변 펼쳐보기 -->
                                            <!-- 관리자 답변 -->
                                            <div class="inquiry-answer"
                                                v-if="inquiry.inqStatus === 'ANSWERED' && inquiry.answerContent">

                                                <button type="button" @click="inquiry.showAnswer = !inquiry.showAnswer">
                                                    {{ inquiry.showAnswer ? '답변 접기' : '답변 펼쳐보기' }}
                                                </button>

                                                <div class="inquiry-answer-content" v-if="inquiry.showAnswer">
                                                    <strong>관리자 답변</strong>
                                                    <p>{{ inquiry.answerContent }}</p>

                                                    <!-- 관리자 답변 수정 및 삭제 -->
                                                    <div class="inquiry-manage-btn" v-if="isAdmin">
                                                        <button type="button" @click="fnInqAnswerEdit(inquiry)">
                                                            수정
                                                        </button>
                                                        <button type="button" @click="fnInqAnswerDelete(inquiry.inqId)">
                                                            삭제
                                                        </button>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- 관리자 답변 작성 모달 -->
                                            <div class="inquiry-write-modal" v-if="showInqAnswer">
                                                <div class="inquiry-write-content">
                                                    <h3>상품 문의 답변 작성</h3>

                                                    <button type="button" class="inquiry-close-btn"
                                                        @click="showInqAnswer = false">
                                                        닫기
                                                    </button>

                                                    <div class="inquiry-form">
                                                        <label for="answerContent">답변 내용</label>

                                                        <textarea id="answerContent" v-model="answerContent"
                                                            placeholder="문의에 대한 답변을 입력해 주세요." rows="5"></textarea>

                                                        <button type="button" class="inquiry-submit-btn"
                                                            @click="fnInqAnswerAdd">
                                                            답변 등록
                                                        </button>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- 관리자 답변 수정 모달 -->
                                            <div class="inquiry-write-modal" v-if="showInqAnswerEdit">
                                                <div class="inquiry-write-content">
                                                    <button type="button" class="inquiry-close-btn"
                                                        @click="showInqAnswerEdit = false">
                                                        ×
                                                    </button>

                                                    <h3>답변 수정</h3>

                                                    <div class="inquiry-form">
                                                        <textarea v-model="editAnswerContent"
                                                            placeholder="답변 내용을 입력해 주세요.">
                                                    </textarea>
                                                    </div>

                                                    <button type="button" class="inquiry-submit-btn"
                                                        @click="fnInqAnswerEditSave">
                                                        수정하기
                                                    </button>
                                                </div>
                                            </div>

                                        </div>

                                    </div>

                                    <!-- 페이지네이션 -->
                                    <div class="inquiry-pagination" v-if="inquiryMaxPage > 1">

                                        <button type="button" @click="fnInqPage(inquiryPage - 1)"
                                            :disabled="inquiryPage === 1">
                                            이전
                                        </button>

                                        <button type="button" v-for="n in inquiryMaxPage" :key="n"
                                            :class="{ active: inquiryPage === n }" @click="fnInqPage(n)">
                                            {{ n }}
                                        </button>

                                        <button type="button" @click="fnInqPage(inquiryPage + 1)"
                                            :disabled="inquiryPage === inquiryMaxPage">
                                            다음
                                        </button>

                                    </div>

                                </template>

                                <!-- 문의 작성 창 -->
                                <div class="inquiry-write-modal" v-if="showInqWrite">
                                    <div class="inquiry-write-content">

                                        <h3>상품 문의 작성</h3>

                                        <button type="button" class="inquiry-close-btn" @click="fnInqWriteClose">
                                            닫기
                                        </button>

                                        <!-- 문의 내용 -->
                                        <div class="inquiry-form">
                                            <label for="inqContent">문의 내용</label>

                                            <textarea id="inqContent" v-model="inqContent"
                                                placeholder="상품에 대한 문의 내용을 입력해 주세요." rows="5">
                                        </textarea>

                                            <!-- 비밀 문의 -->
                                            <label class="inquiry-secret-check">
                                                <input type="checkbox" :checked="isSecret === 'Y'"
                                                    @change="isSecret = $event.target.checked ? 'Y' : 'N'">
                                                비밀 문의로 작성
                                            </label>

                                            <!-- 등록 버튼 -->
                                            <button type="button" class="inquiry-submit-btn" @click="fnInqAdd">
                                                문의 등록
                                            </button>
                                        </div>
                                    </div>
                                </div>

                                <!-- 문의 수정 모달 -->
                                <div class="inquiry-write-modal" v-if="showInqEdit">
                                    <div class="inquiry-write-content">
                                        <h3>상품 문의 수정</h3>

                                        <button type="button" class="inquiry-close-btn" @click="showInqEdit = false">
                                            닫기
                                        </button>

                                        <div class="inquiry-form">
                                            <label for="editInqContent">문의 내용</label>

                                            <textarea id="editInqContent" v-model="editInqContent"
                                                placeholder="문의 내용을 입력해 주세요." rows="5"></textarea>

                                            <label class="inquiry-secret-check">
                                                <input type="checkbox" :checked="editIsSecret === 'Y'"
                                                    @change="editIsSecret = $event.target.checked ? 'Y' : 'N'">
                                                비밀 문의로 작성
                                            </label>

                                            <button type="button" class="inquiry-submit-btn" @click="fnInqEditSave">
                                                수정 완료
                                            </button>
                                        </div>
                                    </div>
                                </div>

                            </div>