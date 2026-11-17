package com.rajesh.elams.model;

public enum PayrollStatus {
	DRAFT("Draft", "badge-draft"),
	CALCULATED("Calculated", "badge-calculated"),
	PENDING_APPROVAL("Pending Approval", "badge-pending"),
	APPROVED("Approved", "badge-approved"),
	PROCESSED("Processed", "badge-processed"),
	PAID("Paid", "badge-paid"),
	CANCELLED("Cancelled", "badge-cancelled");

	private final String displayName;
	private final String cssClass;

	PayrollStatus(String displayName, String cssClass) {
		this.displayName = displayName;
		this.cssClass = cssClass;
	}

	public String getDisplayName() {
		return displayName;
	}

	public String getCssClass() {
		return cssClass;
	}

	public static PayrollStatus fromString(String text) {
		if (text != null) {
			for (PayrollStatus b : PayrollStatus.values()) {
				if (b.name().equalsIgnoreCase(text.trim())) {
					return b;
				}
			}
		}
		return DRAFT;
	}
}
