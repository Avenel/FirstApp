CREATE TABLE `adresse` (
  `Pnr` int(10) unsigned NOT NULL,
  `GueltigVon` datetime NOT NULL,
  `GueltigBis` datetime NOT NULL,
  `Strasse` varchar(50) DEFAULT NULL,
  `Nr` varchar(10) DEFAULT NULL,
  `PLZ` int(5) unsigned DEFAULT NULL,
  `Ort` varchar(50) DEFAULT NULL,
  `SachPnr` int(10) unsigned DEFAULT NULL,
  `Vermerk` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`Pnr`,`GueltigVon`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `bank` (
  `BLZ` int(10) unsigned NOT NULL,
  `BIC` char(10) DEFAULT NULL,
  `BankName` varchar(35) DEFAULT NULL,
  PRIMARY KEY (`BLZ`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `bankverbindung` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `GueltigVon` datetime NOT NULL,
  `GueltigBis` datetime NOT NULL,
  `Pnr` int(10) unsigned NOT NULL,
  `BankKtoNr` varchar(12) DEFAULT NULL,
  `IBAN` char(20) DEFAULT NULL,
  `BLZ` int(10) unsigned NOT NULL,
  `SachPnr` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`ID`,`GueltigVon`),
  KEY `BLZ` (`BLZ`),
  CONSTRAINT `bankverbindung_ibfk_1` FOREIGN KEY (`BLZ`) REFERENCES `bank` (`BLZ`)
) ENGINE=InnoDB AUTO_INCREMENT=127 DEFAULT CHARSET=latin1;

CREATE TABLE `buchung` (
  `BuchJahr` int(4) unsigned NOT NULL,
  `KtoNr` int(5) unsigned NOT NULL,
  `BnKreis` char(2) NOT NULL,
  `BelegNr` int(10) unsigned NOT NULL,
  `Typ` char(1) NOT NULL,
  `Belegdatum` date NOT NULL,
  `BuchDatum` date NOT NULL,
  `Buchungstext` varchar(50) NOT NULL DEFAULT '',
  `Sollbetrag` decimal(10,2) DEFAULT NULL,
  `Habenbetrag` decimal(10,2) DEFAULT NULL,
  `SollKtoNr` int(5) unsigned NOT NULL DEFAULT '0',
  `HabenKtoNr` int(5) unsigned NOT NULL DEFAULT '0',
  `WSaldoAcc` decimal(10,2) NOT NULL DEFAULT '0.00',
  `PSaldoAcc` int(10) NOT NULL DEFAULT '0',
  `Punkte` int(10) DEFAULT NULL,
  PRIMARY KEY (`BuchJahr`,`KtoNr`,`BnKreis`,`BelegNr`,`Typ`),
  KEY `KtoNr` (`KtoNr`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `buchungonline` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Mnr` int(10) unsigned NOT NULL,
  `UeberwDatum` date NOT NULL,
  `SollKtoNr` int(5) unsigned NOT NULL DEFAULT '0',
  `HabenKtoNr` int(5) unsigned NOT NULL DEFAULT '0',
  `Punkte` int(10) NOT NULL,
  `Tan` int(5) unsigned NOT NULL,
  `BlockNr` tinyint(2) NOT NULL DEFAULT '-1',
  PRIMARY KEY (`ID`),
  KEY `Mnr` (`Mnr`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `buergschaft` (
  `Pnr_B` int(10) unsigned NOT NULL,
  `Mnr_G` int(10) unsigned NOT NULL,
  `GueltigVon` datetime NOT NULL,
  `GueltigBis` datetime NOT NULL,
  `ZENr` char(10) NOT NULL,
  `SichAbDatum` datetime DEFAULT NULL,
  `SichEndDatum` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `SichBetrag` decimal(10,2) DEFAULT NULL,
  `SichKurzbez` varchar(200) DEFAULT NULL,
  `SachPnr` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`Pnr_B`,`Mnr_G`,`GueltigVon`,`SichEndDatum`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `eekonto` (
  `KtoNr` int(5) unsigned NOT NULL,
  `GueltigVon` datetime NOT NULL,
  `GueltigBis` datetime NOT NULL,
  `BankID` int(10) unsigned DEFAULT NULL,
  `Kreditlimit` decimal(5,2) DEFAULT '0.00',
  `SachPnr` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`KtoNr`,`GueltigVon`),
  KEY `BankID` (`BankID`),
  CONSTRAINT `eekonto_ibfk_1` FOREIGN KEY (`BankID`) REFERENCES `bankverbindung` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `foerdermitglied` (
  `Pnr` int(10) unsigned NOT NULL,
  `GueltigVon` datetime NOT NULL,
  `GueltigBis` datetime NOT NULL,
  `Region` varchar(30) DEFAULT NULL,
  `Foerderbeitrag` decimal(5,2) DEFAULT NULL,
  `SachPnr` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`Pnr`,`GueltigVon`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `geschaeftsprozess` (
  `ID` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `Beschreibung` varchar(200) NOT NULL,
  `IT` tinyint(1) unsigned NOT NULL,
  `MV` tinyint(1) unsigned NOT NULL,
  `RW` tinyint(1) unsigned NOT NULL,
  `ZE` tinyint(1) unsigned NOT NULL,
  `OeA` tinyint(1) unsigned NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=latin1;

CREATE TABLE `gesellschafter` (
  `Mnr` int(10) unsigned NOT NULL,
  `GueltigVon` datetime NOT NULL,
  `GueltigBis` datetime NOT NULL,
  `FALfdNr` char(20) DEFAULT NULL,
  `FASteuerNr` char(15) DEFAULT NULL,
  `FAIdNr` char(15) DEFAULT NULL,
  `Wohnsitzfinanzamt` varchar(50) DEFAULT NULL,
  `NotarPnr` int(10) unsigned DEFAULT NULL,
  `BeurkDatum` date DEFAULT NULL,
  `SachPnr` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`Mnr`,`GueltigVon`),
  KEY `NotarPnr` (`NotarPnr`),
  KEY `Mnr` (`Mnr`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `kklverlauf` (
  `KtoNr` int(5) unsigned NOT NULL,
  `KKLAbDatum` date NOT NULL,
  `KKL` char(1) NOT NULL,
  PRIMARY KEY (`KtoNr`,`KKLAbDatum`),
  KEY `KKL` (`KKL`),
  CONSTRAINT `kklverlauf_ibfk_1` FOREIGN KEY (`KKL`) REFERENCES `kontenklasse` (`KKL`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `kontenklasse` (
  `KKL` char(1) NOT NULL,
  `KKLAbDatum` date NOT NULL,
  `Prozent` decimal(5,2) unsigned NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`KKL`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `mitglied` (
  `Mnr` int(10) unsigned NOT NULL,
  `GueltigVon` datetime NOT NULL,
  `GueltigBis` datetime NOT NULL,
  `RVDatum` date DEFAULT NULL,
  `SachPnr` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`Mnr`,`GueltigVon`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `ozbkonto` (
  `KtoNr` int(5) unsigned NOT NULL,
  `GueltigVon` datetime NOT NULL,
  `GueltigBis` datetime NOT NULL,
  `Mnr` int(10) unsigned NOT NULL,
  `KtoEinrDatum` date DEFAULT NULL,
  `Waehrung` char(3) NOT NULL DEFAULT 'STR',
  `WSaldo` decimal(10,2) DEFAULT NULL,
  `PSaldo` int(11) DEFAULT NULL,
  `SaldoDatum` date DEFAULT NULL,
  `SachPnr` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`KtoNr`,`GueltigVon`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `ozbperson` (
  `Mnr` int(10) unsigned NOT NULL,
  `UeberPnr` int(10) unsigned DEFAULT NULL,
  `Passwort` varchar(35) DEFAULT NULL,
  `PWAendDatum` date DEFAULT NULL,
  `Antragsdatum` date DEFAULT NULL,
  `Aufnahmedatum` date DEFAULT NULL,
  `Austrittsdatum` date DEFAULT NULL,
  `Schulungsdatum` date DEFAULT NULL,
  `Gesperrt` tinyint(2) unsigned NOT NULL DEFAULT '0',
  `SachPnr` int(10) unsigned DEFAULT NULL,
  `encrypted_password` varchar(64) NOT NULL DEFAULT '$2a$10$qGrVqv4bHcfd4Ld649LoS.xIc/gK8GBdSXAS47AQpg1eVhPQL.H7K',
  `reset_password_token` varchar(128) DEFAULT NULL,
  `reset_password_sent_at` datetime DEFAULT NULL,
  `remember_created_at` datetime DEFAULT NULL,
  `sign_in_count` int(10) DEFAULT '0',
  `current_sign_in_at` datetime DEFAULT NULL,
  `last_sign_in_at` datetime DEFAULT NULL,
  `current_sign_in_ip` varchar(16) DEFAULT NULL,
  `last_sign_in_ip` varchar(16) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`Mnr`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `partner` (
  `Mnr` int(10) unsigned NOT NULL,
  `GueltigVon` datetime NOT NULL,
  `GueltigBis` datetime NOT NULL,
  `MnrO` int(10) unsigned NOT NULL,
  `Berechtigung` char(1) NOT NULL DEFAULT '1',
  `SachPnr` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`Mnr`,`GueltigVon`),
  KEY `MnrO` (`MnrO`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `person` (
  `Pnr` int(10) unsigned NOT NULL,
  `GueltigVon` datetime NOT NULL,
  `GueltigBis` datetime NOT NULL,
  `Rolle` enum('G','M','P','S','F') DEFAULT NULL,
  `Name` varchar(20) NOT NULL,
  `Vorname` varchar(15) NOT NULL DEFAULT '',
  `Geburtsdatum` date DEFAULT NULL,
  `Email` varchar(40) DEFAULT NULL,
  `SperrKZ` tinyint(2) unsigned NOT NULL DEFAULT '0',
  `SachPnr` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`Pnr`,`GueltigVon`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `projektgruppe` (
  `Pgnr` tinyint(2) unsigned NOT NULL DEFAULT '0',
  `ProjGruppenBez` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`Pgnr`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `sonderberechtigung` (
  `ID` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `Mnr` int(11) unsigned NOT NULL,
  `Email` varchar(40) NOT NULL,
  `Berechtigung` enum('IT','MV','RW','ZE','OeA') NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

CREATE TABLE `student` (
  `Mnr` int(10) unsigned NOT NULL,
  `GueltigVon` datetime NOT NULL,
  `GueltigBis` datetime NOT NULL,
  `AusbildBez` varchar(30) DEFAULT NULL,
  `InstitutName` varchar(30) DEFAULT NULL,
  `Studienort` varchar(30) DEFAULT NULL,
  `Studienbeginn` date DEFAULT NULL,
  `Studienende` date DEFAULT NULL,
  `Abschluss` char(20) DEFAULT NULL,
  `SachPnr` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`Mnr`,`GueltigVon`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `tan` (
  `Mnr` int(10) unsigned NOT NULL,
  `ListNr` tinyint(2) unsigned NOT NULL,
  `TanNr` int(10) unsigned NOT NULL,
  `Tan` int(5) unsigned NOT NULL,
  `VerwendetAm` date DEFAULT NULL,
  `Status` enum('o','x') DEFAULT NULL,
  PRIMARY KEY (`Mnr`,`ListNr`,`TanNr`),
  CONSTRAINT `tan_ibfk_1` FOREIGN KEY (`Mnr`, `ListNr`) REFERENCES `tanliste` (`Mnr`, `ListNr`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `tanliste` (
  `Mnr` int(10) unsigned NOT NULL,
  `ListNr` tinyint(2) unsigned NOT NULL,
  `Status` enum('n','d','a') DEFAULT NULL,
  PRIMARY KEY (`Mnr`,`ListNr`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `teilnahme` (
  `Pnr` int(10) unsigned NOT NULL,
  `Vnr` int(5) unsigned NOT NULL,
  `TeilnArt` enum('a','e','u','l','m') DEFAULT NULL,
  `SachPnr` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`Pnr`,`Vnr`),
  KEY `Vnr` (`Vnr`),
  KEY `Pnr` (`Pnr`),
  CONSTRAINT `teilnahme_ibfk_1` FOREIGN KEY (`Vnr`) REFERENCES `veranstaltung` (`Vnr`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `telefon` (
  `Pnr` int(10) unsigned NOT NULL,
  `LfdNr` tinyint(2) unsigned NOT NULL,
  `TelefonNr` varchar(15) DEFAULT NULL,
  `TelefonTyp` char(6) DEFAULT NULL,
  PRIMARY KEY (`Pnr`,`LfdNr`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `umlage` (
  `Jahr` tinyint(4) unsigned NOT NULL,
  `RDU` decimal(5,2) NOT NULL,
  `KDU` decimal(5,2) NOT NULL DEFAULT '0.00'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `veranstaltung` (
  `Vnr` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `VANr` int(11) unsigned NOT NULL,
  `VADatum` date NOT NULL,
  `VAOrt` varchar(30) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `SachPnr` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`Vnr`),
  KEY `VANr` (`VANr`),
  CONSTRAINT `veranstaltung_ibfk_1` FOREIGN KEY (`VANr`) REFERENCES `veranstaltungsart` (`VANr`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `veranstaltungsart` (
  `VANr` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `VABezeichnung` varchar(30) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`VANr`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;

CREATE TABLE `zekonto` (
  `GueltigVon` datetime NOT NULL,
  `GueltigBis` datetime NOT NULL,
  `KtoNr` int(5) unsigned NOT NULL,
  `EEKtoNr` int(5) unsigned NOT NULL,
  `Pgnr` tinyint(2) unsigned DEFAULT NULL,
  `ZENr` char(10) DEFAULT NULL,
  `ZEAbDatum` date DEFAULT NULL,
  `ZEEndDatum` date DEFAULT NULL,
  `ZEBetrag` decimal(10,2) DEFAULT NULL,
  `Laufzeit` tinyint(4) unsigned NOT NULL,
  `ZahlModus` char(1) DEFAULT 'M',
  `TilgRate` decimal(10,2) NOT NULL DEFAULT '0.00',
  `NachsparRate` decimal(10,2) NOT NULL DEFAULT '0.00',
  `KDURate` decimal(10,2) NOT NULL DEFAULT '0.00',
  `RDURate` decimal(10,2) NOT NULL DEFAULT '0.00',
  `ZEStatus` char(1) NOT NULL DEFAULT 'A',
  `SachPnr` int(10) unsigned DEFAULT NULL,
  `Kalk_Leihpunkte` int(11) DEFAULT NULL,
  `Tats_Leihpunkte` int(11) DEFAULT NULL,
  `Sicherung` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`KtoNr`,`GueltigVon`),
  KEY `Pgnr` (`Pgnr`),
  KEY `EEKtoNr` (`EEKtoNr`),
  CONSTRAINT `zekonto_ibfk_1` FOREIGN KEY (`Pgnr`) REFERENCES `projektgruppe` (`Pgnr`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

