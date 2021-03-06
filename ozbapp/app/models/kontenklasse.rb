# encoding: UTF-8
class Kontenklasse < ActiveRecord::Base

  self.table_name = "KontenKlasse"
  self.primary_key = :KKL
  
  # attributes
  attr_accessible :KKL, :KKLEinrDatum, :Prozent, :kkl_with_percent

  # column names
  HUMANIZED_ATTRIBUTES = {
    :KKL        => 'Kontenklasse',
    :KKLEinrDatum => 'Einrichtungsdatum',
    :Prozent    => 'Prozentsatz'
  }

  def self.human_attribute_name(attr, options={})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end
 
  
  # Validations
  validates :KKL, 
    :presence => { :format => { :with => /^[A-Z]{1}$/i  },
      :message => "Bitte geben Sie eine Klasse an." }, 
    :length => { :is => 1, :message => "Die Klasse darf nur ein Zeichen lang sein." }
  
  validates :KKLEinrDatum, 
    :presence => { :format => { :with => /\d{4}-\d{2}-\d{2}/ }, 
      :message => "Bitte geben Sie eine gültiges Kontenklassenverlaufdatum an." }
      
  validates :Prozent, 
    :presence => { :message => "Bitte geben Sie einen Prozentsatz an." }, 
    :numericality => { :greater_than_or_equal_to => 0, 
      :message => "Der Prozentsatz muss positiv sein." },
    :format => { :with => /^\d{1,3}[.]?\d{1,2}$/, #0.00 .. 999.99 (siehe create_tables)
      :message => "Bitte geben Sie einen gültigen Prozentsatz an." }


   # Associations
  has_many :KKLVerlauf,
    :foreign_key => :KKL
  
  # Liefert einen detaillierten String mit dem Prozentsatz
  def kkl_with_percent
    "Klasse " + self.KKL.to_s + " - " + sprintf("%3.2f", self.Prozent) + "%"
  end

end