class DarlehensvertragController < ApplicationController

	def new

	end

	def anzeigen
    @errors = Array.new
    @person = Person.where("Pnr = ?", params[:mitgliedsnummer])
    if !@person.empty?
      @mitgliedsnummer = params[:mitgliedsnummer]
      @nachname = @person.first.Name
      @vorname = @person.first.Vorname
    else
      @errors.push("Die angegebene Mitgliedsnummer konnte nicht gefunden werden.")
      render :new
    end
    @heutigesDatum = Date.today.to_date.strftime("%d.%m.%Y")
	end

  def berechnen
    @kklVerlauf = params[:kklVerlauf]
    @errors = Array.new
    @person = Person.where("Pnr = ?", params[:mitgliedsnummer])
    @mitgliedsnummer = params[:mitgliedsnummer]
    @hoeheDerZE = params[:hoeheDerZE]
    @eigSparPunkte = params[:eigSparPunkte]
    @schenkungspunkte = params[:schenkungspunkte]
    @gewAuszahlDat = nil
    if (params[:gewAuszahlDat] =~ /[0-9]{2}.[0-9]{2}.[0-9]{4}/)
      @gewAuszahlDat = params[:gewAuszahlDat]
    end
    @tilgZeitInJahren = params[:tilgZeitInJahren]
    @nachsparZeitInJahren = params[:nachsparZeitInJahren]
    @datDerErstenTilgRate = nil
    if (params[:datDerErstenTilgRate] =~ /[0-9]{2}.[0-9]{2}.[0-9]{4}/)
      @datDerErstenTilgRate = params[:datDerErstenTilgRate]
    end
    @sparguthaben = params[:sparguthaben]
    @heutigesDatum = nil
    if (params[:heutigesDatum] =~ /[0-9]{2}.[0-9]{2}.[0-9]{4}/)
      @heutigesDatum = params[:heutigesDatum]
    end
    @auszugsDatum = nil
    if (params[:auszugsDatum] =~ /[0-9]{2}.[0-9]{2}.[0-9]{4}/)
      @auszugsDatum = params[:auszugsDatum]
    end

    if @person.empty?
      @errors.push("Die angegebene Mitgliedsnummer konnte nicht gefunden werden.")
    else
      @nachname = @person.first.Name
      @vorname = @person.first.Vorname
    end
    if @mitgliedsnummer.to_i == 0
      @errors.push("Geben sie bitte eine Korrekte Mitgliedsnummer ein.")
    end
    if @hoeheDerZE.to_f == 0
      @errors.push("Geben sie bitte eine Korrekte Zusatzentnahme ein")
    end
    if @eigSparPunkte.is_a? Integer
      @errors.push("Geben sie bitte die Eigenen Sparpunkte korrekt ein")
    end
    if @schenkungspunkte.is_a? Integer 
      @errors.push("Geben sie bitte die Schenkungspunkte korrekt ein")
    end 
    if @gewAuszahlDat.nil?()
      @errors.push("Geben sie bitte ein Valides Gewuenschtes Auszahlungsdatum ein")
    end
    if @tilgZeitInJahren.to_i == 0
      @errors.push("Geben sie bitte die Tilgungszeit in Jahren korrekt ein")
    end
    if @datDerErstenTilgRate.nil?
      @errors.push("Geben sie bitte das Datum der 1. Tilgungrate korrekt ein")
    end
    if @sparguthaben.is_a? Float
      @errors.push("Geben sie bitte das Sparguthaben korrekt ein")
    end
    if @heutigesDatum.nil?
      @errors.push("Geben sie bitte das heutige Datum korrekt ein")
    end
    if @auszugsDatum.nil?
      @errors.push("Geben sie bitte das Auszugs Datum korrekt ein")
    end
    

    if @errors.empty?

      case @kklVerlauf
      when "Klasse A - 100.00%"
        @kontenKlasse = 1.00
      when "Klasse B - 75.00%"
        @kontenKlasse = 0.75
      when "Klasse C - 50.00%"
        @kontenKlasse = 0.50
      when "Klasse D - 25.00%"
        @kontenKlasse = 0.25
      when "Klasse E - 0.00%"
        @kontenKlasse = 0.00
      end

      @tilgInMonaten = @tilgZeitInJahren.to_i * 12

      @leihpunkteAuszahlungErsteRate = ((@datDerErstenTilgRate.to_date - @gewAuszahlDat.to_date).to_i) * @hoeheDerZE.to_i / 30

      @leihpunkteTilgungszeitraum = @tilgZeitInJahren.to_i * 12 * @hoeheDerZE.to_f/2
      @leihpunteGesammt = @leihpunkteAuszahlungErsteRate + @leihpunkteTilgungszeitraum

      @sparpunkteInsgesamt = @eigSparPunkte.to_i + @schenkungspunkte.to_i
      if @kontenKlasse != 0
        @sparpunkteBisHeute = @sparpunkteInsgesamt + ((@heutigesDatum.to_date - @auszugsDatum.to_date) * @sparguthaben.to_i / 30 * @kontenKlasse)
        @sparpunkteBisAuszahlung = (@sparpunkteBisHeute + ((@gewAuszahlDat.to_date - @heutigesDatum.to_date) * @sparguthaben.to_i / 30 * @kontenKlasse)).to_i
      else
        @sparpunkteBisHeute = @sparpunkteInsgesamt + ((@heutigesDatum.to_date - @auszugsDatum.to_date) * @sparguthaben.to_i / 30)
        @sparpunkteBisAuszahlung = (@sparpunkteBisHeute + ((@gewAuszahlDat.to_date - @heutigesDatum.to_date) * @sparguthaben.to_i / 30)).to_i      
      end

      @nachsparpunkte = @leihpunteGesammt - @sparpunkteBisAuszahlung

      if @kontenKlasse != 0
        if @hoeheDerZE.to_f < ((2*@nachsparpunkte)/(12*@nachsparZeitInJahren.to_i))
          @nachsparBetrag = ((2*@nachsparpunkte)/(12*@nachsparZeitInJahren.to_i))/@kontenKlasse
        else
          @nachsparBetrag = @hoeheDerZE.to_f/@kontenKlasse
        end        
      else
        if @hoeheDerZE.to_f < ((2*@nachsparpunkte)/(12*@nachsparZeitInJahren.to_i))
          @nachsparBetrag = ((2*@nachsparpunkte)/(12*@nachsparZeitInJahren.to_i))
        else
          @nachsparBetrag = @hoeheDerZE.to_f
        end        
      end

      @monatlicheDarlehenstilgung = @hoeheDerZE.to_f/(12*@tilgZeitInJahren.to_d)
      @monatlicherBetragNachsparen = @nachsparBetrag/(12*@nachsparZeitInJahren.to_d)

      @rdu = Umlage.where("Jahr = ?", @tilgZeitInJahren.to_i).first.RDU / 100
      @kdu = Umlage.where("Jahr = ?", @tilgZeitInJahren.to_i).first.KDU / 100

      @risikoDekungsbeitrag = @hoeheDerZE.to_f * @rdu / 12
      @kostendeckungsumlage = @hoeheDerZE.to_f * @kdu / 12
      @monatlicheGesammtbeslastung = @monatlicheDarlehenstilgung + @monatlicherBetragNachsparen + @risikoDekungsbeitrag

      render :anzeigen
    else
      render :anzeigen
    end
  end
end
