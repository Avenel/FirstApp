# encoding: UTF-8
require "HistoricRecord.rb"

class EeKonto < ActiveRecord::Base
    include HistoricRecord

  self.table_name = "EEKonto"
  self.primary_keys = :KtoNr, :GueltigVon # two primary keys define an unique record
  
  # Necessary for historization
  def get_primary_keys 
    return {"KtoNr" => self.KtoNr}
  end

  def set_primary_keys(values)
    self.KtoNr = values["KtoNr"]
  end

  # attributes
  attr_accessible :KtoNr, :GueltigVon, :GueltigBis, :BankID, :Kreditlimit,  
                  :SachPnr, :Bankverbindung_attributes, :sachbearbeiter_attributes,
                  
  

   # column names
  HUMANIZED_ATTRIBUTES = {
    :KtoNr        => 'EE Konto-Nr.',
    :BankID       => 'Bank ID',
    :Kreditlimit  => 'Kreditlimit',
    :SachPnr      => 'Sachbearbeiter',
    :GueltigVon   => 'Gültig von',
    :GueltigBis   => 'Gültig bis'
  }

  def self.human_attribute_name(attr, options={})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end


  # Validations  
  validates :KtoNr, :presence => true, :format => { :with => /^[0-9]{5}$/i, :message => "Bitte geben Sie eine gültige Kontonummer (5 stellig) an." }
  validates :Kreditlimit, :presence => true, :numericality => true
  
  validate :bankId_exists
  validate :kto_exists
  validate :sachPnr_exists

  def kto_exists
    kto = OzbKonto.latest(self.KtoNr)
    if kto.nil? then
      errors.add :KtoNr, "Konto existiert nicht: {self.ktoNr}."
      return false
    else
      return true
    end
  end

  def bankId_exists
    bankverbindung = Bankverbindung.latest(self.BankID)

    if bankverbindung.nil? then
      errors.add :BankID, "Bankverbindung existiert nicht: {self.BankID}."
      return false
    else
      return true
    end
  end

  def sachPnr_exists
    if self.SachPnr.nil? then
      return true
    end

    ozbperson = OZBPerson.where("Mnr = ?", self.SachPnr)
    if ozbperson.empty? then
      errorString = String.new("Es konnte keinen zugehörigen Sachbearbeiter zu der angegebenen Mnr (#{self.SachPnr}) gefunden werden.")
      errors.add :Mnr, errorString
      return false
    end
    return true
  end
  
  # callbacks
  before_create :set_valid_time
  before_update :set_new_valid_time
  after_update :save_copy

  # Associations
  belongs_to :OzbKonto,
    :primary_key => :KtoNr,
    :foreign_key => :KtoNr,
    :conditions => proc { ["GueltigBis = ?", self.GueltigBis] } 

  belongs_to :Bankverbindung,
    :primary_key => :ID,
    :foreign_key => :BankID, # associated column in ee_konto table! 
    :conditions => proc { ["GueltigBis = ?", self.GueltigBis] } 
    
  has_one :ZeKonto, 
    :primary_key => :KtoNr,
    :foreign_key => :EEKtoNr, # associated column in ZEKonto table
    :conditions => proc { ["GueltigBis = ?", self.GueltigBis] } 

  accepts_nested_attributes_for :Bankverbindung  

  def EeKonto.get(ktoNr, date = Time.now)
    begin
      return EeKonto.find(:all, :conditions => ["KtoNr = ? AND GueltigVon <= ? AND GueltigBis > ?", ktoNr, date, date]).first
    rescue ActiveRecord::RecordNotFound
      return nil
    end
  end
  
  def self.latest(ktoNr)
    return EeKonto.get(ktoNr)
  end

  # (non static) get latest instance of model
  def getLatest()
    return EeKonto.get(self.KtoNr)
  end

  def ktonr_with_name
    if !self.OzbKonto.nil?
      p = Person.find_by_Pnr_and_GueltigBis(self.OzbKonto.Mnr, "9999-12-31 23:59:59")
      
      if !p.nil?
        "[" + self.KtoNr.to_s + "] " + p.Name + ", " + p.Vorname
      end
    end
  end
  
end