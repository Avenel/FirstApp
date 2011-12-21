# encoding: UTF-8
class Kontenklasse < ActiveRecord::Base

  set_table_name "Kontenklasse"

  attr_accessible :kkl, :kklAbDatum, :prozent
  set_primary_key :kkl

  has_many :KKLVerlauf, :foreign_key => :kkl # Done, ungetestet

  def validate!
    errors = ActiveModel::Errors.new(self)

    if self.kkl.nil? then
      errors.add("", "Kontenklasse darf nicht leer sein.")
    end
    
    if self.prozent < 0 then
      errors.add("","Bitte geben sie einen Prozentwert größer 0 an.")
    end
    
    if self.kklAbDatum.nil? then
      errors.add("", "Bitte geben sie ein Datum an.")
    end
    
    return errors
  end

end
