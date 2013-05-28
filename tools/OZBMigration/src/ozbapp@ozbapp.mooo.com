

CREATE TABLE IF NOT EXISTS `person` (
  `Pnr` int(10) unsigned NOT NULL,
  `GueltigVon` datetime NOT NULL,
  `GueltigBis` datetime NOT NULL,
  `Rolle` enum('G','M','P','S','F') DEFAULT NULL,
  `Name` varchar(20) NOT NULL,
  `Vorname` varchar(15) NOT NULL DEFAULT '',
  `Geburtsdatum` date DEFAULT NULL,
  `Email` varchar(40) DEFAULT NULL,
  `SperrKZ` tinyint(2) NOT NULL DEFAULT '0',
  `SachPnr` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (Pnr,GueltigVon)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS `adresse` (
  `Pnr` int(10) unsigned NOT NULL,
  `GueltigVon` datetime NOT NULL,
  `GueltigBis` datetime NOT NULL,
  `Strasse` varchar(50) DEFAULT NULL,
  `Nr` varchar(10) DEFAULT NULL,
  `PLZ` int(5) DEFAULT NULL,
  `Ort` varchar(50)  DEFAULT NULL,
  `SachPnr` int(10) unsigned DEFAULT NULL,
   `Vermerk` varchar(100) DEFAULT NULL,
  PRIMARY KEY (Pnr,GueltigVon)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `ozbperson` (
  `Mnr` int(10) unsigned NOT NULL ,    
  `UeberPnr` int(10) unsigned ,
  `Passwort` varchar(35) DEFAULT NULL,
  `PWAendDatum` date DEFAULT NULL,
  `Antragsdatum` date DEFAULT NULL,
  `Aufnahmedatum` date DEFAULT NULL,
  `Austrittsdatum` date DEFAULT NULL,
  `Schulungsdatum` date DEFAULT NULL,
  `Gesperrt` tinyint(2) NOT NULL DEFAULT '0',
  `SachPnr` int(10) unsigned DEFAULT NULL,
  `encrypted_password` varchar(64) NOT NULL DEFAULT '$2a$10$qGrVqv4bHcfd4Ld649LoS.xIc/gK8GBdSXAS47AQpg1eVhPQL.H7K',
  `reset_password_token` varchar(128) DEFAULT NULL,
  `reset_password_sent_at` datetime DEFAULT NULL,
  `remember_created_at` datetime DEFAULT NULL,
  `sign_in_count` int(10) default 0,
  `current_sign_in_at` datetime DEFAULT NULL,
  `last_sign_in_at` datetime DEFAULT NULL,
  `current_sign_in_ip` varchar(16) DEFAULT NULL,
  `last_sign_in_ip` varchar(16) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (Mnr)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;



CREATE TABLE IF NOT EXISTS `mitglied` (
  `Mnr` int(10) unsigned NOT NULL ,
  `GueltigVon` datetime NOT NULL,
  `GueltigBis` datetime NOT NULL,
  `RVDatum` date default NULL,
  `SachPnr` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (Mnr,GueltigVon)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;



CREATE TABLE IF NOT EXISTS `gesellschafter` (
  `Mnr` int(10) unsigned NOT NULL ,
  `GueltigVon` datetime NOT NULL,
  `GueltigBis` datetime NOT NULL,
  `FALfdNr` char(20),
  `FASteuerNr` char(15),
  `FAIdNr` char(15),
  `Wohnsitzfinanzamt` varchar(50),
  `NotarPnr` int(10) unsigned  ,
  `BeurkDatum` date,
  `SachPnr` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (Mnr,GueltigVon),
  KEY NotarPnr (NotarPnr),
  KEY Mnr (Mnr)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;



CREATE TABLE IF NOT EXISTS `student` (
  `Mnr` int(10) unsigned NOT NULL ,
  `GueltigVon` datetime NOT NULL,
  `GueltigBis` datetime NOT NULL,
  `AusbildBez` varchar(30),
  `InstitutName` varchar(30),
  `Studienort` varchar(30),
  `Studienbeginn` date,
  `Studienende` date,
  `Abschluss` char(20),
  `SachPnr` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (Mnr,GueltigVon)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;



CREATE TABLE IF NOT EXISTS `foerdermitglied` (
  `Pnr` int(10) unsigned NOT NULL ,
  `GueltigVon` datetime NOT NULL,
  `GueltigBis` datetime NOT NULL,
  `Region` varchar(30),
  `Foerderbeitrag` decimal(5,2),
  `SachPnr` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY Pnr (Pnr,GueltigVon)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS `veranstaltungsart` (
  `VANr` int(11) NOT NULL AUTO_INCREMENT,
  `VABezeichnung` varchar(30) COLLATE utf8_unicode_ci DEFAULT NULL,
 
  PRIMARY KEY (VANr)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS `veranstaltung` (
  `Vnr` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `vid` int(11) NOT NULL,
  `VADatum` date NOT NULL,
  `VAOrt` varchar(30) COLLATE utf8_unicode_ci DEFAULT NULL,
  `SachPnr` int(10) unsigned ,
  FOREIGN KEY (vid) REFERENCES veranstaltungsart(VANr),
  PRIMARY KEY (Vnr)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;



CREATE TABLE IF NOT EXISTS `teilnahme` (
  `Pnr` int(10) unsigned NOT NULL ,
  `Vnr` int(5) unsigned NOT NULL ,  
  `TeilnArt` enum ('a','e','u','l', 'm'), 
  `SachPnr` int(10) unsigned,
  PRIMARY KEY (Pnr,Vnr),
  FOREIGN KEY (Vnr) REFERENCES veranstaltung(Vnr),
  KEY Pnr (Pnr) 
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS `partner` (
  `Mnr` int(10) unsigned NOT NULL ,
  `GueltigVon` datetime NOT NULL,
  `GueltigBis` datetime NOT NULL,
  `MnrO` int(10) unsigned NOT NULL ,  
  `Berechtigung` char(1) NOT NULL DEFAULT '1' , 
  `SachPnr` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (Mnr,GueltigVon),
  KEY MnrO (MnrO)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;



CREATE TABLE IF NOT EXISTS `telefon` (
  `Pnr` int(10) unsigned NOT NULL ,
  `LfdNr` tinyint(2) NOT NULL ,
  `TelefonNr` varchar(15)  DEFAULT NULL,  
  `TelefonTyp` char(6) DEFAULT NULL,
  PRIMARY KEY (Pnr,LfdNr)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS `tanliste` (
  `Mnr` int(10) unsigned NOT NULL ,  
  `ListNr` tinyint(2) unsigned NOT NULL ,    
  `Status` enum ('n','d','a'),    
  PRIMARY KEY (Mnr,ListNr)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `tan` (
  `Mnr` int(10) unsigned NOT NULL ,
  `ListNr` tinyint(2) unsigned NOT NULL ,     
  `TanNr` int(10) unsigned NOT NULL ,
  `Tan` int(5) NOT NULL,
  `VerwendetAm` date DEFAULT NULL,  
  `Status` enum ('o','x'),     
  FOREIGN KEY (Mnr, ListNr) REFERENCES tanliste(Mnr, ListNr),
  PRIMARY KEY (Mnr,ListNr,TanNr)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `bank` (
  `BLZ` int(10) unsigned NOT NULL,
  `BIC` char(10),
  `BankName` varchar(35) DEFAULT NULL,      
  PRIMARY KEY (`BLZ`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `bankverbindung` (
  `ID` tinyint(3) NOT NULL AUTO_INCREMENT ,
  `GueltigVon` datetime NOT NULL,
  `GueltigBis` datetime NOT NULL,
  `Pnr` int(10) unsigned NOT NULL ,
  `BankKtoNr`  varchar(12) DEFAULT NULL,
  `IBAN` char(20),
  `BLZ` int(10) unsigned NOT NULL,   
  `SachPnr` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (ID, GueltigVon),
  FOREIGN KEY (BLZ) REFERENCES bank(BLZ)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS `ozbkonto` (
  `KtoNr` int(5) NOT NULL ,
  `GueltigVon` datetime NOT NULL,
  `GueltigBis` datetime NOT NULL,
  `Mnr` int(10) unsigned NOT NULL ,
  `KtoEinrDatum`  date DEFAULT NULL,
  `Waehrung` char(3) NOT NULL DEFAULT 'STR',
  `WSaldo` decimal(10,2) DEFAULT NULL,
  `PSaldo` int(11) DEFAULT NULL,
  `SaldoDatum` date DEFAULT NULL,    
  `SachPnr` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (KtoNr,GueltigVon)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS `eekonto` (
  `KtoNr` int(5) NOT NULL ,
  `GueltigVon` datetime NOT NULL,
  `GueltigBis` datetime NOT NULL,
  `BankID` tinyint(3)  ,
  `Kreditlimit`  decimal(5,2) DEFAULT '0.00', 
  `SachPnr` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (KtoNr,GueltigVon),
  FOREIGN KEY (BankID) REFERENCES bankverbindung(ID)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS `projektgruppe` (
  `Pgnr` tinyint(2) ,
  `ProjGruppenBez` varchar(50) ,          
  PRIMARY KEY (`Pgnr`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='';

CREATE TABLE IF NOT EXISTS `zekonto` (
  `GueltigVon` datetime NOT NULL,
  `GueltigBis` datetime NOT NULL,
  `KtoNr` int(5) NOT NULL ,
  `EEKtoNr` int(5) NOT NULL ,
  `Pgnr`  tinyint(2),
  `ZENr`  char(10) ,  
  `ZEAbDatum` date DEFAULT NULL,
  `ZEEndDatum` date DEFAULT NULL,
  `ZEBetrag` decimal(10,2) DEFAULT NULL,
  `Laufzeit` tinyint(4) NOT NULL,
  `ZahlModus` char(1) DEFAULT 'M',
  `TilgRate` decimal(10,2) NOT NULL DEFAULT '0.00',
  `AnsparRate` decimal(10,2) NOT NULL DEFAULT '0.00',
  `KDURate` decimal(10,2) NOT NULL DEFAULT '0.00',
  `RDURate` decimal(10,2) NOT NULL DEFAULT '0.00',
  `ZEStatus` char(1) NOT NULL DEFAULT 'A', 
  `SachPnr` int(10) unsigned DEFAULT NULL,
  `Kalk_Leihpunkte` int(11) DEFAULT NULL,
  `Tats_Leihpunkte` int(11) DEFAULT NULL,
  `Sicherung` varchar(200) DEFAULT NULL,
  PRIMARY KEY (KtoNr,GueltigVon),
  FOREIGN KEY (Pgnr) REFERENCES projektgruppe(Pgnr),
  KEY EEKtoNr (EEKtoNr)
) ENGINE=InnoDB DEFAULT CHARSET=latin1; 

CREATE TABLE IF NOT EXISTS `buergschaft` (
  `Pnr_B` int(10) unsigned NOT NULL ,
  `Mnr_G` int(10) unsigned NOT NULL ,
  `GueltigVon` datetime NOT NULL,
  `GueltigBis` datetime NOT NULL,
  `ZENr` char(10) NOT NULL ,
  `SichAbDatum`   datetime DEFAULT NULL,
  `SichEndDatum` datetime DEFAULT NULL,
  `SichBetrag` decimal(10,2) DEFAULT NULL,
  `SichKurzbez` varchar(200) DEFAULT NULL,
  `SachPnr` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (Pnr_B,Mnr_G,GueltigVon,SichEndDatum)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `kontenklasse` (
  `KKL` char(1) NOT NULL ,
  `KKLAbDatum` date NOT NULL ,
  `Prozent`  decimal(5,2) NOT NULL DEFAULT '0.00',        
  PRIMARY KEY (KKL)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS `kklverlauf` (
  `KtoNr` int(5) NOT NULL ,
  `KKLAbDatum` date NOT NULL ,
  `KKL`  char(1) NOT NULL , 
  FOREIGN KEY (KKL) REFERENCES kontenklasse(KKL),
  PRIMARY KEY (KtoNr,KKLAbDatum)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `buchung` (
  `BuchJahr` int(4) NOT NULL ,
  `KtoNr` int(5) NOT NULL ,
  `BnKreis`  char(2) NOT NULL , 
  `BelegNr` int(10) unsigned NOT NULL ,
  `Typ`  char(1) NOT NULL ,
  `Belegdatum` date NOT NULL,
  `BuchDatum` date NOT NULL,
  `Buchungstext` varchar(50) NOT NULL DEFAULT '',
  `Sollbetrag` decimal(10,2) DEFAULT NULL,
  `Habenbetrag` decimal(10,2) DEFAULT NULL,
  `SollKtoNr` int(5) unsigned NOT NULL DEFAULT '0',
  `HabenKtoNr` int(5) unsigned NOT NULL DEFAULT '0',
  `WSaldoAcc` decimal(10,2) NOT NULL DEFAULT '0.00',
  `Punkte` int(10) DEFAULT NULL,
  `PSaldoAcc` int(10) NOT NULL DEFAULT '0',  
  PRIMARY KEY (BuchJahr,KtoNr,BnKreis,BelegNr,Typ),
  KEY KtoNr(KtoNr)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;



CREATE TABLE IF NOT EXISTS `buchungonline` (
  `ID` int(10) NOT NULL AUTO_INCREMENT,
  `Mnr` int(10) unsigned NOT NULL ,
  `UeberwDatum` date NOT NULL,
  `SollKtoNr` int(5) unsigned NOT NULL DEFAULT '0',
  `HabenKtoNr` int(5) unsigned NOT NULL DEFAULT '0',
  `Punkte` int(10) NOT NULL,
  `Tan` int(5) NOT NULL,
  `BlockNr` tinyint(2) NOT NULL DEFAULT '-1',   
  PRIMARY KEY (ID),
  KEY Mnr (Mnr)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE  TABLE IF NOT EXISTS `temp` (
  `KtoNr` int(5) NOT NULL ,
  `Kreditlimit` decimal(5,2) ,
  `BankKtoNr`  varchar(12) ,
  `BLZ` int(10),
  `BankName` varchar(30),
  PRIMARY KEY (`KtoNr`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='';

CREATE TABLE IF NOT EXISTS `sonderberechtigung` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Mnr` int(11) NOT NULL,
  `Email` varchar(40) NOT NULL,
  `Berechtigung` enum('IT','MV','RW','ZE','OeA') NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
INSERT INTO sonderberechtigung VALUES(0, 13, "tkienle@t-online.de", "IT");
CREATE TABLE IF NOT EXISTS `geschaeftsprozess` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Beschreibung` varchar(200) NOT NULL,
  `IT` tinyint(1) NOT NULL,
  `MV` tinyint(1) NOT NULL,
  `RW` tinyint(1) NOT NULL,
  `ZE` tinyint(1) NOT NULL,
  `OeA` tinyint(1) NOT NULL,
  PRIMARY KEY (ID)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `Umlage`;
CREATE TABLE IF NOT EXISTS `Umlage` (
  `Jahr` tinyint(4) NOT NULL,
  `RDU` decimal(5,2) NOT NULL,
  `KDU` decimal(5,2) NOT NULL DEFAULT '0.00'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

INSERT INTO `Umlage` (`Jahr`, `RDU`, `KDU`) VALUES
(2, 1.00, 0.00),
(13, 1.55, 0.00),
(3, 1.05, 0.00),
(4, 1.10, 0.00),
(5, 1.15, 0.00),
(6, 1.20, 0.00),
(7, 1.25, 0.00),
(8, 1.30, 0.00),
(9, 1.35, 0.00),
(10, 1.40, 0.00),
(11, 1.45, 0.00),
(12, 1.50, 0.00),
(14, 1.60, 0.00),
(15, 1.65, 0.00),
(16, 1.70, 0.00),
(17, 1.75, 0.00),
(18, 1.80, 0.00),
(19, 1.85, 0.00),
(20, 1.90, 0.00);

