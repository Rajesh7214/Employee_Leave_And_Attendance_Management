<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!-- SmartOffice Glassmorphism Notification Bell & Dropdown Component -->
<style>
.smart-notif-wrapper {
	position: relative;
	display: inline-block;
	font-family: 'Plus Jakarta Sans', 'Segoe UI', sans-serif;
}

.notif-bell-btn {
	position: relative;
	background: #ffffff;
	border: 1px solid #e2e8f0;
	color: #334155;
	width: 42px;
	height: 42px;
	border-radius: 12px;
	cursor: pointer;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 18px;
	transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
	box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
	outline: none;
}

.notif-bell-btn:hover, .notif-bell-btn.active {
	background: #6366f1;
	color: #ffffff !important;
	border-color: #6366f1;
	box-shadow: 0 6px 18px rgba(99, 102, 241, 0.4);
}

.notif-badge {
	position: absolute;
	top: -5px;
	right: -5px;
	background: #ef4444;
	color: #ffffff;
	font-size: 10px;
	font-weight: 800;
	min-width: 18px;
	height: 18px;
	border-radius: 999px;
	display: flex;
	align-items: center;
	justify-content: center;
	padding: 0 4px;
	border: 2px solid #ffffff;
	box-shadow: 0 0 10px rgba(239, 68, 68, 0.8);
	animation: pulseBadge 2s infinite;
}

@keyframes pulseBadge {
	0% { transform: scale(1); }
	50% { transform: scale(1.15); }
	100% { transform: scale(1); }
}

/* Glassmorphism Popover Panel */
.notif-dropdown-panel {
	position: absolute;
	right: 0;
	top: 52px;
	width: 410px;
	max-width: 92vw;
	background: rgba(15, 23, 42, 0.96);
	backdrop-filter: blur(24px);
	-webkit-backdrop-filter: blur(24px);
	border: 1px solid rgba(255, 255, 255, 0.15);
	border-radius: 20px;
	box-shadow: 0 25px 60px rgba(0, 0, 0, 0.55), 0 0 2px rgba(255, 255, 255, 0.2);
	z-index: 99999;
	overflow: hidden;
	display: flex;
	flex-direction: column;
	animation: notifPopIn 0.25s cubic-bezier(0.16, 1, 0.3, 1);
	text-align: left;
}

@keyframes notifPopIn {
	from { opacity: 0; transform: translateY(-12px) scale(0.95); }
	to { opacity: 1; transform: translateY(0) scale(1); }
}

.notif-dropdown-header {
	padding: 16px 20px 12px 20px;
	display: flex;
	justify-content: space-between;
	align-items: center;
	border-bottom: 1px solid rgba(255, 255, 255, 0.08);
	background: rgba(255, 255, 255, 0.02);
}

.notif-dropdown-header h3 {
	margin: 0;
	font-size: 16px;
	font-weight: 700;
	color: #f8fafc;
	display: flex;
	align-items: center;
	gap: 8px;
}

.btn-mark-all-read {
	background: rgba(255, 255, 255, 0.08);
	border: 1px solid rgba(255, 255, 255, 0.15);
	color: #94a3b8;
	padding: 4px 12px;
	border-radius: 12px;
	cursor: pointer;
	font-size: 11.5px;
	font-weight: 600;
	transition: all 0.2s ease;
	display: inline-flex;
	align-items: center;
	gap: 5px;
}

.btn-mark-all-read:hover {
	color: #38bdf8;
	background: rgba(56, 189, 248, 0.15);
	border-color: #38bdf8;
}

/* Filter Tabs */
.notif-filter-tabs {
	display: flex;
	gap: 6px;
	padding: 10px 18px;
	background: rgba(0, 0, 0, 0.25);
	border-bottom: 1px solid rgba(255, 255, 255, 0.06);
	overflow-x: auto;
	scrollbar-width: none;
}
.notif-filter-tabs::-webkit-scrollbar { display: none; }

.notif-tab {
	background: transparent;
	border: 1px solid rgba(255, 255, 255, 0.1);
	color: #94a3b8;
	padding: 4px 10px;
	border-radius: 20px;
	font-size: 11px;
	font-weight: 600;
	cursor: pointer;
	white-space: nowrap;
	transition: all 0.15s ease;
}

.notif-tab:hover {
	color: #ffffff;
	border-color: rgba(255, 255, 255, 0.25);
}

.notif-tab.active {
	background: #38bdf8;
	color: #0f172a;
	border-color: #38bdf8;
	font-weight: 700;
}

.notif-dropdown-list {
	padding: 14px;
	overflow-y: auto;
	max-height: 380px;
	display: flex;
	flex-direction: column;
	gap: 10px;
}

.notif-dropdown-list::-webkit-scrollbar {
	width: 6px;
}
.notif-dropdown-list::-webkit-scrollbar-thumb {
	background: rgba(255, 255, 255, 0.15);
	border-radius: 10px;
}

/* Glassmorphism Notification Card Item */
.notif-card-item {
	background: rgba(255, 255, 255, 0.04);
	border: 1px solid rgba(255, 255, 255, 0.08);
	border-radius: 16px;
	padding: 14px 16px;
	transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
	position: relative;
	cursor: pointer;
}

.notif-card-item:hover {
	background: rgba(255, 255, 255, 0.09);
	border-color: rgba(56, 189, 248, 0.35);
	transform: translateY(-2px);
	box-shadow: 0 6px 20px rgba(0, 0, 0, 0.3);
}

.notif-card-item.unread {
	background: rgba(56, 189, 248, 0.07);
	border-left: 3.5px solid #38bdf8;
	border-color: rgba(56, 189, 248, 0.25);
}

.notif-card-top {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 6px;
}

.notif-pill {
	padding: 3px 10px;
	border-radius: 20px;
	font-size: 11px;
	font-weight: 700;
	color: #ffffff;
	text-transform: capitalize;
	display: inline-flex;
	align-items: center;
	gap: 5px;
}

.pill-meeting { background: #2563eb; }
.pill-task { background: #7c3aed; }
.pill-leave { background: #ea580c; }
.pill-attendance { background: #059669; }
.pill-announcement { background: #0891b2; }
.pill-security { background: #dc2626; }
.pill-payroll { background: #16a34a; }
.pill-default { background: #64748b; }

.notif-time-status {
	display: flex;
	align-items: center;
	gap: 6px;
	font-size: 11.5px;
	color: #94a3b8;
}

.dot-urgent { width: 8px; height: 8px; border-radius: 50%; background: #ef4444; display: inline-block; box-shadow: 0 0 8px #ef4444; animation: pulseDot 1.5s infinite; }
.dot-info { width: 8px; height: 8px; border-radius: 50%; background: #38bdf8; display: inline-block; }

@keyframes pulseDot {
	0%, 100% { opacity: 1; transform: scale(1); }
	50% { opacity: 0.5; transform: scale(1.3); }
}

.notif-card-title {
	font-size: 14px;
	font-weight: 700;
	color: #f8fafc;
	margin-bottom: 4px;
	line-height: 1.35;
}

.notif-card-snippet {
	font-size: 12.5px;
	color: #cbd5e1;
	line-height: 1.45;
	margin-bottom: 10px;
	display: -webkit-box;
	-webkit-line-clamp: 2;
	-webkit-box-orient: vertical;
	overflow: hidden;
}

.notif-card-actions {
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding-top: 8px;
	border-top: 1px solid rgba(255, 255, 255, 0.05);
}

.btn-card-open {
	font-size: 11.5px;
	font-weight: 700;
	color: #38bdf8;
	background: rgba(56, 189, 248, 0.1);
	border: 1px solid rgba(56, 189, 248, 0.2);
	border-radius: 12px;
	padding: 3px 10px;
	display: inline-flex;
	align-items: center;
	gap: 4px;
	transition: all 0.15s ease;
}

.notif-card-item:hover .btn-card-open {
	background: #38bdf8;
	color: #0f172a;
}

.btn-notif-archive {
	background: transparent;
	border: none;
	color: #94a3b8;
	font-size: 11.5px;
	font-weight: 600;
	cursor: pointer;
	display: inline-flex;
	align-items: center;
	gap: 4px;
	padding: 3px 6px;
	transition: color 0.15s;
}

.btn-notif-archive:hover {
	color: #ef4444;
}

.notif-empty {
	text-align: center;
	padding: 40px 20px;
	color: #94a3b8;
	font-size: 13.5px;
}
.notif-empty i {
	font-size: 34px;
	color: #475569;
	margin-bottom: 10px;
	display: block;
}

.notif-dropdown-footer {
	padding: 12px 20px;
	background: rgba(255, 255, 255, 0.02);
	border-top: 1px solid rgba(255, 255, 255, 0.08);
	text-align: center;
}
.notif-dropdown-footer a {
	color: #38bdf8;
	font-size: 12.5px;
	font-weight: 700;
	text-decoration: none;
	display: inline-flex;
	align-items: center;
	gap: 6px;
	transition: gap 0.2s ease;
}
.notif-dropdown-footer a:hover {
	gap: 10px;
}

/* ========================================================= */
/* PREMIUM NOTIFICATION DETAIL MODAL STYLING                */
/* ========================================================= */
.notif-modal-backdrop {
	position: fixed;
	top: 0;
	left: 0;
	width: 100vw;
	height: 100vh;
	background: rgba(15, 23, 42, 0.75);
	backdrop-filter: blur(12px);
	-webkit-backdrop-filter: blur(12px);
	z-index: 999999;
	display: flex;
	align-items: center;
	justify-content: center;
	padding: 20px;
	animation: modalFadeIn 0.2s ease-out;
}

@keyframes modalFadeIn {
	from { opacity: 0; }
	to { opacity: 1; }
}

.notif-modal-card {
	background: #0f172a;
	background: linear-gradient(145deg, rgba(30, 41, 59, 0.98), rgba(15, 23, 42, 0.98));
	border: 1px solid rgba(255, 255, 255, 0.15);
	border-radius: 24px;
	box-shadow: 0 30px 80px rgba(0, 0, 0, 0.7), 0 0 1px 1px rgba(255, 255, 255, 0.15);
	width: 100%;
	max-width: 540px;
	overflow: hidden;
	display: flex;
	flex-direction: column;
	animation: modalScaleUp 0.25s cubic-bezier(0.16, 1, 0.3, 1);
	color: #f8fafc;
	text-align: left;
}

@keyframes modalScaleUp {
	from { transform: scale(0.92) translateY(10px); opacity: 0; }
	to { transform: scale(1) translateY(0); opacity: 1; }
}

.notif-modal-header {
	padding: 20px 24px;
	border-bottom: 1px solid rgba(255, 255, 255, 0.08);
	display: flex;
	justify-content: space-between;
	align-items: center;
	background: rgba(255, 255, 255, 0.02);
}

.notif-modal-badges {
	display: flex;
	align-items: center;
	gap: 8px;
}

.btn-modal-close {
	background: rgba(255, 255, 255, 0.08);
	border: 1px solid rgba(255, 255, 255, 0.15);
	color: #cbd5e1;
	width: 32px;
	height: 32px;
	border-radius: 50%;
	cursor: pointer;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 14px;
	transition: all 0.2s ease;
}

.btn-modal-close:hover {
	background: #ef4444;
	color: #ffffff;
	border-color: #ef4444;
	transform: rotate(90deg);
}

.notif-modal-body {
	padding: 24px;
	overflow-y: auto;
	max-height: 60vh;
	display: flex;
	flex-direction: column;
	gap: 16px;
}

.modal-meta-row {
	display: flex;
	justify-content: space-between;
	align-items: center;
	font-size: 12.5px;
	color: #94a3b8;
	padding-bottom: 12px;
	border-bottom: 1px solid rgba(255, 255, 255, 0.06);
}

.modal-sender-tag {
	display: inline-flex;
	align-items: center;
	gap: 6px;
	color: #e2e8f0;
	font-weight: 600;
}

.modal-title-text {
	font-size: 18px;
	font-weight: 800;
	color: #ffffff;
	line-height: 1.35;
}

.modal-message-box {
	background: rgba(0, 0, 0, 0.3);
	border: 1px solid rgba(255, 255, 255, 0.08);
	border-radius: 16px;
	padding: 16px;
	font-size: 14px;
	line-height: 1.6;
	color: #e2e8f0;
	white-space: pre-line;
	word-break: break-word;
	font-family: inherit;
}

.modal-action-banner {
	background: rgba(56, 189, 248, 0.08);
	border: 1px solid rgba(56, 189, 248, 0.25);
	border-radius: 14px;
	padding: 14px 16px;
	display: flex;
	align-items: center;
	justify-content: space-between;
	gap: 12px;
}

.modal-action-banner span {
	font-size: 13px;
	color: #bae6fd;
	font-weight: 500;
}

.btn-banner-link {
	background: #38bdf8;
	color: #0f172a;
	padding: 6px 14px;
	border-radius: 10px;
	font-size: 12px;
	font-weight: 700;
	text-decoration: none;
	display: inline-flex;
	align-items: center;
	gap: 6px;
	transition: all 0.2s ease;
	white-space: nowrap;
}

.btn-banner-link:hover {
	background: #7dd3fc;
	box-shadow: 0 4px 12px rgba(56, 189, 248, 0.4);
}

.notif-modal-footer {
	padding: 16px 24px;
	border-top: 1px solid rgba(255, 255, 255, 0.08);
	background: rgba(255, 255, 255, 0.02);
	display: flex;
	justify-content: space-between;
	align-items: center;
	gap: 10px;
}

.modal-footer-left, .modal-footer-right {
	display: flex;
	align-items: center;
	gap: 8px;
}

.btn-modal-action {
	background: rgba(255, 255, 255, 0.08);
	border: 1px solid rgba(255, 255, 255, 0.15);
	color: #f8fafc;
	border-radius: 12px;
	padding: 7px 14px;
	font-size: 12.5px;
	font-weight: 600;
	cursor: pointer;
	display: inline-flex;
	align-items: center;
	gap: 6px;
	transition: all 0.2s ease;
}

.btn-modal-action:hover {
	background: rgba(255, 255, 255, 0.18);
	color: #ffffff;
}

.btn-modal-primary {
	background: #6366f1;
	border-color: #6366f1;
	color: #ffffff;
}

.btn-modal-primary:hover {
	background: #4f46e5;
	box-shadow: 0 4px 14px rgba(99, 102, 241, 0.4);
}

/* Toast feedback */
.notif-toast {
	position: fixed;
	bottom: 24px;
	right: 24px;
	background: #10b981;
	color: #ffffff;
	padding: 10px 18px;
	border-radius: 12px;
	font-size: 13px;
	font-weight: 700;
	box-shadow: 0 10px 30px rgba(0, 0, 0, 0.35);
	z-index: 9999999;
	display: flex;
	align-items: center;
	gap: 8px;
	animation: toastSlide 0.3s cubic-bezier(0.16, 1, 0.3, 1);
}

@keyframes toastSlide {
	from { transform: translateY(20px); opacity: 0; }
	to { transform: translateY(0); opacity: 1; }
}
</style>

<!-- SmartNotification Bell Wrapper -->
<div class="smart-notif-wrapper">
	<!-- Bell Button -->
	<button type="button" id="notifBellBtn" class="notif-bell-btn" onclick="toggleNotificationDropdown(event)" title="Notifications">
		<i class="fa-solid fa-bell"></i>
		<span id="notifBadge" class="notif-badge" style="display: none;">0</span>
	</button>

	<!-- Glassmorphism Dropdown Panel -->
	<div id="notifDropdown" class="notif-dropdown-panel" style="display: none;" onclick="event.stopPropagation()">
		<div class="notif-dropdown-header">
			<h3><i class="fa-solid fa-bell" style="color: #38bdf8;"></i> Notifications (<span id="notifHeaderCount">0</span>)</h3>
			<button type="button" class="btn-mark-all-read" onclick="markAllNotificationsRead(event)">
				<i class="fa-solid fa-check-double"></i> Mark All Read
			</button>
		</div>

		<!-- Dropdown Filter Tabs -->
		<div class="notif-filter-tabs">
			<button type="button" class="notif-tab active" data-filter="all" onclick="filterDropdownNotifList('all', this)">All (<span id="tabCountAll">0</span>)</button>
			<button type="button" class="notif-tab" data-filter="unread" onclick="filterDropdownNotifList('unread', this)">Unread (<span id="tabCountUnread">0</span>)</button>
			<button type="button" class="notif-tab" data-filter="urgent" onclick="filterDropdownNotifList('urgent', this)">🔥 Urgent</button>
			<button type="button" class="notif-tab" data-filter="task" onclick="filterDropdownNotifList('task', this)">Tasks</button>
			<button type="button" class="notif-tab" data-filter="meeting" onclick="filterDropdownNotifList('meeting', this)">Meetings</button>
		</div>

		<div id="notifDropdownList" class="notif-dropdown-list">
			<div class="notif-empty">
				<i class="fa-solid fa-spinner fa-spin"></i>
				<div>Loading notifications...</div>
			</div>
		</div>
		<div class="notif-dropdown-footer">
			<a href="${pageContext.request.contextPath}/sendNotification">
				<span>Open Notification Command Center</span>
				<i class="fa-solid fa-arrow-right"></i>
			</a>
		</div>
	</div>
</div>

<!-- NOTIFICATION DETAIL MODAL -->
<div id="smartNotifModalDropdown" class="notif-modal-backdrop" style="display: none;" onclick="handleDropdownModalBackdropClick(event)">
	<div class="notif-modal-card" onclick="event.stopPropagation()">
		<div class="notif-modal-header">
			<div class="notif-modal-badges">
				<span id="modalDropdownCatPill" class="notif-pill pill-default"><i class="fa-solid fa-bell"></i> Announcement</span>
				<span id="modalDropdownPrioBadge" class="notif-pill" style="background: rgba(255,255,255,0.1); color: #cbd5e1;">Medium</span>
			</div>
			<button type="button" class="btn-modal-close" onclick="closeSmartDropdownModal()" title="Close">&times;</button>
		</div>
		<div class="notif-modal-body">
			<div class="modal-meta-row">
				<div class="modal-sender-tag">
					<i class="fa-regular fa-user" style="color: #38bdf8;"></i>
					<span id="modalDropdownSender">RChips Solutions System</span>
				</div>
				<div id="modalDropdownTimestamp" style="color: #94a3b8;"><i class="fa-regular fa-clock"></i> Just now</div>
			</div>
			<div id="modalDropdownTitle" class="modal-title-text">Notification Title</div>
			<div id="modalDropdownBody" class="modal-message-box">Notification message content...</div>

			<!-- Dynamic Context Module Link -->
			<div id="modalDropdownContextLinkBox" class="modal-action-banner" style="display: none;">
				<span id="modalDropdownContextText">Related to your assigned activity</span>
				<a href="#" id="modalDropdownContextBtn" class="btn-banner-link">
					<span id="modalDropdownContextBtnText">Open Link</span>
					<i class="fa-solid fa-arrow-up-right-from-square"></i>
				</a>
			</div>
		</div>
		<div class="notif-modal-footer">
			<div class="modal-footer-left">
				<button type="button" class="btn-modal-action" onclick="copyDropdownModalMessage()">
					<i class="fa-regular fa-copy"></i> Copy Text
				</button>
				<button type="button" id="modalDropdownArchiveBtn" class="btn-modal-action" onclick="archiveCurrentDropdownModalNotif()">
					<i class="fa-regular fa-folder-closed"></i> Archive
				</button>
			</div>
			<div class="modal-footer-right">
				<button type="button" class="btn-modal-action btn-modal-primary" onclick="closeSmartDropdownModal()">
					<i class="fa-solid fa-check"></i> Done
				</button>
			</div>
		</div>
	</div>
</div>

<script>
(function() {
	var contextPath = "${pageContext.request.contextPath}";
	var dropdownNotifications = [];
	var dropdownActiveFilter = "all";
	var currentDropdownModalId = null;

	window.toggleNotificationDropdown = function(e) {
		if (e) e.stopPropagation();
		var dropdown = document.getElementById("notifDropdown");
		var bell = document.getElementById("notifBellBtn");
		if (!dropdown) return;
		if (dropdown.style.display === "none" || dropdown.style.display === "") {
			dropdown.style.display = "flex";
			if (bell) bell.classList.add("active");
			fetchNotifications();
		} else {
			dropdown.style.display = "none";
			if (bell) bell.classList.remove("active");
		}
	};

	document.addEventListener("click", function(e) {
		var dropdown = document.getElementById("notifDropdown");
		var bell = document.getElementById("notifBellBtn");
		if (dropdown && dropdown.style.display !== "none") {
			if (!dropdown.contains(e.target) && !bell.contains(e.target)) {
				dropdown.style.display = "none";
				if (bell) bell.classList.remove("active");
			}
		}
	});

	window.fetchNotifications = function() {
		fetch(contextPath + "/getNotifications")
			.then(function(res) { return res.json(); })
			.then(function(data) {
				dropdownNotifications = data.notifications || [];
				renderNotifications(data);
			})
			.catch(function(err) {
				console.error("[NotificationCenter] Error fetching notifications:", err);
			});
	};

	window.filterDropdownNotifList = function(filter, btn) {
		dropdownActiveFilter = filter;
		document.querySelectorAll(".notif-tab").forEach(function(t) {
			t.classList.remove("active");
		});
		if (btn) btn.classList.add("active");
		renderDropdownCards();
	};

	function renderNotifications(data) {
		var badge = document.getElementById("notifBadge");
		var headerCount = document.getElementById("notifHeaderCount");
		var tabAll = document.getElementById("tabCountAll");
		var tabUnread = document.getElementById("tabCountUnread");

		var count = data.unreadCount || 0;
		if (badge) {
			if (count > 0) {
				badge.textContent = count > 99 ? "99+" : count;
				badge.style.display = "flex";
			} else {
				badge.style.display = "none";
			}
		}
		if (headerCount) headerCount.textContent = count;
		if (tabUnread) tabUnread.innerText = count;
		if (tabAll) tabAll.innerText = dropdownNotifications.length;

		renderDropdownCards();
	}

	function renderDropdownCards() {
		var list = document.getElementById("notifDropdownList");
		if (!list) return;

		var filtered = dropdownNotifications.filter(function(item) {
			var isUnread = !item.isRead && item.status !== "Read";
			var cat = (item.category || "").toLowerCase();
			var prio = (item.priority || "").toLowerCase();

			if (dropdownActiveFilter === "unread") return isUnread;
			if (dropdownActiveFilter === "urgent") return prio === "critical" || prio === "high" || prio === "urgent";
			if (dropdownActiveFilter === "task") return cat.indexOf("task") !== -1;
			if (dropdownActiveFilter === "meeting") return cat.indexOf("meeting") !== -1;
			return true;
		});

		if (filtered.length === 0) {
			var emptyMsg = dropdownActiveFilter === "unread" ? "No unread notifications" : "No notifications in this filter";
			list.innerHTML = '<div class="notif-empty"><i class="fa-regular fa-bell-slash"></i><div>' + emptyMsg + '</div></div>';
			return;
		}

		var html = "";
		for (var i = 0; i < filtered.length; i++) {
			var n = filtered[i];
			var category = n.category || "Announcement";
			var pillClass = getPillClass(category);
			var iconClass = getCategoryIconClass(category);
			var isUnread = !n.isRead && n.status !== "Read";

			var prioDot = "";
			if (n.priority === "Critical" || n.priority === "High" || n.priority === "URGENT") {
				prioDot = '<span class="dot-urgent" title="Urgent"></span> <span style="font-size:11px; color:#ef4444; font-weight:700;">urgent</span>';
			} else if (n.priority === "Medium") {
				prioDot = '<span class="dot-info" title="Info"></span> <span style="font-size:11px; color:#38bdf8; font-weight:700;">info</span>';
			}

			html += '<div class="notif-card-item ' + (isUnread ? 'unread' : '') + '" id="notif-card-' + n.id + '" onclick="openDropdownDetailModal(\'' + n.id + '\', event)">'
				+ '<div class="notif-card-top">'
				+ '<span class="notif-pill ' + pillClass + '"><i class="' + iconClass + '"></i> ' + escapeHtml(category) + '</span>'
				+ '<div class="notif-time-status"><i class="fa-regular fa-clock" style="font-size:11px;"></i> ' + escapeHtml(n.time || "Recently") + ' ' + prioDot + '</div>'
				+ '</div>'
				+ '<div class="notif-card-title">' + escapeHtml(n.title) + '</div>'
				+ '<div class="notif-card-snippet">' + escapeHtml(n.message) + '</div>'
				+ '<div class="notif-card-actions">'
				+ '<span class="btn-card-open"><i class="fa-solid fa-envelope-open-text"></i> Open Details</span>'
				+ '<button type="button" class="btn-notif-archive" onclick="archiveSingleNotif(\'' + n.id + '\', event)" title="Archive"><i class="fa-regular fa-folder-closed"></i> Archive</button>'
				+ '</div>'
				+ '</div>';
		}

		list.innerHTML = html;
	}

	function getPillClass(cat) {
		if (!cat) return "pill-default";
		var c = cat.toLowerCase();
		if (c.indexOf("meeting") !== -1) return "pill-meeting";
		if (c.indexOf("task") !== -1) return "pill-task";
		if (c.indexOf("leave") !== -1) return "pill-leave";
		if (c.indexOf("attendance") !== -1) return "pill-attendance";
		if (c.indexOf("announcement") !== -1) return "pill-announcement";
		if (c.indexOf("security") !== -1) return "pill-security";
		if (c.indexOf("payroll") !== -1) return "pill-payroll";
		return "pill-default";
	}

	function getCategoryIconClass(cat) {
		if (!cat) return "fa-solid fa-bell";
		var c = cat.toLowerCase();
		if (c.indexOf("meeting") !== -1) return "fa-solid fa-users";
		if (c.indexOf("task") !== -1) return "fa-solid fa-list-check";
		if (c.indexOf("leave") !== -1) return "fa-solid fa-calendar-minus";
		if (c.indexOf("attendance") !== -1) return "fa-solid fa-user-clock";
		if (c.indexOf("announcement") !== -1) return "fa-solid fa-bullhorn";
		if (c.indexOf("security") !== -1) return "fa-solid fa-shield-halved";
		if (c.indexOf("payroll") !== -1) return "fa-solid fa-file-invoice-dollar";
		return "fa-solid fa-bell";
	}

	function escapeHtml(str) {
		if (!str) return "";
		return String(str).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
	}

	// Modal opening logic
	window.openDropdownDetailModal = function(id, e) {
		if (e) e.stopPropagation();
		currentDropdownModalId = id;

		var item = dropdownNotifications.find(function(n) { return String(n.id) === String(id); });
		if (!item) return;

		// Auto Mark as Read when opened
		if (!item.isRead && item.status !== "Read") {
			markSingleRead(id, null, false);
			item.isRead = true;
			item.status = "Read";
			var card = document.getElementById("notif-card-" + id);
			if (card) card.classList.remove("unread");
		}

		var modal = document.getElementById("smartNotifModalDropdown");
		var pill = document.getElementById("modalDropdownCatPill");
		var prio = document.getElementById("modalDropdownPrioBadge");
		var sender = document.getElementById("modalDropdownSender");
		var time = document.getElementById("modalDropdownTimestamp");
		var title = document.getElementById("modalDropdownTitle");
		var body = document.getElementById("modalDropdownBody");
		var linkBox = document.getElementById("modalDropdownContextLinkBox");
		var linkBtn = document.getElementById("modalDropdownContextBtn");
		var linkText = document.getElementById("modalDropdownContextText");
		var linkBtnText = document.getElementById("modalDropdownContextBtnText");

		var category = item.category || "Announcement";
		pill.className = "notif-pill " + getPillClass(category);
		pill.innerHTML = '<i class="' + getCategoryIconClass(category) + '"></i> ' + escapeHtml(category);

		var p = (item.priority || "Medium").toUpperCase();
		if (p === "CRITICAL" || p === "HIGH" || p === "URGENT") {
			prio.style.background = "#ef4444";
			prio.style.color = "#ffffff";
			prio.innerText = "🔥 " + (item.priority || "Urgent");
		} else if (p === "MEDIUM") {
			prio.style.background = "#0284c7";
			prio.style.color = "#ffffff";
			prio.innerText = "Info (Medium)";
		} else {
			prio.style.background = "#64748b";
			prio.style.color = "#ffffff";
			prio.innerText = "Low";
		}

		sender.innerText = item.senderName && item.senderName !== "null" ? item.senderName : "SmartOffice ELAMS";
		time.innerHTML = '<i class="fa-regular fa-clock"></i> ' + escapeHtml(item.time || "Recently");
		title.innerText = item.title || "Notification";
		body.innerText = item.message || "";

		var catLower = category.toLowerCase();
		if (catLower.indexOf("task") !== -1) {
			linkBox.style.display = "flex";
			linkText.innerText = "Tasks Management & Work Assignment";
			linkBtnText.innerText = "View Tasks";
			linkBtn.href = contextPath + "/taskReportServlet";
		} else if (catLower.indexOf("meeting") !== -1) {
			linkBox.style.display = "flex";
			linkText.innerText = "Meeting Schedule & Calendar";
			linkBtnText.innerText = "View Meetings";
			linkBtn.href = contextPath + "/viewMeetings.jsp";
		} else if (catLower.indexOf("leave") !== -1) {
			linkBox.style.display = "flex";
			linkText.innerText = "Leave Balances & Requests";
			linkBtnText.innerText = "Leave Portal";
			linkBtn.href = contextPath + "/leaveHistory.jsp";
		} else if (catLower.indexOf("attendance") !== -1) {
			linkBox.style.display = "flex";
			linkText.innerText = "Work Attendance & Timesheets";
			linkBtnText.innerText = "Attendance History";
			linkBtn.href = contextPath + "/attendanceHistory.jsp";
		} else {
			linkBox.style.display = "none";
		}

		if (modal) modal.style.display = "flex";
	};

	window.closeSmartDropdownModal = function() {
		var modal = document.getElementById("smartNotifModalDropdown");
		if (modal) modal.style.display = "none";
		currentDropdownModalId = null;
	};

	window.handleDropdownModalBackdropClick = function(e) {
		if (e.target.id === "smartNotifModalDropdown") {
			closeSmartDropdownModal();
		}
	};

	window.copyDropdownModalMessage = function() {
		var body = document.getElementById("modalDropdownBody");
		if (body) {
			navigator.clipboard.writeText(body.innerText).then(function() {
				showDropdownToast("Notification message copied to clipboard!");
			}).catch(function() {
				showDropdownToast("Message copied!");
			});
		}
	};

	window.archiveCurrentDropdownModalNotif = function() {
		if (currentDropdownModalId) {
			archiveSingleNotif(currentDropdownModalId, null);
			closeSmartDropdownModal();
		}
	};

	function showDropdownToast(msg) {
		var toast = document.createElement("div");
		toast.className = "notif-toast";
		toast.innerHTML = '<i class="fa-solid fa-circle-check"></i> ' + escapeHtml(msg);
		document.body.appendChild(toast);
		setTimeout(function() {
			toast.style.transition = "all 0.3s ease";
			toast.style.opacity = "0";
			toast.style.transform = "translateY(20px)";
			setTimeout(function() { toast.remove(); }, 300);
		}, 2500);
	}

	window.markSingleRead = function(id, e, refresh) {
		if (e) e.stopPropagation();
		if (refresh === undefined) refresh = true;
		fetch(contextPath + "/getNotifications?action=markRead&id=" + id, { method: "POST" })
			.then(function(res) { return res.json(); })
			.then(function(res) {
				if (refresh) fetchNotifications();
			});
	};

	window.archiveSingleNotif = function(id, e) {
		if (e) e.stopPropagation();
		fetch(contextPath + "/getNotifications?action=archive&id=" + id, { method: "POST" })
			.then(function(res) { return res.json(); })
			.then(function(res) {
				var el = document.getElementById("notif-card-" + id);
				if (el) {
					el.style.opacity = "0";
					el.style.transform = "scale(0.9)";
					setTimeout(function() { fetchNotifications(); }, 200);
				} else {
					fetchNotifications();
				}
			});
	};

	window.markAllNotificationsRead = function(e) {
		if (e) e.stopPropagation();
		fetch(contextPath + "/getNotifications?action=markAllRead", { method: "POST" })
			.then(function(res) { return res.json(); })
			.then(function(res) {
				fetchNotifications();
				showDropdownToast("All notifications marked as read!");
			});
	};

	// Initial fetch & set poll interval (every 10s)
	document.addEventListener("DOMContentLoaded", function() {
		fetchNotifications();
		setInterval(fetchNotifications, 10000);
	});
})();
</script>
