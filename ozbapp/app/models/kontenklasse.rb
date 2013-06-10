# encoding: UTF-8
class Kontenklasse < ActiveRecord::Base
  self.table_name = "KontenKlasse"
  self.primary_key = :KKL
  
  # aliases
  alias_attribute :kkl, :KKL
  alias_attribute :prozent, :Prozent
  
  # attributes
  attr_accessible :KKL, :KKLAbDatum, :Prozent, :kkl_with_percent

  # associations
  has_many :KKLVerlauf,
    :foreign_key => :KKL # no one or many
  
  # validations
  validates :KKL, 
    :presence => { :format => { :with => /[0-9]+/  },
      :message => "Bitte geben Sie eine Klasse an." }, 
    :length => { :is => 1, :message => "Die Klasse darf nur ein Zeichen lang sein." }, 
    :numericality => { :only_integer => true, 
      :message => "Die Klasse darf nur Zahlen beinhalten." }
  
  validates :KKLAbDatum, 
    :presence => { :format => { :with => /\d{4}-\d{2}-\d{2}/ }, 
      :message => "Bitte geben Sie eine gültiges Kontenklassenverlaufdatum an." }
  validates :Prozent, 
    :presence => { :message => "Bitte geben Sie einen Prozentsatz an." }, 
    :numericality => { :greater_than_or_equal_to => 0, 
      :message => "Der Prozentsatz muss positiv sein." },
    :format => { :with => /^\d{1,5}[.]?\d{1,2}$/, #0.00 .. 99999.99 (siehe create_tables)
      :message => "Bitte geben Sie einen gültigen Prozentsatz an." }

  
  # column names
  HUMANIZED_ATTRIBUTES = {
    :KKL        => 'Kontenklasse',
    :KKLAbDatum => 'Ab Datum',
    :Prozent    => 'Prozentsatz'
  }

  def self.human_attribute_name(attr, options={})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end
  
  # Liefert einen detaillierten String mit dem Prozentsatz
  def kkl_with_percent
    "Klasse " + kkl.to_s + " - " + sprintf("%3.2f", prozent) + "%"
  end
end