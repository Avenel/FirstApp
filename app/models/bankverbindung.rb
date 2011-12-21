# encoding: UTF-8
class Bankverbindung < ActiveRecord::Base
   
  set_table_name "Bankverbindung"

  set_primary_key :id

  attr_accessible :id, :pnr, :bankKtoNr, :blz, :bic, :iban, :bankName   

  belongs_to :Person
  has_one :EEKonto, :foreign_key => :bankId # Done, getestet


  def validate!
    errors = ActiveModel::Errors.new(self)

    if self.pnr.nil? then
      errors.add("", "Bitte geben Sie eine Personalnummer an.")
    end
    
    if self.bankKtoNr.nil? then
      errors.add("", "Bitte geben Sie eine Bankkontonummer an.")
    else
      if self.bankKtoNr.to_s.match(/[0-9]+/).nil? then
        errors.add("", "Bitte geben Sie eine gültige Bankkonto-Nummer an.")
      end
    end
    
    if (self.blz.nil? or self.blz == "") and (self.bic.nil? or self.bic == "") and (self.iban.nil? or self.iban == "") then
      errors.add("", "Bitte geben Sie mindestens eine BLZ, BIC oder IBAN an.")
    end
    
    if !self.blz.nil? and self.blz != "" then
      if self.blz.to_s.match(/[0-9]+/).nil? then
        errors.add("", "Bitte geben Sie eine gültige Bankleitzahl ein.")
      end
    end

    if !self.bic.nil? and self.bic != "" then
      if self.bic.to_s.match(/[0-9]+/).nil? then
        errors.add("", "Bitte geben Sie einen gültigen BIC ein.")
      end
    end
    
    if self.bankName.nil? or self.bankName == "" then
      errors.add("", "Bitte geben Sie den Namen der Bank ein.")
    end
    
    # Nice to have: IBAN Validierung
    
    return errors 
  end

end
