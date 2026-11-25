<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
	<% String ctx=request.getContextPath(); String eventId=request.getParameter("eventId"); %>
		<!DOCTYPE html>
		<html lang="ko">

		<head>
			<meta charset="UTF-8">
			<meta name="viewport" content="width=device-width, initial-scale=1.0">
			<title>이벤트 상세</title>

			<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
			<script src="https://cdnjs.cloudflare.com/ajax/libs/dompurify/3.2.6/purify.min.js"></script>
			<link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin/event/view.css">
			
		</head>

		<body>

			<div class="event-wrap">
				<h2>이벤트 상세</h2>

				<div class="event-info">
					<h2 id="eventTitle"></h2>
					<div class="event-meta">
						<span id="eventStatus"></span>
						<span> | </span>
						<span id="eventPeriod"></span>
					</div>
				</div>

				<div id="thumbnailArea"></div>
				<div class="event-content" id="eventContent"></div>

				<div class="event-buttons">
					<button class="btn-gray" onclick="goList()">목록</button>
					<div>
						<button class="btn-dark" onclick="goEdit()">수정</button>
						<button class="btn-gray" onclick="deleteEvent()">삭제</button>
					</div>
				</div>
			</div>

			<script>
				const ctx = '<%=ctx%>';
				const eventId = '<%=eventId%>';

				$(function () {
					loadEvent();
				});

				function loadEvent() {
					$.ajax({
						url: ctx + '/event/view.dox',
						type: 'POST',
						data: {eventId: eventId},
						success: function (data) {
							if (typeof data === 'string') data = JSON.parse(data);

							if (data.result !== 'success') {
								alert(data.msg || '이벤트를 찾을 수 없습니다.');
								goList();
								return;
							}

							const info = data.info;

							$('#eventTitle').text(info.eventTitle);
							$('#eventStatus').text(getStatusName(info.eventStatus));
							$('#eventPeriod').text(
								formatDate(info.startedAt) + ' ~ ' + formatDate(info.endedAt)
							);

							const thumbnail = (data.imageList || []).find(
								img => img.imageType === 'THUMBNAIL'
							);

							if (thumbnail) {
								$('#thumbnailArea').html(
									`<img src="${thumbnail.imageUrl}"
                        style="max-width:100%; margin-top:25px;">`
								);
							}

							$('#eventContent').html(
								DOMPurify.sanitize(info.eventContent || '')
							);
						},
						error: function () {
							alert('이벤트 조회 중 오류가 발생했습니다.');
						}
					});
				}

				function goList() {
					location.href = ctx + '/admin/event/list.do';
				}

				function goEdit() {
					location.href = ctx + '/admin/event/write.do?eventId=' + eventId;
				}

				function deleteEvent() {
					if (!confirm('이벤트를 삭제할까?')) return;

					$.ajax({
						url: ctx + '/event/delete.dox',
						type: 'POST',
						data: {eventId: eventId},
						success: function (data) {
							if (typeof data === 'string') data = JSON.parse(data);

							if (data.result === 'success') {
								alert('삭제 완료');
								goList();
							} else {
								alert(data.msg || '삭제 실패');
							}
						},
						error: function () {
							alert('삭제 중 오류가 발생했습니다.');
						}
					});
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
			</script>

		</body>

		</html>