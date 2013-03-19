class DarlehensverlaufController < ApplicationController


  def new
    @anzeigen = params[:anzeigen]
    @summeDerPunkte = 0
    @summeSoll = 0
    @summeHaben = 0
    @differenzSollHaben
    @tagesSaldoAltHaben = 0
    @notice = Array.new
    @errors  = Array.new
    @Buchung = nil

    
    #prüfen ob das anfangsdatum in richtigem format angegeben wurde
    if (params[:vonDatum] =~ /[0-9]{2}.[0-9]{2}.[0-9]{4}/)
      @vonDatum = params[:vonDatum]
    end

    #prüfen ob das enddatum in richtigem format angegeben wurde
    if (params[:vonDatum] =~ /[0-9]{2}.[0-9]{2}.[0-9]{4}/)
      @bisDatum = params[:bisDatum]
    end

    
    #wurde der anzeigen button noch nicht betätigt. erster klick auf einen kontolink
    if @anzeigen.to_s.empty?
      @Buchung = Buchung.where("KtoNr = ?", params[:KtoNr]).order("Belegdatum Desc, SollBetrag ASC, Typ DESC, PSaldoAcc DESC").limit(10).reverse
      #prüfung ob es überhaupt buchungen gibt
      if !@Buchung.empty?

        if params[:EEoZEkonto] == "EE"
          @bankId = EeKonto.where("KtoNr = ?", params[:KtoNr]).first.bankId
        else
          @EeKtoNrZumZeKto = ZeKonto.where("KtoNr = ?", params[:KtoNr]).first.eeKtoNr
          @bankId = EeKonto.where("KtoNr = ?", @EeKtoNrZumZeKto).first.bankId
        end

        @pnrDesInhabers = Bankverbindung.where("ID = ?", @bankId).first.pnr
        @personZurPnr = Person.where("Pnr = ?", @pnrDesInhabers).first
        @nameZurPerson = @personZurPnr.name
        @vornameZurPerson = @personZurPnr.vorname

        @vonDatum = @Buchung.first.Belegdatum.strftime("%d.%m.%Y")
        @bisDatum = Date.current().strftime("%d.%m.%Y")
        @vorBuchung = Buchung.where("KtoNr = ? AND Belegdatum < ? AND Typ = ?", params[:KtoNr], @vonDatum.to_date, "w").order("Belegdatum DESC").limit(1)

        if @vorBuchung.empty?
          @vorBuchung = @Buchung
        end

         @tagesSaldoSpalte = @vorBuchung.first.dup
         @tagesSaldoAltHaben = @vorBuchung.first.WSaldoAcc
         @tagesSaldoAltPunkte = @vorBuchung.first.Punkte

         @kklVerlaufKlasse = KklVerlauf.where("KtoNr = ?", params[:KtoNr]).order("KKLAbDatum DESC").limit(1).first.KKL
          @kklZhal = 1
          case @kklVerlaufKlasse
            when "A"
              @kklZhal = 1
            when "B"
              @kklZhal = 0.75
            when "C"
              @kklZhal = 0.50
            when "D"
              @kklZhal = 0.25
            when "E"
              @kklZhal = 0
          end

          @tageVorbuchungBisVonDat = (@vonDatum.to_date - @vorBuchung.first.Belegdatum.to_date).to_i

          @tagesSaldoALtGesamtPunkte = (((@tageVorbuchungBisVonDat * @tagesSaldoAltHaben) / 30) * @kklZhal) + @tagesSaldoAltPunkte
        #bestimmen und festlegen des vorigen Tagessaldos oberste zeile in der anzeige
        #bestimmung ob es soll oder haben ist
        if @tagesSaldoAltHaben > 0
            @tagesSaldoSpalte.Habenbetrag = @tagesSaldoAltHaben
            @tagesSaldoSpalte.Sollbetrag = "0"
          else
            @tagesSaldoSpalte.Habenbetrag = "0"
            @tagesSaldoSpalte.Sollbetrag = @tagesSaldoAltHaben * (-1)
          end   

        @tagesSaldoSpalte.Buchungstext = "Tagessaldo"
        @tagesSaldoSpalte.Typ = "w"
        @tagesSaldoSpalte.Belegdatum = @vonDatum
        @tagesSaldoSpalte.PSaldoAcc = @tagesSaldoALtGesamtPunkte

        #bestimmen der punkte in der ersten zeile
          @ersteZeilePunkte = (@vorBuchung.first.WSaldoAcc * (@Buchung.first.Belegdatum-@tagesSaldoSpalte.Belegdatum).to_i)/30 * @kklZhal
          @Buchung.first.PSaldoAcc = @ersteZeilePunkte
        
        @Buchung.push(@tagesSaldoSpalte)
        @Buchung.rotate!(-1)

        #bestimmen der zeile von tt.mm.yyyy bis tt.mm.yyyy
        @letztesBuchungsdatum = (@Buchung.last.Belegdatum)
          @buchungZumLeztenDatum = Buchung.where("KtoNr = ? AND Belegdatum <= ? AND Typ = ?", params[:KtoNr], @letztesBuchungsdatum, "w").order("Belegdatum DESC, HabenBetrag DESC")
          @saldoDesLetztenBuchdatums = @buchungZumLeztenDatum.first.WSaldoAcc

          @differenzDerDaten = (@bisDatum.to_date-@buchungZumLeztenDatum.first.Belegdatum.to_date).to_i

          @punkteZwischenDenDaten = (((@differenzDerDaten * @saldoDesLetztenBuchdatums) / 30) * @kklZhal).to_i

          @zeileDerPunkte = @Buchung.first.dup
          @zeileDerPunkte.Buchungstext = "Punkte von " + @buchungZumLeztenDatum.first.Belegdatum.strftime("%d.%m.%Y") + " bis " + @bisDatum
          @zeileDerPunkte.Belegdatum = @bisDatum
          @zeileDerPunkte.Sollbetrag = 0
          @zeileDerPunkte.Habenbetrag = 0
          @zeileDerPunkte.PSaldoAcc = @punkteZwischenDenDaten
          @zeileDerPunkte.WSaldoAcc = 0
          @zeileDerPunkte.Typ = "w"

          @Buchung.push(@zeileDerPunkte)

      #gab es noch keine buchungen wird eine warnung ausgegeben
      else
        @notice.push("In dem angegebenen Zeitraum gibt es noch keine Buchungen.")
      end
    #wurde der anzeigen button geklickt werden die buchungen in dem angegebenen zeitraum angezeigt
    else
      #prüfung ob ein ein datum in falschem format eingegeben wurde
      if !@vonDatum.to_s.empty? || !@bisDatum.to_s.empty?
        @Buchung = Buchung.where("KtoNr = ? AND Belegdatum >= ? AND Belegdatum <= ?", params[:KtoNr], params[:vonDatum].to_date, params[:bisDatum].to_date).order("Belegdatum Desc, SollBetrag ASC, Typ DESC, PSaldoAcc DESC").reverse
        #prüfung ob es überhaupt buchungen gab
        if !@Buchung.empty?
          @vorBuchung = Buchung.where("KtoNr = ? AND Belegdatum < ? AND Typ = ?", params[:KtoNr], @Buchung.first.Belegdatum, "w").order("BuchDatum DESC").limit(1)
          if params[:EEoZEkonto] == "ZE"
            if (@vorBuchung.empty? or @Buchung.first.PSaldoAcc == 0)
              @vorBuchung = @Buchung
              @wiederverwendungDesKontos = true
            end
          else
            if @vorBuchung.empty?
                @vorBuchung = @Buchung
            end
            @wiederverwendungDesKontos = false
          end

          if params[:EEoZEkonto] == "EE"
            @bankId = EeKonto.where("KtoNr = ?", params[:KtoNr]).first.bankId
          else
            @EeKtoNrZumZeKto = ZeKonto.where("KtoNr = ?", params[:KtoNr]).first.eeKtoNr
            @bankId = EeKonto.where("KtoNr = ?", @EeKtoNrZumZeKto).first.bankId
          end

          @pnrDesInhabers = Bankverbindung.where("ID = ?", @bankId).first.pnr
          @personZurPnr = Person.where("Pnr = ?", @pnrDesInhabers).first
          @nameZurPerson = @personZurPnr.name
          @vornameZurPerson = @personZurPnr.vorname



            #bestimmen und festlegen des vorigen Tagessaldos
          @tagesSaldoSpalte = @vorBuchung.first.dup

          @kklVerlaufKlasse = KklVerlauf.where("KtoNr = ?", params[:KtoNr]).order("KKLAbDatum DESC").limit(1).first.KKL
          @kklZhal = 1
          case @kklVerlaufKlasse
            when "A"
              @kklZhal = 1
            when "B"
              @kklZhal = 0.75
            when "C"
              @kklZhal = 0.50
            when "D"
              @kklZhal = 0.25
            when "E"
              @kklZhal = 0
          end
          

          if !@wiederverwendungDesKontos
            @tagesSaldoAltHaben = @vorBuchung.first.WSaldoAcc
            @tagesSaldoAltPunkte = @vorBuchung.first.Punkte


            @tageVorbuchungBisVonDat = (params[:vonDatum].to_date - @vorBuchung.first.Belegdatum).to_i

            @tagesSaldoALtGesamtPunkte = (((@tageVorbuchungBisVonDat * @tagesSaldoAltHaben) / 30) * @kklZhal) + @tagesSaldoAltPunkte
            #bestimmung ob es soll oder haben ist
            if @tagesSaldoAltHaben > 0
              @tagesSaldoSpalte.Habenbetrag = @tagesSaldoAltHaben
              @tagesSaldoSpalte.Sollbetrag = "0"
            else
              @tagesSaldoSpalte.Habenbetrag = "0"
              @tagesSaldoSpalte.Sollbetrag = @tagesSaldoAltHaben * (-1)
            end  
            @tagesSaldoSpalte.Buchungstext = "Tagessaldo"
            @tagesSaldoSpalte.Typ = "w"
            @tagesSaldoSpalte.Belegdatum = params[:vonDatum]
            @tagesSaldoSpalte.PSaldoAcc = @tagesSaldoALtGesamtPunkte
          else
            @tagesSaldoSpalte.Habenbetrag = 0
            @tagesSaldoSpalte.Sollbetrag = 0
            @tagesSaldoSpalte.Buchungstext = "Tagessaldo"
            @tagesSaldoSpalte.Typ = "w"
            @tagesSaldoSpalte.Belegdatum = params[:vonDatum]
            @tagesSaldoSpalte.PSaldoAcc = 0
          end

          #bestimmen der punkte in der ersten zeile
          @ersteZeilePunkte = (@vorBuchung.first.WSaldoAcc * (@Buchung.first.Belegdatum-@tagesSaldoSpalte.Belegdatum).to_i)/30 * @kklZhal
          @Buchung.first.PSaldoAcc = @ersteZeilePunkte

          @Buchung.push(@tagesSaldoSpalte)
          @Buchung.rotate!(-1)

          #bestimmung der zeile punkte vom tt.mm.yyyy bis tt.mm.yyyy
          @letztesBuchungsdatum = (@Buchung.last.Belegdatum)
          @buchungZumLeztenDatum = Buchung.where("KtoNr = ? AND Belegdatum <= ? AND Typ = ?", params[:KtoNr], @letztesBuchungsdatum, "w").order("Belegdatum DESC, HabenBetrag DESC")
          @saldoDesLetztenBuchdatums = @buchungZumLeztenDatum.first.WSaldoAcc

          @differenzDerDaten = (params[:bisDatum].to_date-@buchungZumLeztenDatum.first.Belegdatum.to_date).to_i

          @punkteZwischenDenDaten = (((@differenzDerDaten * @saldoDesLetztenBuchdatums) / 30) * @kklZhal).to_i

          @zeileDerPunkte = @Buchung.first.dup
          @zeileDerPunkte.Buchungstext = "Punkte von " + @buchungZumLeztenDatum.first.Belegdatum.strftime("%d.%m.%Y") + " bis " + params[:bisDatum]
          @zeileDerPunkte.Belegdatum = params[:bisDatum]
          @zeileDerPunkte.Sollbetrag = 0
          @zeileDerPunkte.Habenbetrag = 0
          @zeileDerPunkte.PSaldoAcc = @punkteZwischenDenDaten
          @zeileDerPunkte.WSaldoAcc = 0
          @zeileDerPunkte.Typ = "w"

          @Buchung.push(@zeileDerPunkte)
        #gab es keine buchungen wird eine warnung ausgegeben
        else
          @notice.push("In dem angegebenen Zeitraum gibt es noch keine Buchungen.")
        end
      #wurde ein datum in falschem format eingegeben wird eine fehlermeldung ausgegeben
      else
        @errors.push("Geben sie bitte ein valides Datum ein.")
      end
    end

    #wenn es buchungen gibt wird bestimmt ob es sich um eine währungs oder um eine punkte buchung handelt
    if !@Buchung.nil? && !@Buchung.empty? 
      @Buchung.each do |buchung|
        #ist es eine währungsbuchung
        if buchung.Typ == "w"
          @summeDerPunkte += buchung.PSaldoAcc
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
      # @summeDerPunkte -= @Buchung.first.PSaldoAcc
      # @summeSoll -= @Buchung.first.Sollbetrag
      # @summeHaben -= @Buchung.first.HabenBetrag
      
      @differenzSollHaben = @summeHaben - @summeSoll
    end
  end



  def kontoauszug
    @Buchung = Buchung.where("KtoNr = ? AND Belegdatum >= ? AND Belegdatum <= ?", params[:ktoNr].to_i, params[:vonDat], params[:bisDat]).order("Belegdatum Desc, SollBetrag ASC, Typ DESC, PSaldoAcc DESC").reverse
    @vorBuchung = Buchung.where("KtoNr = ? AND Belegdatum < ? AND Typ = ?", params[:ktoNr].to_i, params[:vonDat], "w").order("Belegdatum DESC").limit(1)


    if params[:EEoZEkonto] == "ZE"
      if (@vorBuchung.empty? or @Buchung.first.PSaldoAcc == 0)
        @vorBuchung = @Buchung
        @wiederverwendungDesKontos = true
      end
    else
      if @vorBuchung.empty?
          @vorBuchung = @Buchung
      end
      @wiederverwendungDesKontos = false
    end
    @tagesSaldoSpalte = @vorBuchung.first.dup

    @kklVerlaufKlasse = KklVerlauf.where("KtoNr = ?", params[:ktoNr].to_i).order("KKLAbDatum DESC").limit(1).first.KKL
    @kklZhal = 1
    case @kklVerlaufKlasse
      when "A"
        @kklZhal = 1
      when "B"
        @kklZhal = 0.75
      when "C"
        @kklZhal = 0.50
      when "D"
        @kklZhal = 0.25
      when "E"
        @kklZhal = 0
    end

    if !@wiederverwendungDesKontos
    @tagesSaldoAltHaben = @vorBuchung.first.WSaldoAcc
    @tagesSaldoAltPunkte = @vorBuchung.first.Punkte
    @tageVorbuchungBisVonDat = (params[:vonDat].to_date - @vorBuchung.first.Belegdatum).to_i
    @tagesSaldoALtGesamtPunkte = (((@tageVorbuchungBisVonDat * @tagesSaldoAltHaben) / 30) * @kklZhal) + @tagesSaldoAltPunkte

    #bestimmung ob es soll oder haben ist
    if @tagesSaldoAltHaben > 0
      @tagesSaldoSpalte.Habenbetrag = @tagesSaldoAltHaben
      @tagesSaldoSpalte.Sollbetrag = "0"
    else
      @tagesSaldoSpalte.Habenbetrag = "0"
      @tagesSaldoSpalte.Sollbetrag = @tagesSaldoAltHaben * (-1)
    end

    @tagesSaldoSpalte.Buchungstext = "Tagessaldo"
    @tagesSaldoSpalte.Typ = "w"
    @tagesSaldoSpalte.Belegdatum = params[:vonDat]
    @tagesSaldoSpalte.PSaldoAcc = @tagesSaldoALtGesamtPunkte
    else
      @tagesSaldoSpalte.Habenbetrag = 0
      @tagesSaldoSpalte.Sollbetrag = 0
      @tagesSaldoSpalte.Buchungstext = "Tagessaldo"
      @tagesSaldoSpalte.Typ = "w"
      @tagesSaldoSpalte.Belegdatum = params[:vonDat]
      @tagesSaldoSpalte.PSaldoAcc = 0
    end

    #bestimmen der punkte in der ersten zeile
          @ersteZeilePunkte = (@vorBuchung.first.WSaldoAcc * (@Buchung.first.Belegdatum-@tagesSaldoSpalte.Belegdatum).to_i)/30 * @kklZhal
          @Buchung.first.PSaldoAcc = @ersteZeilePunkte

    @Buchung.push(@tagesSaldoSpalte)
    @Buchung.rotate!(-1)

    #bestimmung der zeile punkte vom tt.mm.yyyy bis tt.mm.yyyy
    @letztesBuchungsdatum = (@Buchung.last.Belegdatum)
    @buchungZumLeztenDatum = Buchung.where("KtoNr = ? AND Belegdatum <= ? AND Typ = ?", params[:ktoNr], @letztesBuchungsdatum, "w").order("Belegdatum DESC, HabenBetrag DESC")
    @saldoDesLetztenBuchdatums = @buchungZumLeztenDatum.first.WSaldoAcc

    @differenzDerDaten = (params[:bisDat].to_date-@buchungZumLeztenDatum.first.Belegdatum.to_date).to_i

    @punkteZwischenDenDaten = (((@differenzDerDaten * @saldoDesLetztenBuchdatums) / 30) * @kklZhal).to_i

    @zeileDerPunkte = @Buchung.first.dup
    @zeileDerPunkte.Buchungstext = "Punkte von " + @buchungZumLeztenDatum.first.Belegdatum.strftime("%d.%m.%Y") + " bis " + params[:bisDat]
    @zeileDerPunkte.Belegdatum = params[:bisDat]
    @zeileDerPunkte.Sollbetrag = 0
    @zeileDerPunkte.Habenbetrag = 0
    @zeileDerPunkte.PSaldoAcc = @punkteZwischenDenDaten
    @zeileDerPunkte.WSaldoAcc = 0
    @zeileDerPunkte.Typ = "w"

    @Buchung.push(@zeileDerPunkte)

    @summeDerPunkte = 0
    @summeSoll = 0
    @summeHaben = 0

    if !@Buchung.nil? && !@Buchung.empty? 
    @Buchung.each do |buchung|
      #ist es eine währungsbuchung
      if buchung.Typ == "w"
        @summeDerPunkte += buchung.PSaldoAcc
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
  end
  end
end
