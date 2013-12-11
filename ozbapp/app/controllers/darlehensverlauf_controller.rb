require 'Punkteberechnung'

class DarlehensverlaufController < ApplicationController
  
  def new
    @anzeigen = params[:anzeigen]
    @summeDerPunkte = 0
    @summeSoll = 0
    @summeHaben = 0
    @differenzSollHaben = 0
    @tagesSaldoAltHaben = 0
    @notice = Array.new
    @errors  = Array.new
    @Buchungen = nil
    
    #prüfen ob das anfangsdatum in richtigem format angegeben wurde
    if (params[:vonDatum] =~ /[0-9]{2}.[0-9]{2}.[0-9]{4}/ || params[:vonDatum] =~ /[0-9]{4}-[0-9]{2}-[0-9]{2}/)
      @vonDatum = params[:vonDatum]
    end

    #prüfen ob das enddatum in richtigem format angegeben wurde
    if (params[:vonDatum] =~ /[0-9]{2}.[0-9]{2}.[0-9]{4}/ || params[:vonDatum] =~ /[0-9]{4}-[0-9]{2}-[0-9]{2}/)
      @bisDatum = params[:bisDatum]
    end

    
    #wurde der anzeigen button noch nicht betätigt. erster klick auf einen kontolink
    if @anzeigen.to_s.empty? && (params[:vonDatum].nil? || params[:bisDatum].nil?) then
      # Finde Datum 
      @Buchungen = Buchung.where("KtoNr = ?", params[:KtoNr]).order("BelegDatum DESC, Typ DESC, Punkte ASC").limit(10).reverse

      # Datum setzen (die letzten 10 Buchungen entscheiden)
      @vonDatum = @Buchungen.first.Belegdatum.strftime("%d.%m.%Y")
      @bisDatum = Date.current().strftime("%d.%m.%Y")
    
      # Die letzten Buchungen, chronologisch aufsteigend sortiert
      @Buchungen = Buchung.where("KtoNr = ? AND Belegdatum >= ? AND Belegdatum <= ?", params[:KtoNr], @vonDatum.to_date, @bisDatum.to_date).order("BelegDatum ASC, Typ ASC, Punkte DESC")
    #wurde der anzeigen button geklickt werden die buchungen in dem angegebenen zeitraum angezeigt
    else
      #prüfung ob ein ein datum in falschem format eingegeben wurde
      if !@vonDatum.to_s.empty? && !@bisDatum.to_s.empty?
        @Buchungen = Buchung.where("KtoNr = ? AND Belegdatum >= ? AND Belegdatum <= ?", params[:KtoNr], @vonDatum.to_date, @bisDatum.to_date).order("BelegDatum ASC, Typ ASC, Punkte DESC")
      #wurde ein datum in falschem format eingegeben wird eine fehlermeldung ausgegeben
      else
        @errors.push("Geben sie bitte ein valides Datum ein.")
      end
    end

    # Falls der Zeitraum richtig angegeben wurde und Buchungen vorhanden sind, fahre fort
    if @errors.empty? &&  !@Buchungen.nil? && !@Buchungen.empty? then

      # Daten zum Kontoinhaber
      if params[:EEoZEkonto] == "EE"
          @bankId = EeKonto.where("KtoNr = ?", params[:KtoNr]).first.BankID
      else
        @EeKtoNrZumZeKto = ZeKonto.where("KtoNr = ?", params[:KtoNr]).first.EEKtoNr
        @bankId = EeKonto.where("KtoNr = ?", @EeKtoNrZumZeKto).first.BankID
      end

      @pnrDesInhabers = Bankverbindung.where("ID = ?", @bankId).first.Pnr
      @personZurPnr = Person.where("Pnr = ?", @pnrDesInhabers).first
      @nameZurPerson = @personZurPnr.Name
      @vornameZurPerson = @personZurPnr.Vorname

      # Die (Währungs) Buchung vor der ersten Buchung in Buchungen finden
      @vorherigeBuchung = Buchung.where("KtoNr = ? AND Belegdatum < ? AND Typ = 'w'", params[:KtoNr], @vonDatum.to_date).order("Belegdatum DESC, Punkte ASC").limit(1).first

      # Gueltige KKL
      kkl = getKKL(params[:KtoNr])

      # Prüfen ob es sich um ein wiederverwendetes ZE Konto handelt
      wurdeWiederverwendet = checkReuse(params[:KtoNr], @vonDatum.to_date, params[:EEoZEkonto])

      # Fallunterscheidung:
      # => wurde nicht wiederverwendet: Ganz normal verfahren
      # => wurde wiederverwendet: Finde Zeitpunkt heraus und berechne ab diesem Zeitpunkt die Punkteanzahl für den Tagessaldo. Dieser hat auch Einfluss auf den ersten weiteren PSaldoAcc
      if !wurdeWiederverwendet then 
        if !@vorherigeBuchung.nil? then
          # Punkte für den Tagessaldo der ersten Buchung berechnen = ((DiffTage * WSaldoAcc) / 30) * KKL + Punkte vorherigeBuchung
          punkte = Punkteberechnung.calculate(@vorherigeBuchung.Belegdatum.to_time, @vonDatum.to_time, @vorherigeBuchung.WSaldoAcc, params[:KtoNr])
          @tagessaldoPunkte = punkte + @vorherigeBuchung.PSaldoAcc
        else
          @tagessaldoPunkte = 0
        end
      else 
        # Berechne ab dem Zeitpunkt die Punkte, ab dem das Konto wiederverwendet wurde
        # => kummuliere alle PSaldi
        wurdeWiederverwendetAm = findLastResetBooking(params[:KtoNr]).Belegdatum.to_date

        kummuliertePSaldi = 0
        if @vonDatum.to_date >= wurdeWiederverwendetAm.to_date then
          buchungen = Buchung.where("ktoNr = ? AND Belegdatum >= ? AND Belegdatum <= ?", params[:KtoNr], wurdeWiederverwendetAm.to_date, @vonDatum.to_date).order("Belegdatum DESC, Typ DESC, Punkte DESC")
          
          buchungen.each do |buchung|
            # TODO: KKL hat sich zwischenzeitlich verändert
            kummuliertePSaldi += buchung.Punkte
          end
        end
        @tagessaldoPunkte = Punkteberechnung.calculate( @vorherigeBuchung.Belegdatum.to_time, @vonDatum.to_time, @vorherigeBuchung.WSaldoAcc, params[:KtoNr]) + kummuliertePSaldi
      end

      # Lege Tagessaldo Zeile an
      # => Falls es vorherige Buchungen gibt, übernehme deren Saldi
      # => Falls es keine vorherigen Buchungen gibt, setze Saldi auf 0
      if !@vorherigeBuchung.nil? then
        @tagesSaldoZeile = @vorherigeBuchung.dup
         # bestimmung ob es soll oder haben ist
        if @tagesSaldoZeile.WSaldoAcc > 0
          @tagesSaldoZeile.Habenbetrag = @tagesSaldoZeile.WSaldoAcc
          @tagesSaldoZeile.Sollbetrag = "0"
        else
          @tagesSaldoZeile.Habenbetrag = "0"
          @tagesSaldoZeile.Sollbetrag = @tagesSaldoZeile.WSaldoAcc * (-1)
        end   
      else
        @tagesSaldoZeile = @Buchungen.first.dup
        @tagesSaldoZeile.Habenbetrag = 0
        @tagesSaldoZeile.Sollbetrag = 0
      end

      @tagesSaldoZeile.Buchungstext = "Tagessaldo"
      @tagesSaldoZeile.Typ = "w"
      @tagesSaldoZeile.Belegdatum = @vonDatum
      @tagesSaldoZeile.Punkte = @tagessaldoPunkte


      # In der Tagessaldozeile bereits berücksichtigte Buchungen mit 0 Punkten bewerten
      @Buchungen.each do |buchung|
        if buchung.Belegdatum.to_date == @vonDatum.to_date then
          buchung.Punkte = 0
        end
      end

      # Die nachfolgend erste Währungsbuchung muss korrigiert werden
      # => Punkte der Buchung -= Punkte im Intervall: Buchung.Belegdatum -  vonDatum
      if !@Buchungen.first.nil? && !@vorherigeBuchung.nil? then
        @Buchungen.first.Punkte = Punkteberechnung.calculate(@vonDatum.to_time, @vorherigeBuchung.Belegdatum.to_time, @vorherigeBuchung.WSaldoAcc, params[:KtoNr])
      end

      # Tagessaldozeile den Buchungen oben einfügen
      @Buchungen.push(@tagesSaldoZeile)
      @Buchungen.rotate!(-1)

      # Berechne WSaldo und PSaldo
      @Buchungen.each do |buchung|
        #ist es eine währungsbuchung
        if buchung.Typ == "w"
          @summeDerPunkte += buchung.Punkte
          @summeSoll += buchung.Sollbetrag
          @summeHaben += buchung.Habenbetrag
        #ist es eine punktebuchung
        else
          if buchung.Sollbetrag == 0 and buchung.Habenbetrag != 0
            @summeDerPunkte += buchung.Habenbetrag
          else
            @summeDerPunkte += buchung.Sollbetrag
          end
        end
      end      

      @differenzSollHaben = @summeHaben - @summeSoll

      # Berechne erreichte Punkte in dem gegebenen Intervall (von - bis)
      # Die letzte (Währungs) Buchung vor dem bisDatum finden
      @letzteWaehrungsBuchung = Buchung.where("KtoNr = ? AND Belegdatum <= ? AND Typ = 'w'", params[:KtoNr], @bisDatum.to_date).order("Belegdatum DESC, Punkte ASC").limit(1).first

      @punkteImIntervall = Punkteberechnung.calculate(@letzteWaehrungsBuchung.Belegdatum.to_time, @bisDatum.to_time, @differenzSollHaben, params[:KtoNr])

      # Lege Zeile für die erreichten Punkte an
      @erreichtePunkteZeile = @Buchungen.first.dup
      @erreichtePunkteZeile.Buchungstext = "Punkte von " + @letzteWaehrungsBuchung.Belegdatum.strftime("%d.%m.%Y") + " bis " + @bisDatum.to_date.strftime("%d.%m.%Y")
      @erreichtePunkteZeile.Belegdatum = @bisDatum
      @erreichtePunkteZeile.Sollbetrag = 0
      @erreichtePunkteZeile.Habenbetrag = 0
      @erreichtePunkteZeile.Punkte = @punkteImIntervall
      @erreichtePunkteZeile.WSaldoAcc = 0
      @erreichtePunkteZeile.Typ = "w"

      @Buchungen.push(@erreichtePunkteZeile)

      # Summiere erreichte Punkte auf
      @summeDerPunkte += @punkteImIntervall

    #gab es noch keine buchungen wird eine warnung ausgegeben
    else
      @notice.push("In dem angegebenen Zeitraum gibt es noch keine Buchungen.")   
    end 
  end



  def kontoauszug
    new()
  end
  

  # Liefert anhand einer gegebenen Kontonummer die richtige Kontoklasse zurueck.
  def getKKL(ktoNr)
    kklVerlauf = KklVerlauf.where("KtoNr = ?", ktoNr).order("KKLAbDatum DESC").limit(1).first

    if kklVerlauf.nil? then 
      return 0
    end

    kklVerlaufKlasse = kklVerlauf.KKL
    case kklVerlaufKlasse
      when "A"
        return 1
      when "B"
        return 0.75
      when "C"
        return 0.50
      when "D"
        return 0.25
      when "E"
        return 0
    end

    return 0
  end


  # Ein Konto wurde wiederverwendet falls:
  # => es ein ZE Konto ist
  # => es vor dem angegebenen Startzeitpunkt eine Buchung mit Punkte = 0 gegeben hat
  def checkReuse(ktoNr, vonDatum, kontoTyp)
    if (kontoTyp == "ZE") then
      # Besorge alle Buchungen vor dem vonDatum
      buchungen = Buchung.where("KtoNr = ? AND Belegdatum <= ? AND Punkte = 0", ktoNr, vonDatum).order("Belegdatum DESC, Typ DESC, Punkte DESC, SollBetrag DESC")
      
      # Schaue nach einer PSaldoAcc = 0 Buchung
      if !buchungen.empty? then
        return true
      end
    end

    # Andernfalls handelt es sich nicht um ein wiederverwendetes Konto
    return false
  end

  # Findet die Buchung heraus, welche die letzte Wiederverwendung oder Beginn des ZE eingelauetet hat
  def findLastResetBooking(ktoNr)
    # filtere non-ZE Konten 
    zeKonto = ZeKonto.where("KtoNr = ?", ktoNr).first
    if zeKonto.nil? then 
      return nil
    end

    # Besorge alle Buchungen vor dem vonDatum
    buchungen = Buchung.where("KtoNr = ? AND Punkte = 0", ktoNr).order("Belegdatum DESC, Typ DESC, Punkte DESC, SollBetrag DESC")

    # Gebe die zuletzt gefundene Buchung zurueck
    if !buchungen.empty? then
      return buchungen.first
    end
    
    return nil
  end

end