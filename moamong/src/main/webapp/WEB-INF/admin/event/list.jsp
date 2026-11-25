<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true" %>
	<% String ctx=request.getContextPath(); %>
		<!DOCTYPE html>
		<html lang="ko">

		<head>
			<meta charset="UTF-8">
			<meta name="viewport" content="width=device-width, initial-scale=1.0">
			<title>이벤트 관리</title>

			<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
			<link rel="stylesheet" href="<%=ctx%>/css/admin/event/list.css">
		</head>

		<body>

			<div class="event-wrap">

				<div class="event-header">
					<h2>이벤트 관리</h2>
					<button class="event-btn" onclick="location.href='<%=ctx%>/admin/event/write.do'">
						이벤트 등록
					</button>
				</div>

				<div class="event-filter">
					<button class="active" data-status="">전체</button>
					<button data-status="ONGOING">진행중</button>
					<button data-status="READY">예정</button>
					<button data-status="ENDED">종료</button>
					<button data-status="HIDDEN">숨김</button>
				</div>

				<table class="event-table">
					<thead>
						<tr>
							<th>번호</th>
							<th>썸네일</th>
							<th>이벤트명</th>
							<th>시작일</th>
							<th>종료일</th>
							<th>상태</th>
							<th>관리</th>
						</tr>
					</thead>

					<tbody id="eventList">
						<tr>
							<td colspan="7">조회 중...</td>
						</tr>
					</tbody>
				</table>

				<div class="event-pagination" id="pagination"></div>

			</div>

			<script>
				const ctx = '<%=ctx%>';

				let currentPage = 1;
				let currentStatus = '';

				$(function () {

					loadEventList();

					$('.event-filter button').on('click', function () {

						$('.event-filter button').removeClass('active');
						$(this).addClass('active');

						currentStatus = $(this).data('status');
						currentPage = 1;

						loadEventList();
					});

				});

				function loadEventList() {

					$.ajax({

						url: ctx + '/event/list.dox',
						type: 'POST',

						data: {
							status: currentStatus,
							page: currentPage
						},

						success: function (data) {

							if (typeof data === 'string') {
								data = JSON.parse(data);
							}

							if (data.result !== 'success') {
								$('#eventList').html(
									'<tr><td colspan="7">목록 조회 실패</td></tr>'
								);
								return;
							}

							let html = '';

							if (!data.list || data.list.length === 0) {

								html = '<tr><td colspan="7">등록된 이벤트가 없습니다.</td></tr>';

							} else {

								data.list.forEach(function (item) {

									let thumbnailHtml = '-';

									if (item.thumbnailUrl) {
										thumbnailHtml =
											'<img class="event-thumb" src="' +
											escapeHtml(item.thumbnailUrl) + '">';
									}

									html += `
                                <tr>
                                    <td>${item.eventId}</td>
                                    <td>${thumbnailHtml}</td>
                                    <td>${escapeHtml(item.eventTitle)}</td>
                                    <td>${formatDate(item.startedAt)}</td>
                                    <td>${formatDate(item.endedAt)}</td>
                                    <td>${getStatusName(item.eventStatus)}</td>
                                    <td>
                                        <button class="event-btn"
                                            onclick="goView(${item.eventId})">
                                            상세
                                        </button>
                                    </td>
                                </tr>
                            `;

								});

							}

							$('#eventList').html(html);
							drawPagination(data.cnt);

						},

						error: function () {

							$('#eventList').html(
								'<tr><td colspan="7">서버 오류가 발생했습니다.</td></tr>'
							);

						}

					});

				}

				function drawPagination(totalCount) {

					const pageSize = 6;
					const totalPage = Math.ceil(totalCount / pageSize);

					let html = '';

					for (let i = 1; i <= totalPage; i++) {

						html += `
                    <button class="${i === currentPage ? 'active' : ''}"
                        onclick="changePage(${i})">
                        ${i}
                    </button>
                `;

					}

					$('#pagination').html(html);

				}

				function changePage(page) {

					currentPage = page;
					loadEventList();

				}

				function goView(eventId) {

					location.href = ctx + '/admin/event/view.do?eventId=' + eventId;

				}

				function getStatusName(status) {

					const names = {
						READY: '예정',
						ONGOING: '진행중',
						ENDED: '종료',
						HIDDEN: '숨김'
					};

					return names[status] || status;

				}

				function formatDate(date) {

					if (!date) return '-';

					return String(date).replace('T', ' ').substring(0, 16);

				}

				function escapeHtml(value) {

					return String(value ?? '').replace(/[&<>"']/g, function (ch) {

						return {
							'&': '&amp;',
							'<': '&lt;',
							'>': '&gt;',
							'"': '&quot;',
							"'": '&#39;'
						}[ch];

					});

				}

			</script>

		</body>

		</html>