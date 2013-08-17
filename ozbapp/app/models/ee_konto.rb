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
  attr_accessible :KtoNr, :GueltigVon, :GueltigBis, :BankId, :Kreditlimit,  
                  :SachPnr, :Bankverbindung_attributes, :sachbearbeiter_attributes
  

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
  validates :Kreditlimit, :presence => true, :format => { :with => /^[0-9]+$/, :message => "Bitte geben Sie ein gültiges Kreditlimit ein." }
  
  validate :bankId_exists
  validate :kto_exists
  validate :sachPnr_exists

  def kto_exists
    kto = OzbKonto.latest(self.ktoNr)
    if kto.nil? then
      errors.add :ktoNr, "Konto existiert nicht: {self.ktoNr}."
      return false
    else
      return true
    end
  end

  def bankId_exists
    bankverbindung = Bankverbindung.latest(self.bankId)

    if bankverbindung.nil? then
      errors.add :bankId, "Bankverbindung existiert nicht: {self.bankId}."
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
      errors.add :mnr, errorString
      return false
    end
    return true
  end
  
  # callbacks
  before_create :set_valid_time
  before_update :set_new_valid_time
  after_update :save_copy

  # Associations
  belongs_to :ozb_konto,
    :foreign_key => :KtoNr, 
    :conditions => proc { ["GueltigBis = ?", self.GueltigBis] } 

  belongs_to :Bankverbindung,
    :primary_key => :ID,
    :foreign_key => :BankId, # associated column in ee_konto table! 
    :conditions => proc { ["GueltigBis = ?", self.GueltigBis] } 
    
  has_one :ze_konto, 
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
    if !self.ozb_konto.nil?
      p = Person.find_by_Pnr_and_GueltigBis(self.ozb_konto.Mnr, "9999-12-31 23:59:59")
      
      if !p.nil?
        "[" + self.KtoNr.to_s + "] " + p.Name + ", " + p.Vorname
      end
    end
  end
  
  private
    # bound to callback
    def destroy_historic_records
      # find all historic records that belongs to this record and destroy(!) them
      # note: destroy should always destroy all the corresponding association objects
      # if the association option :dependent => :destroy is set correctly
      recs = EeKonto.find(:all, :conditions => ["KtoNr = ? AND GueltigBis < ?", self.KtoNr, self.GueltigBis])
      
      recs.each do |r|
        r.destroy
      end
    end
    
    # bound to callback
    def destroy_ozb_konto_if_this_is_last_konto
      OzbKonto.destroy_yourself_if_you_are_alone(self.ktoNr)
    end
    
    # bound to callback
    def destroy_bankverbindung
      if (!self.Bankverbindung.nil?)
        self.Bankverbindung.destroy
      end
    end
end