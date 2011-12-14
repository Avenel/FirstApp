# encoding: UTF-8
class Buergschaft < ActiveRecord::Base 
  set_table_name "Buergschaft"   
   
  attr_accessible  :pnrB, :mnrG, :ktoNr, :sichAbDatum, :sichEndDatum, :sichBetrag, :sichKurzBez
  set_primary_keys :pnrB, :mnrG
   
  belongs_to :person
  belongs_to :OZBPerson
  belongs_to :ZEKonto
  
  def refresh
    errors = ActiveModel::Errors.new(self)
  end
  
  def validate!
    errors.add(:pnrB, "Personalnummer des Bürgschafters darf nicht leer sein.") if pnrB == nil
    errors.add(:mnrG, "Mitgliedsnummer des Gesellschafters darf nicht leer sein.") if mnrG == nil
    errors.add(:ktoNr, "Die Kontonummer darf nicht leer sein.") if ktoNr == nil
  end
  
end
