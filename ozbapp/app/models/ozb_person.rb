# encoding: UTF-8
class OZBPerson < ActiveRecord::Base
  self.table_name = "OZBPerson"
  self.primary_key = :Mnr
  
  alias_attribute :mnr, :Mnr
  alias_attribute :ueberPnr, :UeberPnr
  alias_attribute :pwAendDatum, :PWAendDatum
  alias_attribute :antragsdatum, :Antragsdatum
  alias_attribute :aufnahmedatum, :Aufnahmedatum
  alias_attribute :austrittsdatum, :Austrittsdatum
  alias_attribute :schulungsdatum, :Schulungsdatum
  alias_attribute :gesperrt, :Gesperrt
  alias_attribute :sachPnr, :SachPnr
  
  attr_accessible :Mnr, :UeberPnr, :PWAendDatum, 
                  :Antragsdatum, :Aufnahmedatum, :Austrittsdatum, :Schulungsdatum, :SachPnr

  # column names
  HUMANIZED_ATTRIBUTES = {
    :Mnr            => 'Mitglied-Nr.',
    :Antragsdatum   => 'Antragsdatum',
    :Aufnahmedatum  => 'Aufnahmedatum',
    :Austrittsdatum => 'Austrittsdatum',
    :Schulungsdatum => 'Schulungsdatum'    
  }

  def self.human_attribute_name(attr, options={})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  # Validations
  validates :Mnr, :presence => true
  validates :Antragsdatum, :presence => true
  
  # technical attributes
  # obsolet
  # validate :password_complexity
  validate :person_exists

  def person_exists
    person = Person.where("pnr = ?", mnr)
    if person.empty? then
      errorString = String.new("Es konnte keine zugehörige Person zu der angegebenen Mnr (#{mnr}) gefunden werden.")
      errors.add :mnr, errorString
      return false
    end
    return true
  end

  # Relations
  # Note: These are relations which correspond with the db schema. There 
  #       are further relations (Person, OZBKonto) which don't work with 
  #       with the db schema, but never the less exist. If necessesary
  #       there are ways to implement them, like in the OZBKonto model.
  has_many :BuchungOnline, :foreign_key => :Mnr
  belongs_to :Person, :foreign_key => :Mnr
end