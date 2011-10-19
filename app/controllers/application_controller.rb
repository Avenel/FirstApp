class ApplicationController < ActionController::Base
   protect_from_forgery
   @@i = 132
   
   def test
      
      # Personen-Beziehungen: Telefon, Administrator, Partner, Veranstaltung, Teilnahme, Buergschaft
      @person = Person.new
      @person.rolle = :G
      @person.name = "Mustermann"
      @person.vorname = "Max"
      @person.save

      tel = Telefon.new
      tel.pnr = @person.pnr
      tel.telefonNr = "020122"
      tel.telefonTyp = "handy"
      tel.save
      
      admin = Administrator.new
      admin.pnr = @person.pnr
      admin.adminPw = "hello"
      admin.adminEmail = "sd@asd.com"
      admin.save
      
      #partner = Partner.new
      #partner.mnr = @@i
      #partner.mnrO = @@i
      #partner.berechtigung = "A"
      #partner.save
      
      @veranstaltung = Veranstaltung.new
      @veranstaltung.vid = 1
      @veranstaltung.vaDatum = Date.new
      @veranstaltung.vaOrt = "Buxtehude"
      @veranstaltung.save
   
      teilnahme = Teilnahme.new
      teilnahme.pnr = @person.pnr
      teilnahme.vnr = @veranstaltung.vnr
      teilnahme.teilnArt = :a
      teilnahme.save
            
      buergschaft = Buergschaft.new
      buergschaft.pnrB = @person.pnr
      buergschaft.pnrG = @@i
      buergschaft.ktoNr = 91324
      buergschaft.save
      
      # Teilnahme-Beziehungen:Veranstaltung, Veranstaltungsart
      veranstaltungsart = Veranstaltungsart.new
      veranstaltungsart.vaBezeichnung = "Eierschaukeln"
      veranstaltungsart.save
      
   end
  
end
