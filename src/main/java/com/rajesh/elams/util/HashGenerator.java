package com.rajesh.elams.util;

public class HashGenerator {

	public static void main(String[] args) {

		System.out.println("Admin : " + PasswordUtil.hashPassword("admin123"));

		System.out.println("Manager : " + PasswordUtil.hashPassword("manager123"));

		System.out.println("Employee : " + PasswordUtil.hashPassword("employee123"));

	}
}