
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>포인트 히스토리</title>

    <!-- jQuery를 사용하기 위한 라이브러리입니다. -->
    <script src="https://code.jquery.com/jquery-3.7.1.js"
        integrity="sha256-eKhayi8LEQwp4NKxN+CfCh+3qOVUtJn3QNZ0TciWLP4="
        crossorigin="anonymous"></script>

    <!-- Vue 3를 사용하기 위한 라이브러리입니다. -->
    <script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>

    <!-- 프로젝트에서 사용하는 공통 JS 파일입니다. -->
    <script src="/js/page-change.js"></script>
	<link rel="stylesheet" href="/css/point/list.css">
    
</head>

<body>

    <!-- Vue가 화면을 관리하는 영역입니다. -->
    <div id="app">

        <h2>🅿️ 포인트 사용내역</h2>

        <p>회원님의 포인트 적립 및 사용 내역을 확인할 수 있습니다.</p>

        <!-- 포인트 내역 테이블입니다. -->
        <table>

            <!-- 테이블의 제목 부분입니다. -->
            <thead>
                <tr>
                    <th>번호</th>
                    <th>발생 일시</th>
                    <th>유형</th>
                    <th>상세 내용</th>
                    <th>주문 번호</th>
                    <th>변동 포인트</th>
                    <th>변동 후 잔액</th>
                </tr>
            </thead>

            <!-- 실제 포인트 내역이 출력되는 부분입니다. -->
            <tbody>

                <!--
                    list 배열에 저장된 포인트 내역을 한 건씩 꺼냅니다.
                    포인트 내역의 개수만큼 tr 태그가 반복 생성됩니다.
                -->
                <tr v-for="(item, index) in list" :key="item.pointHistoryId">

                    <!-- 화면에 표시할 순번입니다. -->
                    <td>{{ index + 1 }}</td>

                    <!-- 포인트가 발생한 날짜와 시간입니다. -->
                    <td>{{ item.createdAt }}</td>

                    <!-- 포인트 변동 유형을 한글로 표시합니다. -->
                    <td>
                        <span class="type"
                              :class="item.historyType.toLowerCase()">
                            {{ fnTypeName(item.historyType) }}
                        </span>
                    </td>

                    <!-- 포인트가 변경된 이유를 표시합니다. -->
                    <td>
                        {{ item.description || '-' }}
                    </td>

                    <!-- 관련 주문 번호를 표시합니다. -->
                    <!-- 주문과 관계없는 내역이라면 - 를 표시합니다. -->
                    <td>
                        {{ item.orderId || '-' }}
                    </td>

                    <!-- 이번에 변동된 포인트 양입니다. -->
                    <td class="point">
                        {{ Number(item.pointAmount).toLocaleString() }} P
                    </td>

                    <!-- 포인트 변동 후 남은 잔액입니다. -->
                    <td class="point">
                        {{ Number(item.balanceAfter).toLocaleString() }} P
                    </td>

                </tr>

                <!-- 조회된 포인트 내역이 없으면 이 문구를 표시합니다. -->
                <tr v-if="list.length == 0">
                    <td colspan="7" class="empty">
                        포인트 내역이 없습니다.
                    </td>
                </tr>

            </tbody>

        </table>

    </div>

</body>
</html>


<script>

    // Vue 3 애플리케이션을 생성합니다.
    const app = Vue.createApp({

        // 화면에서 사용할 데이터를 선언하는 곳입니다.
        data() {
            return {

                // 서버에서 받아온 포인트 내역을 저장할 배열입니다.
                list: [],
				memberId : "${memberId}"
				
            };
        },


        // 화면에서 사용할 함수들을 작성하는 곳입니다.
        methods: {

            // 포인트 유형을 영어에서 한글로 변경하는 함수입니다.
            fnTypeName: function(type) {

                // EARN이면 포인트 적립이라고 표시합니다.
                if (type == "EARN") {
                    return "적립";
                }

                // USE이면 포인트 사용이라고 표시합니다.
                if (type == "USE") {
                    return "사용";
                }

                // CANCEL이면 포인트 취소라고 표시합니다.
                if (type == "CANCEL") {
                    return "취소";
                }

                // EXPIRE이면 포인트 만료라고 표시합니다.
                if (type == "EXPIRE") {
                    return "만료";
                }

                // ADJUST이면 관리자 포인트 조정이라고 표시합니다.
                if (type == "ADJUST") {
                    return "관리자 조정";
                }

                // 위 유형에 해당하지 않으면 원래 값을 반환합니다.
                return type;

            },


            // 서버에 요청하여 포인트 내역을 가져오는 함수입니다.
            fnList: function() {

                // Vue 내부의 데이터를 사용하기 위해 this를 self에 저장합니다.
                let self = this;

                // 서버로 전달할 검색 조건을 담는 객체입니다.
                // 현재는 전체 내역을 조회하므로 별도의 조건은 없습니다.
                let param = {
					memberId : self.memberId
				};

                // jQuery AJAX를 사용하여 서버에 요청합니다.
				$.ajax({

				    url: "/point/history.dox",

				    dataType: "json",

				    type: "POST",

				    // 수정된 부분
				    data: param,

				    success: function(data) {
						
										
				        if (data.result == "success") {
							
				            self.list = data.list;

				        } else {

				            alert(data.message || "포인트 내역 조회에 실패했습니다.");

				        }

				    },

				    error: function(xhr, status, error) {

				        alert("서버와 통신하는 중 오류가 발생했습니다.");

				        console.log(error);

				    }

				});

            }

        },


        // Vue 화면이 처음 만들어질 때 자동으로 실행되는 부분입니다.
        mounted() {

            // 화면이 열리자마자 포인트 내역을 조회합니다.
            this.fnList();
			
        }

    });


    // 위에서 생성한 Vue를 id가 app인 HTML 영역에 연결합니다.
    app.mount('#app');

</script>
