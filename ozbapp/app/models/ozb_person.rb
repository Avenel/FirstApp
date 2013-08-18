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
    person = Person.where("pnr = ?", self.Mnr)
    if person.empty? then
      errorString = String.new("Es konnte keine zugehörige Person zu der angegebenen Mnr (#{mnr}) gefunden werden.")
      errors.add :mnr, errorString
      return false
    end
    return true
  end

  # Associations
  has_many :Sonderberechtigung,
    :primary_key => :Mnr, # column in Sonderberechtigung 
    :foreign_key => :Mnr # column in OZBPerson

  belongs_to :Person,
    :primary_key => :Pnr,
    :foreign_key => :Mnr,
    # Nur mit der aktuellsten Version der Person verknüpfen 
    :conditions => proc { ["GueltigBis = ?", "9999-12-31 23:59:59"] }

  has_one :Gesellschafter,
    :primary_key => :Mnr,
    :foreign_key => :Mnr,
    # Nur mit der aktuellsten Version verknüpfen 
    :conditions => proc { ["GueltigBis = ?", "9999-12-31 23:59:59"] }   

  has_one :Partner,
    :primary_key => :Mnr,
    :foreign_key => :Mnr,
    # Nur mit der aktuellsten Version verknüpfen 
    :conditions => proc { ["GueltigBis = ?", "9999-12-31 23:59:59"] }

  has_one :Mitglied,
    :primary_key => :Mnr,
    :foreign_key => :Mnr,
    # Nur mit der aktuellsten Version verknüpfen 
    :conditions => proc { ["GueltigBis = ?", "9999-12-31 23:59:59"] }

  has_one :Student,
    :primary_key => :Mnr,
    :foreign_key => :Mnr,
    # Nur mit der aktuellsten Version verknüpfen 
    :conditions => proc { ["GueltigBis = ?", "9999-12-31 23:59:59"] }

  has_many :Tanliste,
    :foreign_key => :Mnr

  has_many :OzbKonto,
    :primary_key => :Mnr,
    :foreign_key => :Mnr,
    # Nur mit der aktuellsten Version verknüpfen 
    :conditions => proc { ["GueltigBis = ?", "9999-12-31 23:59:59"] }

  has_one :Buergschaft,
    :primary_key => :Mnr_G,
    :foreign_key => :Mnr,
    # Nur mit der aktuellsten Version verknüpfen 
    :conditions => proc { ["GueltigBis = ?", "9999-12-31 23:59:59"] }

  has_many :BuchungOnline,
    :primary_key => :Mnr,
    :foreign_key => :Mnr

end