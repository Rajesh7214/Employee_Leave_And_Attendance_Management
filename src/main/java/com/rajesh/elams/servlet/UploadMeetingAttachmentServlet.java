package com.rajesh.elams.servlet;

import java.io.IOException;

import com.rajesh.elams.dao.MeetingAttachmentDao;
import com.rajesh.elams.dao.MeetingAttachmentDaoImpl;
import com.rajesh.elams.model.Employee;
import com.rajesh.elams.model.MeetingAttachment;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(urlPatterns = { "/uploadMeetingAttachment", "/deleteMeetingAttachment" })
public class UploadMeetingAttachmentServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private MeetingAttachmentDao attachmentDao;

	@Override
	public void init() {
		attachmentDao = new MeetingAttachmentDaoImpl();
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("loggedUser") == null) {
			response.sendRedirect("login.jsp");
			return;
		}

		String servletPath = request.getServletPath();

		if ("/deleteMeetingAttachment".equals(servletPath)) {
			int attachmentId = Integer.parseInt(request.getParameter("attachmentId"));
			int meetingId = Integer.parseInt(request.getParameter("meetingId"));
			attachmentDao.deleteAttachment(attachmentId);
			response.sendRedirect("meetingDetail?meetingId=" + meetingId);
			return;
		}

		// Upload / Add Attachment
		int meetingId = Integer.parseInt(request.getParameter("meetingId"));
		String fileName = request.getParameter("fileName");
		String filePath = request.getParameter("filePath");
		String fileType = request.getParameter("fileType");
		String description = request.getParameter("description");

		Employee employee = (Employee) session.getAttribute("employee");
		int uploadedBy = employee != null ? employee.getEmployee_id() : 1;

		if (fileName != null && !fileName.isBlank() && filePath != null && !filePath.isBlank()) {
			MeetingAttachment att = new MeetingAttachment();
			att.setMeetingId(meetingId);
			att.setFileName(fileName.trim());
			att.setFilePath(filePath.trim());
			att.setFileType(fileType != null && !fileType.isBlank() ? fileType.trim() : "Document");
			att.setDescription(description != null ? description.trim() : "");
			att.setUploadedBy(uploadedBy);

			attachmentDao.addAttachment(att);
		}

		response.sendRedirect("meetingDetail?meetingId=" + meetingId);
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doPost(request, response);
	}
}
