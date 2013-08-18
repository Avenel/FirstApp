# encoding: UTF-8
require "HistoricRecord.rb"

class ZeKonto < ActiveRecord::Base
	include HistoricRecord
	
  self.table_name = "ZEKonto"
  self.primary_keys = :KtoNr, :GueltigVon
  
  # Necessary for historization
  def get_primary_keys 
    return {"KtoNr" => self.KtoNr}
  end

  def set_primary_keys(values)
    self.KtoNr = values["KtoNr"]
  end
  
  # attributes
  attr_accessible :KtoNr, :GueltigVon, :GueltigBis, :Pgnr, :EEKtoNr, :ZENr, :ZEAbDatum,
                  :ZEEndDatum, :ZEBetrag, :Laufzeit, :ZahlModus, :TilgRate, :NachsparRate, 
                  :KDURate, :RDURate, :ZEStatus, :Kalk_Leihpunkte, :Tats_Leihpunkte, 
                  :Sicherung, :SachPnr
  

  # column names
  HUMANIZED_ATTRIBUTES = {
    :GueltigVon => 'Gültig von',
    :GueltigBis => 'Gültig bis',
    :KtoNr      => 'ZE Konto-Nr.',
    :EEKtoNr    => 'EE Konto-Nr.',
    :Pgnr       => 'Projekt',
    :ZENr       => 'ZE-Nr.',
    :ZEAbDatum  => 'Gültig ab',
    :ZEEndDatum => 'Gültig bis',
    :ZEBetrag   => 'ZE-Betrag',
    :Laufzeit   => 'Laufzeit',
    :ZahlModus  => 'Zahlungsmodus',
    :TilgRate   => 'Tilgungsrate',
    :NachsparRate => 'Nachspar Rate',
    :KDURate    => 'KDU',
    :RDURate    => 'RDU',
    :ZEStatus   => 'Status',
    :SachPnr    => 'Sachbearbeiter-Nr.'
  }

  def self.human_attribute_name(attr, options={})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  # Validations
  # validate always things you will accept nested attributes for!
  validates :KtoNr, :presence => { :format => { :with => /[0-9]+/ }, :message => "Bitte geben Sie eine gültige Kontonummer an." }
  validates :Pgnr, :presence => { :format => { :with => /[0-9]+/ }, :message => "Bitte geben Sie eine gültige Projektgruppe an." }
  validates :EEKtoNr, :presence => { :format => { :with => /[0-9]+/ }, :message => "Bitte geben Sie eine gültige EE-Kontonummer an." }
  validates :ZENr, :presence => { :format => { :with => /^[A-Z]([0-9]){4}$/ }, :message => "Bitte geben Sie eine gültige ZE-Nr. an." }
  validates :ZEAbDatum, :presence => true
  validates :ZEEndDatum, :presence => true
  validates :ZEBetrag, :presence => { :format => { :with => /[0-9]+/ }, :message => "Bitte geben Sie einen gültigen ZEBetrag an." } 
  validates :Laufzeit, :presence => { :format => { :with => /[1-9]+/ }, :message => "Bitte geben Sie eine gültige Laufzeit an." }
  
  # enum ZahlModus
  AVAILABLE_ZAHLMODI = %W(m q j) # m = monatlich, q = quartal, j = jaehrlich
  validates :ZahlModus, :presence => true, :inclusion => { :in => AVAILABLE_ZAHLMODI, :message => "%{value} is not a valid Zalhmodus (m, q, j)" }

  validates :NachsparRate, :presence => true, :numericality =>{:greater_than_or_equal_to => 0.01 }
  validates :TilgRate, :presence => true, :numericality =>{:greater_than_or_equal_to => 0.01 }
  validates :KDURate, :presence => true, :numericality =>{:greater_than_or_equal_to => 0.01 }
  validates :RDURate, :presence => true, :numericality =>{:greater_than_or_equal_to => 0.01 }
  
  # enum ZEStatus
  AVAILABLE_ZESTATUS = %W(a e u) # a = aktiv, e = beendet, u = unterbrochen 
  validates :ZahlModus, :presence => true, :inclusion => { :in => AVAILABLE_ZAHLMODI, :message => "%{value} is not a valid ZEStatus (a, e, u)" }

  validates :Kalk_Leihpunkte, :presence => true, :format => {:with => /^[\d]+$/i}

  validate :kto_exists
  validate :eeKonto_exists
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


  def eeKonto_exists
    kto = EeKonto.latest(self.eeKtoNr)
    if kto.nil? then
      errors.add :ktoNr, "EEKonto existiert nicht: {self.eeKtoNr}."
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

  # Associations
  belongs_to :ozb_konto,
    :primary_key => :KtoNr,
    :foreign_key => :KtoNr,
    :conditions => proc { ["GueltigBis = ?", self.GueltigBis] } 

  belongs_to :ee_konto,
    :primary_key => :KtoNr,
    :foreign_key => :EEKtoNr,
    :conditions => proc { ["GueltigBis = ?", self.GueltigBis] } 
	
  has_many :buergschaft,
    :primary_key => :ZENr,
    :foreign_key => :ZENr,
    :conditions => proc { ["GueltigBis = ?", self.GueltigBis] } 

  belongs_to :projektgruppe,
    :foreign_key => :Pgnr

  # callbacks
  before_create :set_valid_time
  before_update :set_new_valid_time
  after_update :save_copy  
  
  def ZeKonto.latest(ktoNr)
    begin
      self.find(:all, :conditions => ["KtoNr = ? AND GueltigBis = ?", ktoNr, "9999-12-31 23:59:59"]).first # composite primary key gem
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end
  
  def ZeKonto.latest_all_for(mnr)
    ozb = OzbKonto.find(:all, :conditions => ["Mnr = ? AND GueltigBis = ?", mnr, "9999-12-31 23:59:59"]) # composite primary key gem
    
    k = Array.new
    ozb.each do |o|
      k << o.ze_konto unless o.ze_konto.nil?
    end
    
    return k
  end
  
  # Returns nil if at the given time no person object was valid
  def ZeKonto.get(KtoNr, date = Time.now)
    begin
      return ZeKonto.find(:all, :conditions => ["KtoNr = ? AND GueltigVon <= ? AND GueltigBis > ?", KtoNr, date, date]).first
    rescue ActiveRecord::RecordNotFound
      return nil
    end
  end
  
  # (non static) get latest instance of model
  def getLatest()
    return ZeKonto.get(self.KtoNr)
  end
  
  
end
