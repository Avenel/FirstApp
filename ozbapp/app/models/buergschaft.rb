# encoding: UTF-8
require "HistoricRecord.rb"

class Buergschaft < ActiveRecord::Base 
    include HistoricRecord

  self.table_name = "Buergschaft"
  self.primary_keys = :Pnr_B, :Mnr_G, :GueltigVon
  
  # Necessary for historization
  def get_primary_keys 
    return {"Pnr_B" => self.Pnr_B, "Mnr_G" => self.Mnr_G}
  end

  def set_primary_keys(values)
    self.Pnr_B = values["Pnr_B"]
    self.Mnr_G = values["Mnr_G"]
  end

  # attributes
  attr_accessible :Pnr_B, :Mnr_G, :GueltigVon, :GueltigBis, :ZENr, :SichAbDatum, 
                  :SichEndDatum, :SichBetrag, :SichKurzbez, :SachPnr

  # column names
  HUMANIZED_ATTRIBUTES = {
    :Pnr_B        => 'Bürgschafter',
    :Mnr_G        => 'Gläubiger',
    :ZENr        => 'ZE-Nr.',
    :SichAbDatum  => 'Beginn',
    :SichEndDatum => 'Ende',
    :SichBetrag   => 'Betrag',
    :SichKurzbez  => 'Kurzbezeichnung'
  }

  def self.human_attribute_name(attr, options={})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end


  # validations
  validates :Pnr_B, :presence => true
  validates :Mnr_G, :presence => true
  validates :ZENr, :presence => true
  validates :SichAbDatum, :presence => true
  validates :SichEndDatum, :presence => true
  validates :SichBetrag, :presence => true,
                       :numericality =>{:greater_than_or_equal_to => 0.01 }
  validate :zeKonto_exists
  validate :sachPnr_exists
  validate :valid_sichZeitraum

  # SachPnr should be an ozb member, so check if there is an OZBPerson with the given Pnr (=Mnr)
  def sachPnr_exists
    if self.SachPnr.nil? then
      return true
    end

    ozbperson = OZBPerson.where("Mnr = ?", self.SachPnr)
    if ozbperson.empty? then
      errorString = String.new("Es konnte keinen zugehörigen Sachbearbeiter zu der angegebenen Mnr (#{self.SachPnr}) gefunden werden.")
      errors.add :mnr, errorString
      return false
    end
    return true
  end

  def zeKonto_exists 
    if !self.ZENr.nil? then
      zeKonto = ZeKonto.where("ZENr = ?", self.ZENr).first
      if zeKonto.nil? then
        errors.add :ZENr, "Kein zugehöriges ZEKonto gefunden."
        return false
      else 
        return true
      end
    else 
      return false
    end
  end
  
  def valid_sichZeitraum
     # sichAbDatum
    if !self.SichAbDatum.nil? then
      if !self.SichAbDatum.strftime("%Y-%m-%d").match(/[0-9]{4}-[0-9][0-9]-[0-9][0-9]/) then
        return false
        errors.add("", "Bitte geben sie das sichAbDatum im Format: yyyy-mm-dd an.")
      end
    end
    
    # sichEndDatum
    if !self.SichEndDatum.nil? then
      if !self.SichEndDatum.strftime("%Y-%m-%d").match(/[0-9]{4}-[0-9][0-9]-[0-9][0-9]/) then
        return false
        errors.add("", "Bitte geben sie das sichEndDatum im Format: yyyy-mm-dd an.")
      end
    end

    # test if sichAbDatum is after sichEndDatum
    if self.SichAbDatum > self.SichEndDatum
      errors.add("", 'must be possible')
      return false
    end
  end
  
  def validate(bName, gName)!    
    errors = ActiveModel::Errors.new(self)
    person = nil
    
    # Bürgschafter
    if self.pnrB.nil? then
      names = bName.split(",")
      self.pnrB = find_by_name(names[0], names[-1])
      person = Person.where("Pnr = ?", self.Pnr_B).first
      
      if self.Pnr_B == 0 then
        self.Pnr_B = nil
        errors.add("", "Personalnummer oder Name des Bürgschafters konnte nicht gefunden werden.")
      end
    else
      person = Person.where("Pnr = ?", self.Pnr_B).first
    end
   
    if person.nil? then 
      errors.add("", "Personalnummer konnte in der Datenbank nicht gefunden werden.")
    end
    
    # Gesellschafter
    person = nil
    if self.Mnr_G.nil? then
    
      names = gName.split(",")
      self.mnrG = find_by_name(names[0], names[-1])
      person = Person.where("Pnr = ?", self.Mnr_G).first
      
      if self.Mnr_G == 0 then
        self.Mnr_G = nil
        errors.add("", "Mitgliedsnummer oder Name des Gesellschafters konnte nicht gefunden werden.")
      end
      
    else
      person = Person.where("Pnr = ?", self.Mnr_G).first
    end
    
    if person.nil? then 
      errors.add("", "Personalnummer konnte in der Datenbank nicht gefunden werden.")
    else
      if person.rolle != "G" then 
        errors.add("", "Es sind nur Gesellschafter erlaubt.")
      end
    end
   
    return errors
  end

  # callbacks
  before_create :set_valid_time
  before_update :set_new_valid_time
  after_update :save_copy

  # Associations
  belongs_to :Person,
          :foreign_key => :Pnr_B,
          :conditions => proc { ["GueltigBis = ?", self.GueltigBis] }          
  
  belongs_to :OZBPerson,
          :foreign_key => :Mnr_G,
          :conditions => proc { ["GueltigBis = ?", self.GueltigBis] }
    
  belongs_to :ZEKonto,
          :primary_key => :ZENr, # column in ZEKonto
          :foreign_key => :ZENr, # column in Buergschaft
          :conditions => proc { ["GueltigBis = ?", self.GueltigBis] }

  
  def find_by_name(lastname, firstname)
    person = Person.where("name = ? AND vorname = ?", lastname.to_s.strip, firstname.to_s.strip).first
    
    
    if person.nil? then
      return 0
    else
      return person.pnr
    end
  end

  # Returns the EEKonto Object for ktoNr and date
  def Buergschaft.get(pnr_b, mnr_g, date = Time.now)
    begin
      return Buergschaft.find(:all, :conditions => ["Pnr_B = ? AND Mnr_G = ? AND GueltigVon <= ? AND GueltigBis > ?", pnr_b, mnr_g, date, date]).first
    rescue ActiveRecord::RecordNotFound
      return nil
    end
  end

  # (non static) get latest instance of model
  def getLatest()
    return Buergschaft.get(self.Pnr_B, self.Mnr_G)
  end
  
  def self.latest(pnr_b, mnr_g)
    return Buergschaft.get(pnr_b, mnr_g)
  end
  
end
