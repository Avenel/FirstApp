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
import java.text.DateFormat;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.Scanner;

public class Migratior {
	private static String inputfile = new File(AppWindow.class
			.getProtectionDomain().getCodeSource().getLocation().getPath()
			.replace("migration.jar", ""), "/create_tables.txt").toString();
	private static String server = "localhost";
	private static String user;
	private static String password;
	private static String pathToLog = new File(AppWindow.class
			.getProtectionDomain().getCodeSource().getLocation().getPath()
			.replace("migration.jar", ""), "log.txt").toString();

	public static void main(String[] args) {
		if (args.length == 0) {
			new AppWindow();
		} else {
			if (args[0].equals("-h")) {
				printHelp();
			} else {
				for (int i = 0; i < args.length; i++) {
					if (args[i].equals("-i"))
						inputfile = args[++i];
					if (args[i].equals("-s"))
						server = args[++i];
					if (args[i].equals("-u"))
						user = args[++i];
					if (args[i].equals("-p"))
						password = args[++i];
				}
			}
			System.out.println("migration ...");
			migrate(inputfile, server, user, password, pathToLog);
		}
	}

	private static void printHelp() {
		System.out.println("-h \t Zeigt diese Hilfeseite");
		System.out
				.println("-i \t Setzt den Pfad zur txt-Datei mit der Tabellendefiniton (Default: im gleichen Ordner wir die Jar-Datei die Datei create_tables.txt");
		System.out.println("-s \t Setzt den Server (Default: localhost");
		System.out.println("-u \t Setzt den Username f�r den Login");
		System.out.println("-p \t Setzt das Password");
	}

	public static void migrate(String pathToFile, String server, String user,
			String password, String pathToLog) {
		Calendar calendar = Calendar.getInstance();
		GregorianCalendar endCalender = new GregorianCalendar(9999, 11, 31, 23,
				59, 59);
		Timestamp endOfTime = new java.sql.Timestamp(endCalender.getTime()
				.getTime());

		try {
			/**
			 * Lesen Dateiinhalt
			 */
			Scanner in = new Scanner(new File(pathToFile));
			/**
			 * Sql Aufrufe mussen von einander mit dem Symbol ";" getrennt sein
			 */
			in.useDelimiter(";");
			Class.forName("com.mysql.jdbc.Driver");
			/**
			 * Link zur neuen Datenbank
			 */
			String urlOzbTest = "jdbc:mysql://" + server
					+ "/ozb_test?zeroDateTimeBehavior=convertToNull";
			/**
			 * Link zur alten Datenbank
			 */
			String urlOzbProd = "jdbc:mysql://" + server
					+ "/ozb_prod?zeroDateTimeBehavior=convertToNull";
			/**
			 * Ausgabe aller Fehler in der log Datei
			 */
			PrintWriter pw = new PrintWriter(new FileOutputStream(pathToLog));
			try {
				/**
				 * Erstellung Verbindungen zu Datenbanken
				 */
				Connection conOzbProd = DriverManager.getConnection(urlOzbProd,
						user, password);
				Connection conOzbTest = DriverManager.getConnection(urlOzbTest,
						user, password);
				conOzbTest.setAutoCommit(false);
				Statement stOzbTest = conOzbTest.createStatement();
				Statement stOzbProd = conOzbProd.createStatement();
				/**
				 * Vorbereitung der SQl Aufrufe fur die neue Datenbank. Inhalt
				 * von Attributen wird spater hingefugt
				 */
				String queryInsertPerson = "INSERT INTO person "
						+ "(Pnr,Rolle,Name,Vorname,Geburtsdatum,"
						+ "EMail,GueltigVon,GueltigBis,SperrKZ) VALUES "
						+ "(?,?,?,?,?,?,?,?,?);";
				String queryInsertAdresse = "INSERT INTO adresse (Pnr,Strasse,Nr,PLZ,Ort,GueltigVon,GueltigBis,Vermerk) VALUES (?,?,?,?,?,?,?,?);";
				String queryInsertOZBPerson = "INSERT INTO ozbperson (Mnr,UeberPnr,Antragsdatum,Aufnahmedatum,Austrittsdatum,Schulungsdatum) VALUES (?,?,?,?,?,?);";
				String queryInsertPartner = "INSERT INTO partner (Mnr,Pnr_P,Berechtigung,GueltigVon,GueltigBis) VALUES (?,?,?,?,?);";
				String queryInsertMitglied = "INSERT INTO mitglied (Mnr,RVDatum,GueltigVon,GueltigBis) VALUES (?,?,?,?);";
				String queryInsertGesellschafter = "INSERT INTO gesellschafter (Mnr,FASteuerNr,FALfdNr,FAIdNr,Wohnsitzfinanzamt,GueltigVon,GueltigBis) VALUES (?,?,?,?,?,?,?);";
				String queryInsertStudent = "INSERT INTO student (Mnr,GueltigVon,GueltigBis,AusbildBez,InstitutName,Studienort,Studienbeginn,Studienende,Abschluss) VALUES (?,?,?,?,?,?,?,?,?);";
				String queryInsertFoerdermitglied = "INSERT INTO foerdermitglied (Pnr,GueltigVon,GueltigBis,Region,Foerderbeitrag,MJ) VALUES (?,?,?,?,?,?);";
				String queryInsertTelefon = "INSERT INTO telefon (Pnr,LfdNr,TelefonNr,TelefonTyp) VALUES (?,?,?,?);";
				String queryInsertTanliste = "INSERT INTO tanliste (Mnr,ListNr,Status,TanListDatum) VALUES (?,?,?,?);";
				String queryInsertTan = "INSERT INTO tan (Mnr,ListNr,TanNr,Tan,VerwendetAm,Status) VALUES (?,?,?,?,?,?);";
				String queryInsertBankverbindung = "INSERT INTO bankverbindung (Pnr,BankKtoNr,BLZ,GueltigVon,GueltigBis,IBAN) VALUES (?,?,?,?,?,?);";
				String queryInsertBank = "INSERT INTO bank (BLZ,BankName) VALUES (?,?);";

				String queryInsertProjektgruppe = "INSERT INTO projektgruppe (Pgnr,ProjGruppenBez) VALUES (?,?);";
				String queryInsertZEKonto = "INSERT INTO zekonto (KtoNr,EEKtoNr,Pgnr,ZENr,ZEAbDatum,ZEEndDatum,ZEBetrag,Laufzeit,ZahlModus,TilgRate,NachsparRate,KDURate,RDURate,ZEStatus,GueltigVon,GueltigBis,Kalk_Leihpunkte,Tats_Leihpunkte,Sicherung) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);";
				String queryInsertBuergschaft = "INSERT INTO buergschaft (Pnr_B,Mnr_G,ZENr,SichAbDatum,SichEndDatum,SichBetrag,SichKurzbez,GueltigVon,GueltigBis) VALUES (?,?,?,?,?,?,?,?,?);";
				String queryInsertEEKonto = "INSERT INTO eekonto (KtoNr,BankID,Kreditlimit,GueltigVon,GueltigBis) VALUES (?,?,?,?,?)";
				String queryInsertTemp = "INSERT INTO temp (KtoNr,Kreditlimit,BankKtoNr,BLZ,BankName) VALUES (?,?,?,?,?);";
				String queryInsertKontenklasse = "INSERT INTO kontenklasse (KKL,KKLEinrDatum,Prozent) VALUES (?,?,?)";
				String queryInsertKKLVerlauf = "INSERT INTO kklverlauf (KtoNr,KKLAbDatum,KKL) VALUES (?,?,?)";

				String queryInsertVeranstalltungart = "INSERT INTO veranstaltungsart (VANr,VABezeichnung) VALUES (?,?)";
				String queryInsertVeranstalltung = "INSERT INTO veranstaltung (Vnr,VANr,VADatum,VAOrt) VALUES (?,?,?,?)";
				String queryInsertTeilnahme = "INSERT INTO teilnahme (Pnr,Vnr,TeilnArt) VALUES (?,?,?)";

				// User Table (Devise Login Module)
				String queryInsertUser = "INSERT INTO users (id,email,created_at,updated_at) VALUES (?,?,?,?)";

				/**
				 * Lesen, Trennung und Ausfuhrung SQl Aufrufe aus Datei
				 */
				while (in.hasNext()) {
					String line = in.next() + ";";

					try {
						System.out.println("trying" + line);
						stOzbTest.executeUpdate(line);

					} catch (SQLException e) {
						pw.println("create tables : " + e.getMessage());

					}
				}
				conOzbTest.commit();

				// Person
				/**
				 * Aufruf Daten fur die Tabelle Person
				 */
				ResultSet rs = stOzbProd
						.executeQuery(" SELECT `MNR`,`GM`,`NAME`,`VORNAME`, `GEBURTSDATUM`,`STRASSE-NR`, `PLZ`, `ORT`, `VERMERK`, `EMAIL`, `SPERRKZ` FROM Mitglied "
								+ "union "
								+ "select `MNR`,`GM`,`NAME`,`VORNAME`, `GEBURTSDATUM`,`STRASSE-NR`, `PLZ`, `ORT`, `VERMERK`, `EMAIL`, 0 from F�rdermitglied;");

				while (rs.next()) {
					/**
					 * Dynamische Erstellung des Aufrufs und Bearbeitung der
					 * Daten, die wir aus der alten Datenbank bekommen haben.
					 */
					PreparedStatement queryInsertStmt = conOzbTest
							.prepareStatement(queryInsertPerson);
					queryInsertStmt.setInt(1, rs.getInt("MNR"));
					queryInsertStmt.setString(2, rs.getString("GM"));
					queryInsertStmt.setString(3, rs.getString("NAME"));
					queryInsertStmt.setString(4, rs.getString("VORNAME"));
					queryInsertStmt.setDate(5, rs.getDate("GEBURTSDATUM"));
					// queryInsertStmt.setString(6, rs.getString("VERMERK"));
					queryInsertStmt.setString(6, rs.getString("EMAIL"));
					queryInsertStmt.setTimestamp(7, new java.sql.Timestamp(
							calendar.getTime().getTime() - 1 * 24 * 60 * 60
									* 1000));
					queryInsertStmt.setTimestamp(8, endOfTime);

					// Default: 0 -> Logon freigegeben
					queryInsertStmt.setString(9, "0");// rs.getString("SPERRKZ"));

					/**
					 * Ausfuhrung des SQL Aufrufs. Falls ein Fehler vorhanden
					 * wird, wird es im log Datei protokolliert
					 */
					try {
						System.out.println("insert person"
								+ rs.getString("NAME"));
						queryInsertStmt.executeUpdate();
					} catch (SQLException e) {
						pw.println("Person : " + " MNR: " + rs.getInt("MNR")
								+ " " + e.getMessage());
						pw.println("SQL-Query: " + queryInsertStmt.toString());
						pw.println("");
					}

					// Adresse
					queryInsertStmt = conOzbTest
							.prepareStatement(queryInsertAdresse);
					queryInsertStmt.setInt(1, rs.getInt("MNR"));
					if (!(rs.getString("STRASSE-NR") == null)) {
						String temp = rs.getString("STRASSE-NR");
						queryInsertStmt
								.setString(2, getStrasseFromString(temp));
						queryInsertStmt.setString(3, getNumberFromString(temp));
					} else {
						queryInsertStmt.setString(2, "###");
						queryInsertStmt.setString(3, "###");
					}
					queryInsertStmt.setInt(4, rs.getInt("PLZ"));

					if (rs.getString("ORT") == null
							|| rs.getString("ORT").equals("")) {
						queryInsertStmt.setString(5, "###");
					} else {
						queryInsertStmt.setString(5, rs.getString("ORT"));
					}

					queryInsertStmt.setTimestamp(6, new java.sql.Timestamp(
							calendar.getTime().getTime() - 1 * 24 * 60 * 60
									* 1000));
					queryInsertStmt.setTimestamp(7, endOfTime);
					queryInsertStmt.setString(8, rs.getString("VERMERK"));
					try {
						queryInsertStmt.executeUpdate();
					} catch (SQLException e) {
						pw.println("Adresse : " + " MNR: " + rs.getInt("MNR")
								+ " " + e.getMessage());
						pw.println("SQL-Query: " + queryInsertStmt.toString());
						pw.println("");
					}
				}

				// OZBPerson
				String sql = "SELECT DISTINCT m.MNR, O.UEBER_MNR, m.PASSWORT, m.PW_AENDDAT, m.SPERRKZ, m.ANTRAGSDAT, m.AUFNAHMEDAT, m.AUS_DAT, m.SCHUL_DAT, m.EMAIL "
						+ "FROM Mitglied m, Konto k, "
						+ "(select T.km1 MNR, MAX(T.km2) UEBER_MNR "
						+ "from"
						+ "(SELECT distinct m.MNR km1, m2.MNR km2 "
						+ "FROM Mitglied m, Mitglied m2 "
						+ "WHERE m.UEBER_NAME = m2.NAME AND "
						+ "m.UEBER_VORNAME = m2.VORNAME "
						+ "union "
						+ "SELECT distinct m.MNR km1, NULL km2 "
						+ "FROM Mitglied m) T "
						+ "group by T.km1) O "
						+ "WHERE " + "m.MNR = k.MNR AND " + "O.MNR = m.MNR ";
				rs = stOzbProd.executeQuery(sql);
// (Mnr,UeberPnr,Antragsdatum,Aufnahmedatum,Austrittsdatum,Schulungsdatum) VALUES (?,?,?,?,?,?);
				
				while (rs.next()) {
					PreparedStatement queryInsertStmt = conOzbTest
							.prepareStatement(queryInsertOZBPerson);
					queryInsertStmt.setInt(1, rs.getInt("MNR"));
					if (rs.getInt("UEBER_MNR") == 0) {
						queryInsertStmt.setNull(2, java.sql.Types.INTEGER);
					} else {
						queryInsertStmt.setInt(2, rs.getInt("UEBER_MNR"));
					}

					// TODO
					if (rs.getString("ANTRAGSDAT") == null
							|| rs.getString("ANTRAGSDAT").equals("")) {
						queryInsertStmt.setString(3, "0000-01-01"); // Dreckig,
																	// lieber
																	// Calendar
																	// Object
																	// nutzen.
					} else {
						queryInsertStmt.setDate(3, rs.getDate("ANTRAGSDAT"));
					}

					queryInsertStmt.setDate(4, rs.getDate("AUFNAHMEDAT"));
					queryInsertStmt.setDate(5, rs.getDate("AUS_DAT"));
					queryInsertStmt.setDate(6, rs.getDate("SCHUL_DAT"));
					long oneDay = 1 * 24 * 60 * 60 * 1000;
					// queryInsertStmt.setTimestamp(10, new
					// java.sql.Timestamp(calendar.getTime().getTime() - 1 * 24
					// * 60 * 60 * 1000));
					// queryInsertStmt.setTimestamp(11, endOfTime);
					try {
						queryInsertStmt.executeUpdate();
					} catch (SQLException e) {
						pw.println("OZBPerson : " + " MNR: " + rs.getInt("MNR")
								+ " " + e.getMessage());
						pw.println("SQL-Query: " + queryInsertStmt.toString());
						pw.println("");
					}
				}

				// Mitglied
				rs = stOzbProd
						.executeQuery(" SELECT `MNR`,`RV_DAT` FROM Mitglied WHERE GM='M' ");
				while (rs.next()) {

					PreparedStatement queryInsertStmt = conOzbTest
							.prepareStatement(queryInsertMitglied);

					queryInsertStmt.setInt(1, rs.getInt("MNR"));
					queryInsertStmt.setDate(2, rs.getDate("RV_DAT"));
					queryInsertStmt.setTimestamp(3, new java.sql.Timestamp(
							calendar.getTime().getTime() - 1 * 24 * 60 * 60
									* 1000));
					queryInsertStmt.setTimestamp(4, endOfTime);

					try {
						queryInsertStmt.executeUpdate();
					} catch (SQLException e) {
						pw.println("Mitglied : " + " MNR: " + rs.getInt("MNR")
								+ " " + e.getMessage());
						pw.println("SQL-Query: " + queryInsertStmt.toString());
						pw.println("");
					}

				}

				// Gesellschafter

				rs = stOzbProd
						.executeQuery(" SELECT `MNR`,FALfdnr,FAStnr,FAIdnr,WohnsitzFA FROM Mitglied WHERE GM='G' ");
				while (rs.next()) {

					PreparedStatement queryInsertStmt = conOzbTest
							.prepareStatement(queryInsertGesellschafter);

					queryInsertStmt.setInt(1, rs.getInt("MNR"));

					if (rs.getString("FAStnr") == null
							|| rs.getString("FAStnr").equals("")) {
						queryInsertStmt.setString(2, "###");
					} else {
						queryInsertStmt.setString(2, rs.getString("FAStnr"));
					}

					queryInsertStmt.setInt(3, rs.getInt("FALfdnr"));
					queryInsertStmt.setString(4, rs.getString("FAIdnr"));

					if (rs.getString("WohnsitzFA") == null
							|| rs.getString("WohnsitzFA").equals("")) {
						queryInsertStmt.setString(5, "###");
					} else {
						queryInsertStmt
								.setString(5, rs.getString("WohnsitzFA"));
					}

					queryInsertStmt.setTimestamp(6, new java.sql.Timestamp(
							calendar.getTime().getTime() - 1 * 24 * 60 * 60
									* 1000));
					queryInsertStmt.setTimestamp(7, endOfTime);
					try {
						queryInsertStmt.executeUpdate();
					} catch (SQLException e) {
						pw.println("Gesellschafter : " + " MNR: "
								+ rs.getInt("MNR") + " " + e.getMessage());
						pw.println("SQL-Query: " + queryInsertStmt.toString());
						pw.println("");
					}

				}

				// Student

				rs = stOzbProd
						.executeQuery(" SELECT `MNR` FROM Mitglied WHERE GM='S' ");
				while (rs.next()) {

					PreparedStatement queryInsertStmt = conOzbTest
							.prepareStatement(queryInsertStudent);

					queryInsertStmt.setInt(1, rs.getInt("MNR"));
					queryInsertStmt.setTimestamp(2, new java.sql.Timestamp(
							calendar.getTime().getTime() - 1 * 24 * 60 * 60
									* 1000));
					queryInsertStmt.setTimestamp(3, endOfTime);
					
					String dummyString = "###";
					Date dummyDate = new Date(endCalender.getTime().getTime());
							
					//Keine Daten vorhanden
					//AusbildBez.
					queryInsertStmt.setString(4, dummyString);
					//InstitutName
					queryInsertStmt.setString(5, dummyString);
					//Studienort
					queryInsertStmt.setString(6, dummyString);
					//Studienbeginn
					queryInsertStmt.setDate(7, dummyDate);
					//Studienende
					queryInsertStmt.setDate(8, dummyDate);
					//Abschluss
					queryInsertStmt.setString(9, dummyString);
					
					try {
						queryInsertStmt.executeUpdate();
					} catch (SQLException e) {
						pw.println("Student : " + " MNR: " + rs.getInt("MNR")
								+ " " + e.getMessage());
						pw.println("SQL-Query: " + queryInsertStmt.toString());
						pw.println("");
					}

				}
				// Foerdermitglied

				rs = stOzbTest
						.executeQuery(" SELECT `Pnr` FROM person WHERE Rolle='F' ");
				while (rs.next()) {

					PreparedStatement queryInsertStmt = conOzbTest
							.prepareStatement(queryInsertFoerdermitglied);

					queryInsertStmt.setInt(1, rs.getInt("Pnr"));
					queryInsertStmt.setTimestamp(2, new java.sql.Timestamp(
							calendar.getTime().getTime() - 1 * 24 * 60 * 60
									* 1000));
					queryInsertStmt.setTimestamp(3, endOfTime);

					// Region,Foerderbeitrag,MJ
					// TODO
					queryInsertStmt.setString(4, "###");
					queryInsertStmt.setInt(5, -1);
					queryInsertStmt.setString(6, "m");

					try {
						queryInsertStmt.executeUpdate();
					} catch (SQLException e) {
						pw.println("Foerdermitglied : " + " Pnr: "
								+ rs.getInt("Pnr") + " " + e.getMessage());
						pw.println("SQL-Query: " + queryInsertStmt.toString());
						pw.println("");
					}

				}
				// Veranstaltungsart
				rs = stOzbProd
						.executeQuery("SELECT `Vanr`,`VABezeichnung` FROM `Veranstaltungsart`");
				while (rs.next()) {
					PreparedStatement queryInsertStmt = conOzbTest
							.prepareStatement(queryInsertVeranstalltungart);

					queryInsertStmt.setInt(1, rs.getInt("Vanr"));
					queryInsertStmt.setString(2, rs.getString("VABezeichnung"));
					try {
						queryInsertStmt.executeUpdate();
					} catch (SQLException e) {
						pw.println("Veranstaltungsart : " + " Vnr: "
								+ rs.getInt("Vanr") + " " + e.getMessage());
						pw.println("SQL-Query: " + queryInsertStmt.toString());
						pw.println("");
					}

				}
				// Veranstaltung
				rs = stOzbProd
						.executeQuery("SELECT `Vnr`,`Vanr`,`VADatum`,`VAOrt` FROM `Veranstaltung`");
				while (rs.next()) {
					PreparedStatement queryInsertStmt = conOzbTest
							.prepareStatement(queryInsertVeranstalltung);

					queryInsertStmt.setInt(1, rs.getInt("Vnr"));
					queryInsertStmt.setInt(2, rs.getInt("Vanr"));
					queryInsertStmt.setDate(3, rs.getDate("VADatum"));
					queryInsertStmt.setString(4, rs.getString("VAOrt"));
					try {
						queryInsertStmt.executeUpdate();
					} catch (SQLException e) {
						pw.println("Veranstaltung : " + " Vnr: "
								+ rs.getInt("Vnr") + " " + e.getMessage());
						pw.println("SQL-Query: " + queryInsertStmt.toString());
						pw.println("");
					}
				}

				// Teilnahme
				rs = stOzbProd
						.executeQuery("SELECT `Mnr`,`Vnr`,`TeilnArt` FROM `Teilnahme`");
				while (rs.next()) {
					PreparedStatement queryInsertStmt = conOzbTest
							.prepareStatement(queryInsertTeilnahme);

					queryInsertStmt.setInt(1, rs.getInt("Mnr"));
					queryInsertStmt.setInt(2, rs.getInt("Vnr"));
					queryInsertStmt.setString(3, rs.getString("TeilnArt"));
					try {
						queryInsertStmt.executeUpdate();
					} catch (SQLException e) {
						pw.println("Teilnahme : " + " Vnr: " + rs.getInt("Vnr")
								+ " Mnr: " + rs.getInt("Mnr") + " "
								+ e.getMessage());
						pw.println("SQL-Query: " + queryInsertStmt.toString());
						pw.println("");
					}
				}

				// Partner
				rs = stOzbProd
						.executeQuery(" SELECT `MNR`,`MNR_P`,`AUT` FROM PartnerMitglied");
				while (rs.next()) {

					PreparedStatement queryInsertStmt = conOzbTest
							.prepareStatement(queryInsertPartner);

					queryInsertStmt.setInt(1, rs.getInt("MNR"));
					queryInsertStmt.setInt(2, rs.getInt("MNR_P"));

					/*
					-- Partner: Berechtigungen in der ozb_prod: i, j, n, l
					-- unsere neuen Berechtigungen: l = leseberechtigt, v = vollberechtigt
					-- Wie sollen die Daten f�r die Migration angepasst werden?
					-> alles auf l setzen. �nderungen k�nnen nach der Migration manuell gemacht werden
					*/
					queryInsertStmt.setString(3, "l");

					queryInsertStmt.setTimestamp(4, new java.sql.Timestamp(
							calendar.getTime().getTime() - 1 * 24 * 60 * 60
									* 1000));
					queryInsertStmt.setTimestamp(5, endOfTime);
					try {
						queryInsertStmt.executeUpdate();
					} catch (SQLException e) {
						pw.println("Partner : " + " MNR: " + rs.getInt("MNR")
								+ " " + e.getMessage());
						pw.println("SQL-Query: " + queryInsertStmt.toString());
						pw.println("");
					}

				}

				// Telefon
				rs = stOzbProd
						.executeQuery("SELECT Telefon.MNR,`LFD-Nr`,Telefon.TELNr,Telefon.TELTYP FROM Telefon,Mitglied where Telefon.MNR=Mitglied.MNR; ");
				while (rs.next()) {

					PreparedStatement queryInsertStmt = conOzbTest
							.prepareStatement(queryInsertTelefon);

					queryInsertStmt.setInt(1, rs.getInt("MNR"));
					queryInsertStmt.setInt(2, rs.getInt("LFD-Nr"));
					queryInsertStmt.setString(3, rs.getString("TELNr"));
					
					/*
					-- Telefon: es gibt unterschiedliche Telefontypen zu unseren Definitionen
					-- Alle per Default auf "tel" stellen?
					-> Es gibt in ozb_prod nur noch b�ro und gesch
					-> Vorschlag: Typ gesch in Tabelle Telefon in ozb_test erg�nzen und b�ro und gesch diesem Typ zuordnen 
					*/
					String teltyp = rs.getString("TELTYP").toLowerCase().trim();
					if ( teltyp.equals("b�ro") || teltyp.equals("gesch") )
						queryInsertStmt.setString(4, "gesch");
					else if ( teltyp.equals("fax"))
						queryInsertStmt.setString(4, "fax");
					else if ( teltyp.equals("mob"))
						queryInsertStmt.setString(4, "mob");
					else if ( teltyp.equals("tel") || teltyp.equals("priv"))
						queryInsertStmt.setString(4, "tel");

					try {
						queryInsertStmt.executeUpdate();
					} catch (SQLException e) {
						pw.println("Telefon : " + " MNR: " + rs.getInt("MNR")
								+ " " + e.getMessage());
						pw.println("SQL-Query: " + queryInsertStmt.toString());
						pw.println("");
					}

				}
				// Tanliste
				rs = stOzbProd
						.executeQuery("SELECT MNR, LISTID, STATUS FROM Tanliste ; ");
				while (rs.next()) {

					PreparedStatement queryInsertStmt = conOzbTest
							.prepareStatement(queryInsertTanliste);

					queryInsertStmt.setInt(1, rs.getInt("MNR"));
					queryInsertStmt.setInt(2, rs.getInt("LISTID"));
					queryInsertStmt.setString(3, rs.getString("STATUS"));

					// TanlistDatum
					// Aktuelles Datum des Migrationsdatum verwenden					
					java.util.Date date = new java.util.Date();					 
			        java.sql.Date tanlistDate = new java.sql.Date(date.getTime());
			        queryInsertStmt.setDate(4, tanlistDate);
			        
					try {
						queryInsertStmt.executeUpdate();
					} catch (SQLException e) {
						pw.println("Tanliste : " + " MNR: " + rs.getInt("MNR")
								+ " " + e.getMessage());
						pw.println("SQL-Query: " + queryInsertStmt.toString());
						pw.println("");
					}

				}

				// Tan
				rs = stOzbProd
						.executeQuery("SELECT MNR, LISTID,TANID,TAN,VERW_DATUM, STATUS FROM Tan ; ");
				while (rs.next()) {

					PreparedStatement queryInsertStmt = conOzbTest
							.prepareStatement(queryInsertTan);

					queryInsertStmt.setInt(1, rs.getInt("MNR"));
					queryInsertStmt.setInt(2, rs.getInt("LISTID"));
					queryInsertStmt.setInt(3, rs.getInt("TANID"));
					queryInsertStmt.setInt(4, rs.getInt("TAN"));
					queryInsertStmt.setDate(5, rs.getDate("VERW_DATUM"));
					queryInsertStmt.setString(6, rs.getString("STATUS"));

					try {
						queryInsertStmt.executeUpdate();
					} catch (SQLException e) {
						pw.println("Tan : " + " MNR: " + rs.getInt("MNR") + " "
								+ e.getMessage());
						pw.println("SQL-Query: " + queryInsertStmt.toString());
						pw.println("");
					}

				}

				// Bank
				rs = stOzbProd
						.executeQuery("SELECT `BLZ`,`BANK` FROM `Mitglied` WHERE BLZ is not null GROUP By BLZ");
				
				boolean dummyBankInserted = false;
				
				while (rs.next()) {
					PreparedStatement queryInsertStmt = conOzbTest
							.prepareStatement(queryInsertBank);
					queryInsertStmt.setString(2, rs.getString("BANK"));
					try {
						queryInsertStmt.setInt(1, Integer.parseInt(rs
								.getString("BLZ").replaceAll(" ", "")));
					} catch (Exception e) {
						pw.println("Can't process BLZ" + rs.getString("BLZ")
								+ ", skipping.");
						continue;
					}
					try {
						//Dummy Bank fuer Dummy Bankverbindung hinzufuegen
						if (!dummyBankInserted) {
							PreparedStatement queryDummyInsertStmt = conOzbTest
									.prepareStatement(queryInsertBank);
							queryDummyInsertStmt.setInt(1, 00000000);
							queryDummyInsertStmt.setString(2, "DUMMY BANK");
							
							queryDummyInsertStmt.execute();
							
							dummyBankInserted = true;
						}
						
						queryInsertStmt.executeUpdate();
					} catch (SQLException e) {
						// pw.println("Bank : " + " BLZ: "
						// + rs.getString("BLZ") + " " + e.getMessage());
						// pw.println("SQL-Query: " +
						// queryInsertStmt.toString());
						// pw.println("");
					}

				}

				// Bankverbindung
				rs = stOzbProd
						.executeQuery("select MNR,BANKKONTONR, BLZ from Mitglied WHERE BLZ is not null");
				
				boolean dummyBankverbindungInserted = false;

				while (rs.next()) {

					PreparedStatement queryInsertStmt = conOzbTest
							.prepareStatement(queryInsertBankverbindung);

					queryInsertStmt.setInt(1, rs.getInt("MNR"));
					queryInsertStmt.setString(2, rs.getString("BANKKONTONR"));
					try {
						queryInsertStmt.setInt(3, Integer.parseInt(rs
								.getString("BLZ").replaceAll(" ", "")));
					} catch (Exception e) {
						pw.println("Can't process BLZ" + rs.getString("BLZ")
								+ ", skipping.");
						continue;
					}
					queryInsertStmt.setTimestamp(4, new java.sql.Timestamp(
							calendar.getTime().getTime() - 1 * 24 * 60 * 60
									* 1000));
					queryInsertStmt.setTimestamp(5, endOfTime);

					queryInsertStmt.setString(6, "###");

					try {
						//Dummy Bankkonto fuer EEKonto ohne BankID
						if(!dummyBankverbindungInserted) {
							PreparedStatement queryDummyInsertStmt = conOzbTest
									.prepareStatement(queryInsertBankverbindung);
							
							queryDummyInsertStmt.setInt(1, 13);
							queryDummyInsertStmt.setString(2, "DUMMY");
							queryDummyInsertStmt.setInt(3, 00000000);
							queryDummyInsertStmt.setTimestamp(4, new java.sql.Timestamp(
									calendar.getTime().getTime() - 1 * 24 * 60 * 60
											* 1000));
							queryDummyInsertStmt.setTimestamp(5, endOfTime);
							queryDummyInsertStmt.setString(6, "###");
		
							queryDummyInsertStmt.execute();
							
							dummyBankverbindungInserted = true;
						}
						
						queryInsertStmt.executeUpdate();
					} catch (SQLException e) {
						pw.println("Bankverbindung : " + " MNR: "
								+ rs.getInt("MNR") + " " + e.getMessage());
						pw.println("SQL-Query: " + queryInsertStmt.toString());
						pw.println("");
					}

				}

				// TODO
				// Waehrung
				// Die Tabelle muss mit den gefundenen Waehrungen gef�llt
				// werden. (STR, CAR
				// NGD, EUR, PFR).
				// Ich hau jetzt mal was rein Micha, schau dir das bitte nochmal
				// an ;)
				String queryInsertWaehrungStmt = "INSERT INTO waehrung (Code,Bezeichnung) VALUES (?,?);";
				PreparedStatement queryWaehrungInsertStmt = null;
				/*
				 * "INSERT INTO waehrung (Code,Bezeichnung) VALUES ('STR', 'Stuttgarter');"
				 * "INSERT INTO waehrung (Code,Bezeichnung) VALUES ('CAR', '###');"
				 * +
				 * "INSERT INTO waehrung (Code,Bezeichnung) VALUES ('NGD', '###');"
				 * +
				 * "INSERT INTO waehrung (Code,Bezeichnung) VALUES ('EUR', 'Europ');"
				 * +
				 * "INSERT INTO waehrung (Code,Bezeichnung) VALUES ('PFR', 'Pforzheimer');"
				 * ;
				 */
				try {
					queryWaehrungInsertStmt = conOzbTest
							.prepareStatement(queryInsertWaehrungStmt);
					queryWaehrungInsertStmt.setString(1, "STR");
					queryWaehrungInsertStmt.setString(2, "Stuttgarter");
					queryWaehrungInsertStmt.executeUpdate();

					queryWaehrungInsertStmt = conOzbTest
							.prepareStatement(queryInsertWaehrungStmt);
					queryWaehrungInsertStmt.setString(1, "CAR");
					queryWaehrungInsertStmt.setString(2, "###");
					queryWaehrungInsertStmt.executeUpdate();

					queryWaehrungInsertStmt = conOzbTest
							.prepareStatement(queryInsertWaehrungStmt);
					queryWaehrungInsertStmt.setString(1, "NGD");
					queryWaehrungInsertStmt.setString(2, "###");
					queryWaehrungInsertStmt.executeUpdate();

					queryWaehrungInsertStmt = conOzbTest
							.prepareStatement(queryInsertWaehrungStmt);
					queryWaehrungInsertStmt.setString(1, "EUR");
					queryWaehrungInsertStmt.setString(2, "Euro");
					queryWaehrungInsertStmt.executeUpdate();

					queryWaehrungInsertStmt = conOzbTest
							.prepareStatement(queryInsertWaehrungStmt);
					queryWaehrungInsertStmt.setString(1, "PFR");
					queryWaehrungInsertStmt.setString(2, "Pforzheimer");
					queryWaehrungInsertStmt.executeUpdate();
				} catch (SQLException e) {
					pw.println("Waehrung : " + e.getMessage());
					pw.println("SQL-Query: "
							+ queryWaehrungInsertStmt.toString());
					pw.println("");
				}

				String queryInsertOZBKonto = "INSERT INTO ozbkonto (KtoNr,Mnr,KtoEinrDatum,WaehrungID,WSaldo,PSaldo,SaldoDatum,GueltigVon,GueltigBis) VALUES (?,?,?,?,?,?,?,?,?);";
				// OZBKonto 1
				rs = stOzbProd
						.executeQuery("SELECT KTONR,MNR,KTOEINRDAT,WHRG,W_SALDO,PKTESALDO,SALDODAT FROM Konto; ");
				while (rs.next()) {

					PreparedStatement queryInsertStmt = conOzbTest
							.prepareStatement(queryInsertOZBKonto);

					queryInsertStmt.setInt(1, rs.getInt("KTONR"));
					queryInsertStmt.setInt(2, rs.getInt("MNR"));
					queryInsertStmt.setDate(3, rs.getDate("KTOEINRDAT"));
					queryInsertStmt.setString(4, rs.getString("WHRG"));
					queryInsertStmt.setBigDecimal(5,
							rs.getBigDecimal("W_SALDO"));
					queryInsertStmt.setInt(6, rs.getInt("PKTESALDO"));
					queryInsertStmt.setDate(7, rs.getDate("SALDODAT"));
					queryInsertStmt.setTimestamp(8, new java.sql.Timestamp(
							calendar.getTime().getTime() - 1 * 24 * 60 * 60
									* 1000));
					queryInsertStmt.setTimestamp(9, endOfTime);
					try {
						queryInsertStmt.executeUpdate();
					} catch (SQLException e) {
						pw.println("OZBKonto (1) : " + " KTONR: "
								+ rs.getInt("KTONR") + " " + e.getMessage());
						pw.println("SQL-Query: " + queryInsertStmt.toString());
						pw.println("");
					}

				}

				// OZBKonto 2
				rs = stOzbProd
						.executeQuery("select KTONR, MNR, STATUS, DARLDAT, ENDDAT, WHRG,DARL_SALDO, PKTESALDO, SALDODAT from Darlehen; ");
				while (rs.next()) {

					PreparedStatement queryInsertStmt = conOzbTest
							.prepareStatement(queryInsertOZBKonto);

					queryInsertStmt.setInt(1, rs.getInt("KTONR"));
					queryInsertStmt.setInt(2, rs.getInt("MNR"));

					try {
						Date date = rs.getDate("DARLDAT");
						if (date.getDate() <= 7)
							date.setDate(1);
						else
							date.setDate(date.getDate() - 7);
						queryInsertStmt.setDate(3, date);
					} catch (Exception e) {

						queryInsertStmt.setNull(3, java.sql.Types.DATE);
					}

					queryInsertStmt.setString(4, rs.getString("WHRG"));
					queryInsertStmt.setBigDecimal(5,
							rs.getBigDecimal("DARL_SALDO"));
					queryInsertStmt.setInt(6, rs.getInt("PKTESALDO"));
					queryInsertStmt.setDate(7, rs.getDate("SALDODAT"));
					
					/* Bei der Migration sollte historisiert werden. F�r Status=E:  GueltigVon=DARLDAT und GueltigBis=ENDDAT
					F�r Status=A sollte eigentlich in GueltiVon nicht das Datum der Migration, sondern das DARLDAT, also das Beginndatum des Darlehens stehen 
					*/
					Date darldat = rs.getDate("DARLDAT");						
					queryInsertStmt.setTimestamp(8, new java.sql.Timestamp(darldat.getTime()));
					
					if ( rs.getString("STATUS").equals("E") ) {
						Date enddat = rs.getDate("ENDDAT");
						if (enddat != null)
							queryInsertStmt.setTimestamp(9, new java.sql.Timestamp(enddat.getTime()));
						else
							queryInsertStmt.setTimestamp(9, endOfTime);
					} else {
						queryInsertStmt.setTimestamp(9, endOfTime);
					}
					
					try {
						queryInsertStmt.executeUpdate();
					} catch (SQLException e) {
						pw.println("OZBKonto (2) : " + " KTONR: "
								+ rs.getInt("KTONR") + " " + e.getMessage());
						pw.println("SQL-Query: " + queryInsertStmt.toString());
						pw.println("");
					}

				}

				// EEKonto Temp
				rs = stOzbProd
						.executeQuery("SELECT k.KTONR, k.`LIMIT`, m.`BANKKONTONR`,m.BLZ,m.BANK FROM Konto k join Mitglied m on m.MNR = k.MNR; ");
				while (rs.next()) {

					PreparedStatement queryInsertStmt = conOzbTest
							.prepareStatement(queryInsertTemp);

					queryInsertStmt.setInt(1, rs.getInt("KTONR"));
					queryInsertStmt.setBigDecimal(2, rs.getBigDecimal("LIMIT"));
					queryInsertStmt.setString(3, rs.getString("BANKKONTONR"));

					try {
						queryInsertStmt.setInt(4, Integer.parseInt(rs
								.getString("BLZ").replaceAll(" ", "")));
					} catch (Exception e) {
						queryInsertStmt.setNull(4, java.sql.Types.INTEGER);
					}

					queryInsertStmt.setString(5, rs.getString("BANK"));

					try {
						queryInsertStmt.executeUpdate();
					} catch (SQLException e) {
						pw.println("EEKonto Temp : " + " KTONR: "
								+ rs.getInt("KTONR") + " " + e.getMessage());
						pw.println("SQL-Query: " + queryInsertStmt.toString());
						pw.println("");
					}
				}
				// EEKonto
				rs = stOzbTest
						.executeQuery("select T.KtoNr, max(T.ID) ID,T.Kreditlimit from "
								+ "(select Temp.KtoNr, Bankverbindung.ID, Temp.Kreditlimit from temp as Temp, bankverbindung as Bankverbindung join bank as Bank on Bank.BLZ = Bankverbindung.BLZ "
								+ "where (Temp.BankKtoNr=Bankverbindung.BankKtoNr and Temp.BLZ=Bankverbindung.BLZ) "
								+ "or (Temp.BankKtoNr=Bankverbindung.BankKtoNr and Temp.BankName=Bank.BankName) "
								+ "union "
								+ "select Temp.KtoNr, NULL, Temp.Kreditlimit from temp as Temp) T "
								+ "group by T.KtoNr");
				while (rs.next()) {

					PreparedStatement queryInsertStmt = conOzbTest
							.prepareStatement(queryInsertEEKonto);

					queryInsertStmt.setInt(1, rs.getInt("KtoNr"));
					if (rs.getInt("ID") == 0) {
						/*
						-- EEKonto: Wie sieht der Vorgang aus, wenn zu alten Daten keine BankID zugeordnet werden kann? Dummy-Datensatz?
						-> Das Migrationsprogramm sollte nur die Bankverbindungen �bernehmen, die der Tabelle Mitglied stehen.
						-> Die Bankverbindungen in Tabelle Konto werden nicht migriert
						-> In Tabelle EEKonto wird immer die BankID eingetragen, die zu der Bankverbindung dieses Mitglieds geh�rt
						-> Derzeit sind in Tabelle Mitglied f�r die meisten neuen Mitglieder/Gesellschaftern noch keine Bankverbindungen eingetragen und
						-> es wurden eine ganze Reihe von Bankverbindungen von ausgeschiedenen Mitgliedern/Gesellschaftern auf NULL zur�ck gesetzt
						-> keine Ahnung, wer das gemacht hat
						-> Daher: Alle einer Dummy-BLZ, z.B. 00000000 zuordnen. Korrektur sp�ter nach der Migration manuell
						*/
						// 1 setzen fuer manuelle nachbearbeitung, mit dummy bankverbindung
						queryInsertStmt.setInt(2, 1);
					} else {
						queryInsertStmt.setInt(2, rs.getInt("ID"));
					}
					queryInsertStmt.setBigDecimal(3,
							rs.getBigDecimal("Kreditlimit"));
					queryInsertStmt.setTimestamp(4, new java.sql.Timestamp(
							calendar.getTime().getTime() - 1 * 24 * 60 * 60
									* 1000));
					queryInsertStmt.setTimestamp(5, endOfTime);
					try {
						queryInsertStmt.executeUpdate();
					} catch (SQLException e) {
						pw.println("EEKonto : " + " KtoNr: "
								+ rs.getInt("KtoNr") + " " + e.getMessage());
						pw.println("SQL-Query: " + queryInsertStmt.toString());
						pw.println("");
					}

				}

				// Projektgruppe
				rs = stOzbProd
						.executeQuery("SELECT PGNR, ProjektGruppBez FROM Projektgruppe ; ");
				while (rs.next()) {

					PreparedStatement queryInsertStmt = conOzbTest
							.prepareStatement(queryInsertProjektgruppe);

					queryInsertStmt.setInt(1, rs.getInt("PGNR"));
					queryInsertStmt.setString(2,
							rs.getString("ProjektGruppBez"));

					try {
						queryInsertStmt.executeUpdate();
					} catch (SQLException e) {
						pw.println("Projektgruppe : " + " PGNR: "
								+ rs.getInt("PGNR") + " " + e.getMessage());
						pw.println("SQL-Query: " + queryInsertStmt.toString());
						pw.println("");
					}

				}

				// ZEKonto
				rs = stOzbProd
						.executeQuery("SELECT KTONR,`E-KTONR`,PGNR,DARLNR,DARLDAT,ENDDAT,DARLBETRAG,LAUFZEIT,ZAHLMODUS,TILG_RATE,NSPAR_RATE,KDU,RDU,STATUS,KALK_LEIHPUNKTE,TATS_LEIHPUNKTE,Sicherung FROM Darlehen ; ");
				while (rs.next()) {

					PreparedStatement queryInsertStmt = conOzbTest
							.prepareStatement(queryInsertZEKonto);

					queryInsertStmt.setInt(1, rs.getInt("KTONR"));
					queryInsertStmt.setInt(2, rs.getInt("E-KTONR"));
					queryInsertStmt.setInt(3, rs.getInt("PGNR"));
					queryInsertStmt.setString(4, rs.getString("DARLNR"));
					queryInsertStmt.setDate(5, rs.getDate("DARLDAT"));

					/*
					-- ZEKonto: Wenn das Enddatum nicht gesetzt ist (null), wie fortfahren?
					->             ZEEndDatum auf '9999-12-31' setzen
					*/
					if (rs.getDate("ENDDAT") == null) {
						queryInsertStmt.setString(6, "9999-12-31");
					} else {
						queryInsertStmt.setDate(6, rs.getDate("ENDDAT"));
					}

					queryInsertStmt.setBigDecimal(7,
							rs.getBigDecimal("DARLBETRAG"));
					queryInsertStmt.setInt(8, rs.getInt("LAUFZEIT"));
					/*
					--			Wenn Zahlmodus = null, welchen Wert setzen?
					->             ZahlModus auf Default m setzen
					*/
					if (rs.getString("ZAHLMODUS") == null
							|| rs.getString("ZAHLMODUS").equals("")) {
						queryInsertStmt.setString(9, "m"); 
					} else {
						queryInsertStmt.setString(9, rs.getString("ZAHLMODUS"));
					}

					queryInsertStmt.setBigDecimal(10,
							rs.getBigDecimal("TILG_RATE"));
					queryInsertStmt.setBigDecimal(11,
							rs.getBigDecimal("NSPAR_RATE"));
					queryInsertStmt.setBigDecimal(12, rs.getBigDecimal("KDU"));
					queryInsertStmt.setBigDecimal(13, rs.getBigDecimal("RDU"));
					queryInsertStmt.setString(14, rs.getString("STATUS"));
					queryInsertStmt.setTimestamp(15, new java.sql.Timestamp(rs.getDate("DARLDAT").getTime()));
					
					if ( rs.getString("STATUS").equals("E") ) {
						Date enddat = rs.getDate("ENDDAT");
						if (enddat != null)
							queryInsertStmt.setTimestamp(16, new java.sql.Timestamp(enddat.getTime()));
						else
							queryInsertStmt.setTimestamp(16, endOfTime);
					} else {
						queryInsertStmt.setTimestamp(16, endOfTime);
					}
					
					queryInsertStmt.setTimestamp(16, endOfTime);
					queryInsertStmt.setInt(17, rs.getInt("KALK_LEIHPUNKTE"));
					queryInsertStmt.setInt(18, rs.getInt("TATS_LEIHPUNKTE"));
					queryInsertStmt.setString(19, rs.getString("Sicherung"));
					try {
						queryInsertStmt.executeUpdate();
					} catch (SQLException e) {
						pw.println("ZEKonto : " + " KTONR: "
								+ rs.getInt("KTONR") + " " + e.getMessage());
						pw.println("SQL-Query: " + queryInsertStmt.toString());
						pw.println("");
					}

				}

				// Buergschaft

				rs = stOzbProd
						.executeQuery("SELECT MNR_B,MNR_G,Darlehen.KTONR,ZE_NR, SICH_AB_DAT,SICH_BIS_DAT,SICH_BETRAG,SICH_BEZ  FROM Buergschaft,Darlehen WHERE Buergschaft.ze_nr=Darlehen.darlnr ;");
				while (rs.next()) {

					PreparedStatement queryInsertStmt = conOzbTest
							.prepareStatement(queryInsertBuergschaft);

					queryInsertStmt.setInt(1, rs.getInt("MNR_B"));
					queryInsertStmt.setInt(2, rs.getInt("MNR_G"));
					queryInsertStmt.setString(3, rs.getString("ZE_NR"));
					queryInsertStmt.setDate(4, rs.getDate("SICH_AB_DAT"));
					/*
					-- Buergschaft: Wenn das Enddatum nicht gesetzt ist (null), wie fortfahren?
					-> Kann so bleiben, wie es jetzt ist: 9999-01-01
					*/
					if (rs.getDate("SICH_BIS_DAT") == null) {
						queryInsertStmt.setString(5, "9999-01-01");
					} else {
						queryInsertStmt.setDate(5, rs.getDate("SICH_BIS_DAT"));
					}

					queryInsertStmt.setBigDecimal(6,
							rs.getBigDecimal("SICH_BETRAG"));
					queryInsertStmt.setString(7, rs.getString("SICH_BEZ"));
					queryInsertStmt.setTimestamp(8, new java.sql.Timestamp(
							calendar.getTime().getTime() - 1 * 24 * 60 * 60
									* 1000));
					queryInsertStmt.setTimestamp(9, endOfTime);
					try {
						queryInsertStmt.executeUpdate();
					} catch (SQLException e) {
						pw.println("Buergschaft : " + " MNR_B: "
								+ rs.getInt("MNR_B") + " " + e.getMessage());
						pw.println("SQL-Query: " + queryInsertStmt.toString());
						pw.println("");
					}

				}
				// Kontenklasse
				rs = stOzbProd
						.executeQuery("SELECT KKL, `KKL-ABDAT`,`KKL%` FROM Kontenklasse ; ");
				while (rs.next()) {

					PreparedStatement queryInsertStmt = conOzbTest
							.prepareStatement(queryInsertKontenklasse);

					queryInsertStmt.setString(1, rs.getString("KKL"));
					queryInsertStmt.setDate(2, rs.getDate("KKL-ABDAT"));
					queryInsertStmt.setBigDecimal(3, rs.getBigDecimal("KKL%"));

					try {
						queryInsertStmt.executeUpdate();
					} catch (SQLException e) {
						pw.println("Kontenklasse : " + " KKL: "
								+ rs.getString("KKL") + " " + e.getMessage());
						pw.println("SQL-Query: " + queryInsertStmt.toString());
						pw.println("");
					}

				}

				// KKLVerlauf
				rs = stOzbProd
						.executeQuery("SELECT `KTONR`, `KKL-ABDAT`, `KKL` FROM `KKL-Verlauf` ; ");
				while (rs.next()) {

					PreparedStatement queryInsertStmt = conOzbTest
							.prepareStatement(queryInsertKKLVerlauf);

					queryInsertStmt.setInt(1, rs.getInt("KTONR"));
					queryInsertStmt.setDate(2, rs.getDate("KKL-ABDAT"));
					queryInsertStmt.setString(3, rs.getString("KKL"));

					try {
						queryInsertStmt.executeUpdate();
					} catch (SQLException e) {
						pw.println("KKLVerlauf : " + " KTONR: "
								+ rs.getInt("KTONR") + " " + e.getMessage());
						pw.println("SQL-Query: " + queryInsertStmt.toString());
						pw.println("");
					}

				}
				
				
				String queryInsertBuchung = "INSERT INTO buchung (BuchJahr,KtoNr,BnKreis,BelegNr,Typ,Belegdatum,BuchDatum,Buchungstext,Sollbetrag,Habenbetrag,SollKtoNr,HabenKtoNr,WSaldoAcc,Punkte,PSaldoAcc) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
				
				// Buchung
				rs = stOzbProd
						.executeQuery("SELECT JAHR,KONTONR,BNKREIS,BELEGNR,TYP,BUCHUNGSDAT,WERTDAT,BUCHUNGSTEXT,SOLLBETRAG,HABENBETRAG,SOLLKTONR,HABENKTONR,SALDO_ACC,PKTE,PKTE_ACC FROM `Buchung` ; ");
				while (rs.next()) {
					PreparedStatement queryInsertStmt = conOzbTest
							.prepareStatement(queryInsertBuchung);

					queryInsertStmt.setInt(1, rs.getInt("JAHR"));
					queryInsertStmt.setInt(2, rs.getInt("KONTONR"));
					queryInsertStmt.setString(3, rs.getString("BNKREIS"));
					queryInsertStmt.setInt(4, rs.getInt("BELEGNR"));
					queryInsertStmt.setString(5, rs.getString("TYP"));
					queryInsertStmt.setDate(6, rs.getDate("BUCHUNGSDAT"));
					queryInsertStmt.setDate(7, rs.getDate("WERTDAT"));
					queryInsertStmt.setString(8, rs.getString("BUCHUNGSTEXT"));
					queryInsertStmt.setBigDecimal(9,
							rs.getBigDecimal("SOLLBETRAG"));
					queryInsertStmt.setBigDecimal(10,
							rs.getBigDecimal("HABENBETRAG"));
					queryInsertStmt.setInt(11, rs.getInt("SOLLKTONR"));
					queryInsertStmt.setInt(12, rs.getInt("HABENKTONR"));
					queryInsertStmt.setBigDecimal(13,
							rs.getBigDecimal("SALDO_ACC"));

					// Vertauscht, da in der Produktivdatenbank schon falsch
					// benannt wurde (Punkte -> PSaldoACC)
					queryInsertStmt.setInt(14, rs.getInt("PKTE_ACC"));
					queryInsertStmt.setInt(15, rs.getInt("PKTE"));
					
					try {
						queryInsertStmt.executeUpdate();
						
					} catch (SQLException e) {
						pw.println("Buchung : " + " KONTONR: "
								+ rs.getInt("KONTONR") + " " + e.getMessage());
						pw.println("SQL-Query: " + queryInsertStmt.toString());
						pw.println("");
					}

				}
				stOzbTest
						.executeUpdate("INSERT INTO `geschaeftsprozess` (`ID`, `Beschreibung`, `IT`, `MV`, `RW`, `ZE`, `OeA`) VALUES (1, 'Alle Mitglieder anzeigen', 1, 1, 1, 1, 1),(2, 'Details einer Person anzeigen', 1, 1, 1, 1, 1),(3, 'Mitglieder hinzufuegen', 1, 1, 0, 0, 0),(5, 'Mitglieder loeschen', 1, 1, 0, 0, 0),(6, 'Rolle eines Mitglieds zum Gesellschafter aendern', 1, 1, 0, 0, 0),(7, 'Mitglied Administratorrechte hinzufuegen', 1, 0, 0, 0, 0),(8, 'Kontenklassen hinzufuegen', 1, 0, 1, 0, 0),(9, 'Kontenklassen bearbeiten', 1, 0, 0, 0, 0),(11, 'Alle Konten anzeigen', 1, 1, 1, 1, 1),(12, 'Details eines Kontos anzeigen', 1, 1, 1, 1, 1),(13, 'Einlage/Entnahmekonten hinzufuegen', 1, 0, 1, 0, 0),(14, 'Einlage/Entnahmekonten bearbeiten', 1, 0, 1, 0, 0),(15, 'Zusatzentnahmekonten hinzufuegen', 1, 0, 1, 0, 0),(17, 'Buergschaften anzeigen', 1, 1, 1, 1, 1),(18, 'Buergschaften hinzufuegen', 1, 0, 0, 1, 0),(19, 'Buergschaften bearbeiten', 1, 0, 0, 1, 0),(20, 'Veranstaltung einsehen/bearbeiten',1,1,0,0,1);");
				/** Loschen der Tabelle temp */
				stOzbTest.executeUpdate("drop table temp");
				
				
				// Users table
				
				// Get OZBPersons
				sql = "SELECT DISTINCT m.MNR, O.UEBER_MNR, m.PASSWORT, m.PW_AENDDAT, m.SPERRKZ, m.ANTRAGSDAT, m.AUFNAHMEDAT, m.AUS_DAT, m.SCHUL_DAT, m.EMAIL "
						+ "FROM Mitglied m, Konto k, "
						+ "(select T.km1 MNR, MAX(T.km2) UEBER_MNR "
						+ "from"
						+ "(SELECT distinct m.MNR km1, m2.MNR km2 "
						+ "FROM Mitglied m, Mitglied m2 "
						+ "WHERE m.UEBER_NAME = m2.NAME AND "
						+ "m.UEBER_VORNAME = m2.VORNAME "
						+ "union "
						+ "SELECT distinct m.MNR km1, NULL km2 "
						+ "FROM Mitglied m) T "
						+ "group by T.km1) O "
						+ "WHERE " + "m.MNR = k.MNR AND " + "O.MNR = m.MNR ";
				rs = stOzbProd
						.executeQuery(sql);
				
				System.out.println("Inserting Users... ");
				// Insert Mnr + Email into users table
				while (rs.next()) {
					int mnr = rs.getInt("MNR");
					System.out.println("Mnr: " + mnr);
					PreparedStatement queryInsertStmt = conOzbTest
							.prepareStatement(queryInsertUser);

					queryInsertStmt.setInt(1, mnr);
					queryInsertStmt.setString(2, rs.getString("EMAIL"));
					
					// Now
					java.util.Date today = new java.util.Date();
					java.sql.Date sqlToday = new java.sql.Date(today.getTime());
					
					queryInsertStmt.setDate(3, sqlToday);
					queryInsertStmt.setDate(4, sqlToday);

					try {
						queryInsertStmt.executeUpdate();
					} catch (SQLException e) {
						pw.println("Users : " + " Mnr: "
								+ rs.getInt("Mnr") + " " + e.getMessage());
						pw.println("SQL-Query: " + queryInsertStmt.toString());
						pw.println("");
					}

				}
				
				conOzbTest.commit();

				conOzbProd.close();
				conOzbTest.close();
			} catch (SQLException e) {
				pw.println("sql: " + e.getMessage());
				e.printStackTrace();
			}
			pw.close();
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		}
	}

	/**
	 * Eine Methode, um die Hausnummer aus einer Zeile zu erhalten
	 * 
	 */
	private static String getNumberFromString(String str) {
		char[] buffer = str.toCharArray();

		for (int i = 0; i < buffer.length; i++) {
			if (Character.isDigit(buffer[i])) {
				return str.substring(i);
			}

		}

		return "";

	}

	/**
	 * Eine Methode, um die Adresse aus einer Zeile zu erhalten
	 * 
	 */
	private static String getStrasseFromString(String str) {
		char[] buffer = str.toCharArray();

		for (int i = 0; i < buffer.length; i++) {
			if (Character.isDigit(buffer[i])) {
				str.substring(0, i);
				return str.substring(0, i);
			}

		}

		return "";

	}
}
