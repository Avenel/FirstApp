# encoding: UTF-8
class OZBPerson < ActiveRecord::Base

  self.table_name = "OZBPerson"
  self.primary_key = :Mnr

  # attributes  
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

  # Associations
  has_many :BuchungOnline, :foreign_key => :Mnr
  belongs_to :Person, :foreign_key => :Mnr
end