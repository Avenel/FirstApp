=begin
  
  +----+--------------------------------------------------+----+----+----+----+-----+
| ID | Beschreibung                                     | IT | MV | RW | ZE | OeA |
+----+--------------------------------------------------+----+----+----+----+-----+
|  1 | Alle Mitglieder anzeigen                         |  1 |  1 |  1 |  1 |   1 |
|  2 | Details einer Person anzeigen                    |  1 |  1 |  1 |  1 |   1 |
|  3 | Mitglieder hinzufuegen                           |  1 |  1 |  0 |  0 |   0 |
|  5 | Mitglieder loeschen                              |  1 |  1 |  0 |  0 |   0 |
|  6 | Rolle eines Mitglieds zum Gesellschafter aendern |  1 |  1 |  0 |  0 |   0 |
|  7 | Mitglied Administratorrechte hinzufuegen         |  1 |  0 |  0 |  0 |   0 |
|  8 | Kontenklassen hinzufuegen                        |  1 |  0 |  1 |  0 |   0 |
|  9 | Kontenklassen bearbeiten                         |  1 |  0 |  0 |  0 |   0 |
| 11 | Alle Konten anzeigen                             |  1 |  1 |  1 |  1 |   1 |
| 12 | Details eines Kontos anzeigen                    |  1 |  1 |  1 |  1 |   1 |
| 13 | Einlage/Entnahmekonten hinzufuegen               |  1 |  0 |  1 |  0 |   0 |
| 14 | Einlage/Entnahmekonten bearbeiten                |  1 |  0 |  1 |  0 |   0 |
| 15 | Zusatzentnahmekonten hinzufuegen                 |  1 |  0 |  1 |  0 |   0 |
| 17 | Buergschaften anzeigen                           |  1 |  1 |  1 |  1 |   1 |
| 18 | Buergschaften hinzufuegen                        |  1 |  0 |  0 |  1 |   0 |
| 19 | Buergschaften bearbeiten                         |  1 |  0 |  0 |  1 |   0 |
| 20 | Veranstaltung einsehen/bearbeiten                |  1 |  1 |  0 |  0 |   1 |
+----+--------------------------------------------------+----+----+----+----+-----+
  
=end

Geschaeftsprozess.delete_all

Geschaeftsprozess.create(:ID => 1, :Beschreibung => "Alle Mitglieder anzeigen", :IT => 1, :MV => 1, :RW => 1, :ZE => 1, :OeA => 1)
Geschaeftsprozess.create(:ID => 2, :Beschreibung => "Details einer Person anzeigen", :IT => 1, :MV => 1, :RW => 1, :ZE => 1, :OeA => 1)
Geschaeftsprozess.create(:ID => 3, :Beschreibung => "Mitglieder hinzufuegen", :IT => 1, :MV => 1, :RW => 0, :ZE => 0, :OeA => 0)
Geschaeftsprozess.create(:ID => 5, :Beschreibung => "Mitglieder loeschen", :IT => 1, :MV => 1, :RW => 0, :ZE => 0, :OeA => 0)
Geschaeftsprozess.create(:ID => 6, :Beschreibung => "Rolle eines Mitglieds zum Gesellschafter aendern", :IT => 1, :MV => 1, :RW => 0, :ZE => 0, :OeA => 0)
Geschaeftsprozess.create(:ID => 7, :Beschreibung => "Mitglied Administratorrechte hinzufuegen", :IT => 1, :MV => 0, :RW => 0, :ZE => 0, :OeA => 0)
Geschaeftsprozess.create(:ID => 8, :Beschreibung => "Kontenklassen hinzufuegen", :IT => 1, :MV => 0, :RW => 1, :ZE => 0, :OeA => 0)
Geschaeftsprozess.create(:ID => 9, :Beschreibung => "Kontenklassen bearbeiten", :IT => 1, :MV => 0, :RW => 0, :ZE => 0, :OeA => 0)
Geschaeftsprozess.create(:ID => 11, :Beschreibung => "Alle Konten anzeigen", :IT => 1, :MV => 1, :RW => 1, :ZE => 1, :OeA => 1)
Geschaeftsprozess.create(:ID => 12, :Beschreibung => "Details eines Kontos anzeigen ", :IT => 1, :MV => 1, :RW => 1, :ZE => 1, :OeA => 1)
Geschaeftsprozess.create(:ID => 13, :Beschreibung => "Einlage/Entnahmekonten hinzufuegen", :IT => 1, :MV => 0, :RW => 1, :ZE => 0, :OeA => 0)
Geschaeftsprozess.create(:ID => 14, :Beschreibung => "Einlage/Entnahmekonten bearbeiten", :IT => 1, :MV => 0, :RW => 1, :ZE => 0, :OeA => 0)
Geschaeftsprozess.create(:ID => 15, :Beschreibung => "Zusatzentnahmekonten hinzufuegen", :IT => 1, :MV => 0, :RW => 1, :ZE => 0, :OeA => 0)
Geschaeftsprozess.create(:ID => 17, :Beschreibung => "Buergschaften anzeigen", :IT => 1, :MV => 1, :RW => 1, :ZE => 1, :OeA => 1)
Geschaeftsprozess.create(:ID => 18, :Beschreibung => "Buergschaften hinzufuegen", :IT => 1, :MV => 0, :RW => 0, :ZE => 1, :OeA => 0)
Geschaeftsprozess.create(:ID => 19, :Beschreibung => "Buergschaften bearbeite", :IT => 1, :MV => 0, :RW => 0, :ZE => 1, :OeA => 0)
Geschaeftsprozess.create(:ID => 20, :Beschreibung => "Veranstaltung einsehen/bearbeiten", :IT => 1, :MV => 1, :RW => 0, :ZE => 0, :OeA => 1)



