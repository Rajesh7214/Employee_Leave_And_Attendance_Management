package com.rajesh.elams.util;

public class SecurityUtil {


	public static String escapeHtml(String input) {
		if (input == null) {
			return "";
		}
		return input.replace("&", "&amp;")
				.replace("<", "&lt;")
				.replace(">", "&gt;")
				.replace("\"", "&quot;")
				.replace("'", "&#x27;")
				.replace("/", "&#x2F;");
	}


	public static String clean(String input) {
		if (input == null) return "";
		return input.trim();
	}
}
