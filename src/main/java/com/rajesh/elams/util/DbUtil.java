package com.rajesh.elams.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DbUtil {

	private static String url = "jdbc:mysql://localhost:3306/ELAMS";

	private static String user = "root";
	private static String pwd = "root";

	public static Connection getConnection() throws SQLException, ClassNotFoundException {

		Class.forName("com.mysql.cj.jdbc.Driver");

		Connection con = DriverManager.getConnection(url, user, pwd);

		System.out.println("Database Connected Successfully");

		return con;
	}
}