import java.awt.Container;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.Date;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.Scanner;

import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPasswordField;
import javax.swing.JTextField;

public class AppWindow extends JFrame implements ActionListener {
	private static final long serialVersionUID = 1L;
	/**
	 * Textfeld fur die Datei-Adresse mit create tables  Anweisungen
	 */
	protected JTextField jtfCreateTables;
	/**
	 * Textfeld fur den log-Datei Pfad
	 */
	protected JTextField jtfLog;
	/**
	 * Textfeld fur login
	 */
	protected JTextField jtfLogin;
	/**
	 * Textfeld fur password
	 */
	protected JPasswordField jtfPassword;

	protected JTextField jtfServer;
	
	/**
	 * GUI Konstrukteur
	 */
	public AppWindow() {
		setSize(400, 250);
		Container contentPane = getContentPane();
		contentPane.setLayout(new BoxLayout(contentPane, BoxLayout.Y_AXIS));
		JLabel labelCreateTables = new JLabel("Path for create_tables");
		contentPane.add(labelCreateTables);

		jtfCreateTables = new JTextField();
		contentPane.add(jtfCreateTables);
		jtfCreateTables.setText(new File(AppWindow.class.getProtectionDomain().getCodeSource().getLocation().getPath().replace("migration.jar", "")) + "/create_tables.txt"); //Default Value

		JLabel labelLogFile = new JLabel("Path for log.txt");
		contentPane.add(labelLogFile);

		jtfLog = new JTextField();
		contentPane.add(jtfLog);
		jtfLog.setText(new File(AppWindow.class.getProtectionDomain().getCodeSource().getLocation().getPath().replace("migration.jar", "")) + "/log.txt");//Default Value
		
		contentPane.add(new JLabel("Server"));
		
		jtfServer = new JTextField();
		contentPane.add(jtfServer);
		jtfServer.setText("localhost"); //Default Value

		JLabel labelLogin = new JLabel("Login");
		contentPane.add(labelLogin);

		jtfLogin = new JTextField();
		contentPane.add(jtfLogin);
		jtfLogin.setText("root");//Default Value

		JLabel labelPassword = new JLabel("Password");
		contentPane.add(labelPassword);

		jtfPassword = new JPasswordField();
		contentPane.add(jtfPassword);
		

		JButton startButton = new JButton("Start");
		startButton.addActionListener(this);
		contentPane.add(startButton);
		setDefaultCloseOperation(EXIT_ON_CLOSE);
		setVisible(true);
	}

	public static void main(String[] args) {
		new AppWindow();
	}

	/**
	 * Action beim Drucken der Taste "Start"
	 * 
	 */	
	public void actionPerformed(ActionEvent ae) {		
		Migratior.migrate(jtfCreateTables.getText(), jtfServer.getText(), jtfLogin.getText(), jtfPassword.getText(), jtfLog.getText());
	}
}
