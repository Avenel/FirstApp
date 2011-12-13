# encoding: UTF-8

# Personen-Beziehungen: Telefon, Administrator, Partner, Veranstaltung, Teilnahme, Buergschaft
  
person = Person.create( :rolle => :B, :name => "Mustermann", :vorname => "Max" )
person2 = Person.create( :rolle => :G, :name => "Mueller", :vorname => "Hermann" )
person3 = Person.create( :rolle => :S, :name => "Müller", :vorname => "Lieschen" )
person4 = Person.create( :rolle => :M, :name => "Neuer", :vorname => "Manuel" )
person5 = Person.create( :rolle => :G, :name => "Kahn", :vorname => "Oliver" )
person6 = Person.create( :rolle => :P, :name => "Schneider", :vorname => "Rudi" )
   
tel = Telefon.create( :pnr => person.pnr, :telefonNr => "072458292", :telefonTyp => "Fest" )
tel = Telefon.create( :pnr => person2.pnr, :telefonNr => "072452391", :telefonTyp => "Fest" )
tel = Telefon.create( :pnr => person3.pnr, :telefonNr => "072459281", :telefonTyp => "Fest" )
tel = Telefon.create( :pnr => person4.pnr, :telefonNr => "072458639", :telefonTyp => "Fest" )
tel = Telefon.create( :pnr => person5.pnr, :telefonNr => "072453021", :telefonTyp => "Fest" )
tel = Telefon.create( :pnr => person6.pnr, :telefonNr => "072450483", :telefonTyp => "Fest" )

# OZB Personen
ozbPerson = OZBPerson.create( :mnr => person.pnr, :ueberPnr => person.pnr, :email => "person1@ozb.de", :password => "123456", :pSaldo => 50,
                              :ktoEinrDatum => Date.new(), :saldoDatum => Date.new() )
ozbPartner = OZBPerson.create( :mnr => person2.pnr, :ueberPnr => person2.pnr, :email => "partner@ozb.de", :password => "123456",
                              :ktoEinrDatum => Date.new(), :saldoDatum => Date.new(), :pSaldo => 61 )
ozbPerson3 = OZBPerson.create( :mnr => person3.pnr, :ueberPnr => person3.pnr, :email => "person3@ozb.de", :password => "123456",
                              :ktoEinrDatum => Date.new(), :saldoDatum => Date.new(), :pSaldo => 60 )
ozbPerson2 = OZBPerson.create( :mnr => person4.pnr, :ueberPnr => person4.pnr, :email => "person4@ozb.de", :password => "123456",
                              :ktoEinrDatum => Date.new(), :saldoDatum => Date.new(), :pSaldo => 42 )
ozbPerson5 = OZBPerson.create( :mnr => person5.pnr, :ueberPnr => person5.pnr, :email => "person5@ozb.de", :password => "123456",
                              :ktoEinrDatum => Date.new(), :saldoDatum => Date.new(), :pSaldo => 210 )
ozbPerson4 = OZBPerson.create( :mnr => person6.pnr, :ueberPnr => person6.pnr, :email => "person6@ozb.de", :password => "123456",
                              :ktoEinrDatum => Date.new(), :saldoDatum => Date.new(), :pSaldo => 120 )


# Rollen
admin = Administrator.create( :pnr => person.pnr, :adminPw => "test", :adminEmail => "test@test.de" )
partner = Partner.create( :mnr => ozbPartner.mnr, :mnrO => person.pnr, :berechtigung => 'A' )
mitglied = Mitglied.create(:mnr => ozbPerson.mnr )
student = Student.create( :mnr => ozbPerson.mnr, :studienort => "Karlsruhe" ) 
gesellschafter = Gesellschafter.create( :mnr => ozbPerson.mnr, :faSteuerNr => 13512, :faLfdNr => 2134 ) 


# Veranstaltungen
veranstaltung = Veranstaltung.create( :vid => 1, :vaDatum => Time.now, :vaOrt => "Buxtehude" )
teilname = Teilnahme.create( :pnr => person.pnr, :vnr => veranstaltung.vnr, :teilnArt => :a )
veranstaltungsart = Veranstaltungsart.create( :vaBezeichnung => "Eierschaukeln" )

# OZB Konto
ozbKonto = OZBKonto.create( :ktoNr => 50001, :mnr => ozbPerson.mnr, :wSaldo => 520.21 )
ozbKonto2 = OZBKonto.create( :ktoNr => 50004, :mnr => ozbPerson2.mnr, :wSaldo => 1231.32 )
ozbKonto3 = OZBKonto.create( :ktoNr => 50005, :mnr => ozbPerson3.mnr, :wSaldo => 83920.12 )
ozbKonto4 = OZBKonto.create( :ktoNr => 50006, :mnr => ozbPerson4.mnr, :wSaldo => 9227.41 )
ozbGesellschafterKonto = OZBKonto.create( :ktoNr => 10002, :mnr => ozbPartner.mnr, :wSaldo => 10000 )  


# Buchungen
buchungonline = BuchungOnline.create( :mnr => ozbPerson.mnr, :ueberwdatum => Time.now, :sollktonr => ozbKonto.ktoNr, 
                                      :habenktonr => 25231, :punkte => 1337, :tan => 52621, :blocknr => 45 )

buchung = Buchung.create( :buchungstext => "Test", :buchJahr => 2010, :buchDatum => Time.now, :ktoNr => ozbKonto.ktoNr, 
                            :bnKreis => "A2", :belegNr => 213, :belegDatum => Time.now, :typ => "B" )


# Tanlisten
tanliste=  Tanliste.create( :mnr => ozbPerson.mnr, :listNr => 1, :status => :n )
tan = Tan.create( :mnr => ozbPerson.mnr, :listNr => 1, :tanNr => 1, :tan => 43123 )


# Bankverbindungen
bankverbindung = Bankverbindung.create( :pnr => person.pnr, :blz => 213123 )


# EE Konten
eeKonto = EEKonto.create( :ktoNr => ozbKonto.ktoNr, :bankId => bankverbindung.id )


# Projektgruppen
projGruppe = Projektgruppe.create()

# ZE Konten
zeKonto = ZEKonto.create( :ktoNr => ozbGesellschafterKonto.ktoNr, :eeKtoNr => eeKonto.ktoNr, :laufzeit => 23, :tilgRate => 200, 
                          :pgNr => projGruppe.pgNr )




# Buergschaften
buergschaft = Buergschaft.create( :pnrB => person.pnr, :mnrG => gesellschafter.mnr, :ktoNr => zeKonto.ktoNr )

# Kontenklassen
kkl = Kontenklasse.create(:kkl => 1, :prozent => 100.0, :kklAbDatum => Time.now)
kkl2 = Kontenklasse.create(:kkl => 2, :prozent => 75.0, :kklAbDatum => Time.now)
kkl3 = Kontenklasse.create(:kkl => 3, :prozent => 50.0, :kklAbDatum => Time.now)


# Kontenklassenverlaeufe
kklVerlauf = KKLVerlauf.create( :ktoNr => eeKonto.ktoNr, :kklAbDatum => Time.now, :kkl => kkl.kkl )
kklVerlauf = KKLVerlauf.create( :ktoNr => zeKonto.ktoNr, :kklAbDatum => Time.now, :kkl => kkl2.kkl )
kklVerlauf = KKLVerlauf.create( :ktoNr => ozbKonto2.ktoNr, :kklAbDatum => Time.now, :kkl => kkl2.kkl )
kklVerlauf = KKLVerlauf.create( :ktoNr => ozbKonto3.ktoNr, :kklAbDatum => Time.now, :kkl => kkl3.kkl )
kklVerlauf = KKLVerlauf.create( :ktoNr => ozbKonto4.ktoNr, :kklAbDatum => Time.now, :kkl => kkl.kkl )




