# encoding: UTF-8
class EEKonto < ActiveRecord::Base

  set_table_name "EEKonto"   

  attr_accessible :ktoNr, :bankId, :kreditlimit

  set_primary_key :ktoNr

  belongs_to :OZBKonto
  belongs_to :Bankverbindung
  has_one :ZEKonto, :foreign_key => :ktoNr # Done, getestet

  def validate!
    errors = ActiveModel::Errors.new(self)
    
    # Kontonummer
    if self.ktoNr.nil? then
      errors.add("", "Bitte geben sie eine Kontonummer an.")
    else
      if !self.ktoNr.to_s.match('\d+') then
        errors.add("", "Die Kontonummer muss eine Zahl sein.")
      end
    end
    
    # Bankverbindung
    if self.bankId.nil? then
      errors.add("", "Bitte geben sie eine Bankverbindung an.")
    end
    
    # Kreditlimit
    if self.kreditlimit.nil? then
      errors.add("", "Bitte geben sie ein gültiges Kreditlimit (>0) an.")
    else
      if !self.kreditlimit.to_s.match('\d+') then
        errors.add("", "Bitte geben sie einen gültigen Zahlenwert > 0 an.")
      else
        if self.kreditlimit < 0 then
          errors.add("", "Bitte geben Sie einen positiven Zahlenwert für das Kreditlimit an.")
        end
      end
    end

    return errors
  end

end
