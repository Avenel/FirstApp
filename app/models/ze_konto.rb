# encoding: UTF-8
class ZEKonto < ActiveRecord::Base

  set_table_name "ZEKonto"

  attr_accessible :ktoNr, :eeKtoNr, :pgNr, :zeNr, :zeAbDatum, :zeEndDatum, :zeBetrag, 
                  :laufzeit, :zahlModus, :tilgRate, :ansparRate, :kduRate, :rduRate, :zeStatus
  
  set_primary_key :ktoNr
  
  belongs_to :OZBKonto
  belongs_to :EEKonto
  has_many :Buergschaft, :foreign_key => :ktoNr # Done, getestet
  belongs_to :Projektgruppe, :inverse_of => :ZEKonto, :foreign_key => :pgNr # Done, getestet
  
  def validate!
    errors = ActiveModel::Errors.new(self)
    
    # Kontonummer
    if self.ktoNr.nil? then
      errors.add("", "Bitte geben sie eine Kontonummer an.")
    else
      if self.ktoNr.to_s.match(/[0-9]+/).nil? then
        erros.add("", "Die Kontonummer muss eine Zahl sein.")
      end
    end
    
    # EE-Kontonummer
    if self.eeKtoNr.nil? then
      errors.add("", "Bitte geben sie ein EEKonto an.")
    else
      if self.ktoNr.to_s.match(/[0-9]+/).nil? then
        errors.add("", "Die Kontonummer (EEKonto) muss eine Zahl sein.")
      end
    end
    
    # Projektgruppe
    if !self.pgNr.nil? then
      if self.pgNr.to_s.match(/[0-9]+/).nil? then
        errors.add("", "Die Projektgruppennummer muss eine Zahl sein.")
      end
    end
    
    # ZE-Nummer
    if self.zeNr.nil? then
      errors.add("", "Bitte geben sie ein ZE Nummer an.")
    else
      if self.zeNr.to_s.match(/[0-9]+/).nil? then
        errors.add("", "Die ZE Nummer muss eine Zahl sein.")
      end
    end
      
    # zeAbDatum
    if !self.zeAbDatum.nil? then
      if self.zeAbDatum.to_s.match(/[0-9]{4}-[0-9][0-9]-[0-9][0-9]/).nil? then
        errors.add("", "Bitte geben sie das ZE Ab-Datum im Format: yyyy-mm-dd an.")
      end
    end
    
    # zeEndeDatum
    if !self.zeEndDatum.nil? then
      if self.zeEndDatum.to_s.match(/[0-9]{4}-[0-9][0-9]-[0-9][0-9]/).nil? then
        errors.add("", "Bitte geben sie das ZE End-Datum im Format: yyyy-mm-dd an.")
      end
    end
    
    # Betrag
    if !self.zeBetrag.nil? then
      if self.zeBetrag.to_s.match(/[0-9]+/).nil? then
        errors.add("", "Der Betrag muss eine Zahl sein.")
      else
        if self.zeBetrag < 0 then
          errors.add("", "Bitte geben Sie einen positiven Zahlenwert für den ZE Betrag an.")
        end
      end
    end
  
    # Laufzeit
    if !self.laufzeit.nil? then
      if self.laufzeit.to_s.match(/[0-9]+/).nil? then
        errors.add("", "Die Laufzeit muss eine Zahl sein.")
      else
        if self.laufzeit < 0 then
          errors.add("", "Bitte geben Sie einen positiven Zahlenwert für die Laufzeit an.")
        end
      end
    end
  
    # ZahlModus
    if !self.zahlModus.nil? then
      if self.zahlModus.to_s.match(/./).nil? then
        errors.add("", "Der Zahlmodus muss ein Buchstabe sein.")
      end
    end
    
    # Tilgungsrate
    if !self.tilgRate.nil? then
      if self.tilgRate.to_s.match(/[0-9]+/).nil? then
        errors.add("", "Die Tilgungsrate muss eine Zahl sein.")
      else
        if self.tilgRate < 0 then
          errors.add("", "Bitte geben Sie einen positiven Zahlenwert für die Tilgungsrate an.")
        end
      end
    end
    
    # Ansparrate
    if !self.ansparRate.nil? then
      if self.ansparRate.to_s.match(/[0-9]+/).nil? then
        errors.add("", "Die Ansparrate muss eine Zahl sein.")
      else
        if self.ansparRate < 0 then
          errors.add("", "Bitte geben Sie einen positiven Zahlenwert für die Ansparrate an.")
        end
      end
    end
    
    # Kdu Rate
    if !self.kduRate.nil? then
      if self.kduRate.to_s.match(/[0-9]+/).nil? then
        errors.add("", "Die kduRate muss eine Zahl sein.")
      else
        if self.kduRate < 0 then
          errors.add("", "Bitte geben Sie einen positiven Zahlenwert für die kduRate an.")
        end
      end
    end
    
    # Rdu Rate
    if !self.rduRate.nil? then
      if self.rduRate.to_s.match(/[0-9]+/).nil? then
        errors.add("", "Die rduRate muss eine Zahl sein.")
      else
        if self.rduRate < 0 then
          errors.add("", "Bitte geben Sie einen positiven Zahlenwert für die rduRate an.")
        end
      end
    end
    
    return errors
  end
  
end
