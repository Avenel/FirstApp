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
  validates :KKL, :presence => { :format => { :with => /[0-9]+/ }, :message => "Bitte geben Sie eine gültige Klasse an." }
  validates :KKLAbDatum, :presence => { :format => { :with => /\d{4}-\d{2}-\d{2}/ }, :message => "Bitte geben Sie eine gültiges Kontenklassenverlaufdatum an." }
  validates :Prozent, :presence => { :format => { :with => /[0-9]+/ }, :message => "Bitte geben Sie einen gültigen Prozentsatz an." }
  
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