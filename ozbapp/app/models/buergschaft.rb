# encoding: UTF-8
class Buergschaft < ActiveRecord::Base 
  self.table_name = "buergschaft"
  self.primary_keys = :Pnr_B, :Mnr_G, :SichEndDatum
  
  # attributes
  attr_accessible :Pnr_B, :Mnr_G, :ZENr, :SichAbDatum, :SichEndDatum, :SichBetrag, :SichKurzbez, :Historisiert

  # associations
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
  
  # validations
  validates :Pnr_B, :presence => true
  validates :Mnr_G, :presence => true
  validates :SichAbDatum, :presence => true
  validates :SichEndDatum, :presence => true
  validates :SichBetrag, :presence => true,
                       :numericality =>{:greater_than_or_equal_to => 0.01 }
  
 
  

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
    
    # Kontonummer
    if self.ktoNr.nil? then
      errors.add("", "Die Kontonummer darf nicht leer sein.")
    end
    
    # Sicherheitsbetrag
    if self.sichBetrag.nil? then 
      errors.add("", "Bitte geben Sie einen Sicherheitsbetrag größer 0 an.")
    end
    
    if !self.sichBetrag.nil? && self.sichBetrag < 0 then 
      errors.add("", "Bitte geben Sie einen Sicherheitsbetrag größer 0 an.")
    end
    
    # sichAbDatum
    if !self.sichAbDatum.nil? then
      if self.sichAbDatum.to_s.match(/[0-9]{4}-[0-9][0-9]-[0-9][0-9]/).nil? then
        errors.add("", "Bitte geben sie das sichAbDatum im Format: yyyy-mm-dd an.")
      end
    end
    
    # sichEndDatum
    if !self.sichEndDatum.nil? then
      puts self.sichEndDatum.to_s
      if self.sichEndDatum.to_s.match(/[0-9]{4}-[0-9][0-9]-[0-9][0-9]/).nil? then
        errors.add("", "Bitte geben sie das sichEndDatum im Format: yyyy-mm-dd an.")
      end
    end
    
    return if [sichEndDatum.blank?, sichAbDatum.blank?].any?
    if sichAbDatum > sichEndDatum
      errors.add("", 'must be possible')
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
  
end
