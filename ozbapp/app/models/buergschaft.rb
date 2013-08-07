# encoding: UTF-8
class Buergschaft < ActiveRecord::Base 
  self.table_name = "Buergschaft"
  self.primary_keys = :Pnr_B, :Mnr_G, :GueltigVon
  
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
    if !self.sichAbDatum.nil? then
      if !self.sichAbDatum.strftime("%Y-%m-%d").match(/[0-9]{4}-[0-9][0-9]-[0-9][0-9]/) then
        return false
        errors.add("", "Bitte geben sie das sichAbDatum im Format: yyyy-mm-dd an.")
      end
    end
    
    # sichEndDatum
    if !self.sichEndDatum.nil? then
      puts self.sichEndDatum.to_s
      if !self.sichEndDatum.strftime("%Y-%m-%d").match(/[0-9]{4}-[0-9][0-9]-[0-9][0-9]/) then
        return false
        errors.add("", "Bitte geben sie das sichEndDatum im Format: yyyy-mm-dd an.")
      end
    end

    # test if sichAbDatum is after sichEndDatum
    if sichAbDatum > sichEndDatum
      errors.add("", 'must be possible')
      return false
    end
  end

  # GueltigVon und GueltigBis wird durch Model selbst gesetzt
  # Sachbearbeiter muss durch Controller oder abhängiges Model gesetzt werden!
  
  # Relations
  belongs_to :person,
    :foreign_key => :Pnr_B
  
  belongs_to :OZBPerson,
    :foreign_key => :Mnr_G
    
  belongs_to :ZEKonto,
    :foreign_key => :ZENr
  
  has_one :sachbearbeiter,
    :class_name => "Person",
    :foreign_key => :Pnr,
    :primary_key => :SachPNR,
    :order => "GueltigBis DESC"

  # callbacks
  before_create :set_valid_time
  before_update :set_new_valid_time
  after_destroy :destroy_historic_records
  
  def validate(bName, gName)!    
    errors = ActiveModel::Errors.new(self)
    person = nil
    
    # Bürgschafter
    if self.pnrB.nil? then
      names = bName.split(",")
      self.pnrB = find_by_name(names[0], names[-1])
      person = Person.where("pnr = ?", self.pnrB).first
      
      if self.pnrB == 0 then
        self.pnrB = nil
        errors.add("", "Personalnummer oder Name des Bürgschafters konnte nicht gefunden werden.")
      end
    else
      person = Person.where("pnr = ?", self.pnrB).first
    end
   
    if person.nil? then 
      errors.add("", "Personalnummer konnte in der Datenbank nicht gefunden werden.")
    end
    
    # Gesellschafter
    person = nil
    if self.mnrG.nil? then
    
      names = gName.split(",")
      self.mnrG = find_by_name(names[0], names[-1])
      person = Person.where("pnr = ?", self.mnrG).first
      
      if self.mnrG == 0 then
        self.mnrG = nil
        errors.add("", "Mitgliedsnummer oder Name des Gesellschafters konnte nicht gefunden werden.")
      end
      
    else
      person = Person.where("pnr = ?", self.mnrG).first
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
  
  def find_by_name(lastname, firstname)
    person = Person.where("name = ? AND vorname = ?", lastname.to_s.strip, firstname.to_s.strip).first
    
    puts person.inspect
    
    if person.nil? then
      return 0
    else
      return person.pnr
    end
    
  end

  # Historization stuff
  # bound to callback
  def set_valid_time
    unless(self.GueltigBis || self.GueltigVon)
      self.GueltigVon = Time.now
      self.GueltigBis = Time.zone.parse("9999-12-31 23:59:59")
    end
  end
  
  @@copy = nil

  # bound to callback
  def set_new_valid_time
    if (self.KtoNr)
      if (self.GueltigBis > "9999-01-01 00:00:00")
        @@copy            = self.get(self.KtoNr)
        @@copy            = @@copy.dup
        @@copy.KtoNr      = self.KtoNr
        @@copy.GueltigVon = self.GueltigVon
        @@copy.GueltigBis = Time.now
        
        self.GueltigVon   = Time.now
        self.GueltigBis   = Time.zone.parse("9999-12-31 23:59:59")
      end
    end
  end

 #NU
  after_update do
      if !@@copy.nil?
        @@copy.save(:validation => false)
        @@copy = nil
      end
   end

  # Returns the EEKonto Object for ktoNr and date
  def get(pnr_b, mnr_g, date = Time.now)
    Buergschaft.find(:all, :conditions => ["Pnr_B = ? AND Mnr_G = ? AND GueltigVon <= ? AND GueltigBis > ?", pnr_b, mnr_g, date, date]).first
  end
  
  def self.latest(pnr_b, mnr_g)
    begin
      self.find(:all, :conditions => ["Pnr_B = ? AND Mnr_G = ? AND GueltigBis = ?", pnr_b, mnr_g, "9999-12-31 23:59:59"]).first
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end
  
end
