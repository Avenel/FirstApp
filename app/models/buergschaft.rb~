# encoding: UTF-8
class Buergschaft < ActiveRecord::Base 
  set_table_name "Buergschaft"   
   
  attr_accessible  :pnrB, :mnrG, :ktoNr, :sichAbDatum, :sichEndDatum, :sichBetrag, :sichKurzBez
  set_primary_keys :pnrB, :mnrG
   
  belongs_to :person
  belongs_to :OZBPerson
  belongs_to :ZEKonto
  
  def validate!    
    errors = ActiveModel::Errors.new(self)
    person = nil
    
    # Bürgschafter
    if self.pnrB == nil then
      errors.add("", "Personalnummer des Bürgschafters darf nicht leer sein.")
    else
      person = Person.find(self.pnrB)
    end
   
    if person.nil? && self.pnrB != "" then 
      errors.add("", "Personalnummer konnte in der Datenbank nicht gefunden werden.")
    else
      if person.rolle != "B" then 
        errors.add("", "Es sind nur Bürgschafter erlaubt.")
      end
    end
    
    # Gesellschafter
    person = nil
    if self.mnrG == nil then
      errors.add("", "Mitgliedsnummer des Gesellschafters darf nicht leer sein.") 
    else
      person = Person.find(self.mnrG)
    end
    
    if person.nil? && self.mnrG != "" then 
      errors.add("", "Personalnummer konnte in der Datenbank nicht gefunden werden.")
    else
      if person.rolle != "G" then 
        errors.add("", "Es sind nur Gesellschafter erlaubt.")
      end
    end
    
    # Kontonummer
    if self.ktoNr == nil then
      errors.add("", "Die Kontonummer darf nicht leer sein.")
    end
    
    # Sicherheitsbetrag
    if self.sichBetrag.nil? then 
      errors.add("", "Bitte geben Sie einen Sicherheitsbetrag größer 0 an.")
    end
    
    if !self.sichBetrag.nil? && self.sichBetrag < 0 then 
      errors.add("", "Bitte geben Sie einen Sicherheitsbetrag größer 0 an.")
    end
    
    
    return errors
  end
  
end
