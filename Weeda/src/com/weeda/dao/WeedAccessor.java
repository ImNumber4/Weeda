package com.weeda.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;

public class WeedAccessor {

	private String userName = "utopia";
	private String password = "utopia";
	private String dbName = "utopia";

	public Connection getConnection() throws SQLException {

		java.sql.Connection conn = null;
		Properties connectionProps = new Properties();
		connectionProps.put("user", this.userName);
		connectionProps.put("password", this.password);

		conn = DriverManager.getConnection("jdbc:mysql://54.215.236.186:3306/" + dbName, connectionProps);
		System.out.println("Connected to database");
		return conn;
	}

	public static void main(String[] args) throws SQLException {
		WeedAccessor accessor = new WeedAccessor();
		Connection conn;
		conn = accessor.getConnection();
		Statement statement = conn.createStatement();
		ResultSet rs = statement.executeQuery("Show Tables");
		while (rs.next()) {
			System.out.println(rs.getString("Tables_in_utopia"));
		}

		rs.close();
		statement.close();
		conn.close();
	}
}
