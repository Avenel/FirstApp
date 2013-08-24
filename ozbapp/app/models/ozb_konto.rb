# encoding: UTF-8
require "HistoricRecord.rb"

class OzbKonto < ActiveRecord::Base
    include HistoricRecord
  
  self.table_name = "OZBKonto"
  self.primary_keys = :KtoNr, :GueltigVon
  
  # Necessary for historization
  def get_primary_keys 
    return {"KtoNr" => self.KtoNr}
  end

  def set_primary_keys(values)
    self.KtoNr = values["KtoNr"]
  end

  # attributes
  attr_accessible :KtoNr, :GueltigVon, :GueltigBis, :Mnr, :KtoEinrDatum, :WaehrungID, :WSaldo, 
                  :PSaldo, :SaldoDatum, :SachPnr, :EeKonto_attributes, 
                  :ZeKonto_attributes, :kkl_verlauf_attributes
  
  # column names
  HUMANIZED_ATTRIBUTES = {
    :KtoNr          => 'Konto-Nr.',
    :GueltigVon     => 'Gültig von',
    :GueltigBis     => 'Gültig bis',
    :Mnr            => 'Mitglieder-Nr.',
    :KtoEinrDatum   => 'Einrichtungsdatum',
    :Waehrung       => 'Währung',
    :WSaldo         => 'Währungssaldo',
    :PSaldo         => 'Punktesaldo',
    :SaldoDatum     => 'Saldo Datum',
    :SachPnr        => 'Sachbearbeiter-Nr.',
    :ee_konten      => 'EE-Konto (Bankverbindung)'
  }

  def self.human_attribute_name(attr, options={})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  # Validations
  validates :KtoNr, :presence => { :format => { :with => /^[0-9]{5}$/i }, :message => "Bitte geben Sie eine gültige Kontonummer (5 stellig) an." }
  validates :Mnr, :presence => { :format => { :with => /[0-9]+/ }, :message => "Bitte geben Sie eine gültige Mitgliedsnummer an." }  
  validates :KtoEinrDatum, :presence => true
  validates :WaehrungID, :presence => { :format => { :with => /[a-zA-Z]{3}/ }, :message => "Bitte geben Sie eine gültige Währung an." }
  validates :SachPnr, :format => { :with => /[0-9]+/, :message => "Bitte geben Sie eine gültige Mitgliedsnummer für den Sachbearbeiter an." }  

  validate :ozbperson_exists, :sachPnr_exists

  def ozbperson_exists
    ozbperson = OZBPerson.where("Mnr = ?", self.Mnr)
    if ozbperson.empty? then
      errorString = String.new("Es konnte keine zugehörige OZBPerson zu der angegebenen Mnr (%(value)) gefunden werden.")
      errors.add :Mnr, errorString
      return false
    end
    return true
  end

  def sachPnr_exists
    ozbperson = OZBPerson.where("Mnr = ?", self.SachPnr)
    if ozbperson.empty? then      
      errorString = String.new("Es konnte keinen zugehörigen Sachbearbeiter zu der angegebenen Mnr (%(value)) gefunden werden.")
      errors.add :SachPnr, errorString
      return false
    end
    return true
  end

  # Associations
  has_many :Buchung, 
    :primary_key => :KtoNr,
    :foreign_key => :KtoNr,
    # Zeige nur Buchungen an, die innerhalb dieser version des OZBKontos durchgeführt wurden.
    :conditions => proc { ["BuchDatum <= ?", self.GueltigBis] },
    :dependent => :destroy

  belongs_to :OZBPerson, 
    :foreign_key => :Mnr
  
  has_one :KklVerlauf, 
    :foreign_key => :KtoNr,
    :primary_key => :KtoNr,
    # Nur der aktuellste KKLVerlauf, in dem aktiven Zeitram des OZBKontos ist gültig
    :order => "KKLAbDatum DESC", 
    :conditions => proc { ["KKLAbDatum <= ?", self.GueltigBis] },
    :dependent => :destroy 

  has_one :ZeKonto, 
    :foreign_key => :KtoNr,
    :primary_key => :KtoNr, 
    :conditions => proc { ["GueltigBis = ?", self.GueltigBis] },
    :dependent => :destroy 

  has_one :EeKonto,
    :foreign_key => :KtoNr, 
    :primary_key => :KtoNr,
    :conditions => proc { ["GueltigBis = ?", self.GueltigBis] },
    :dependent => :destroy

  belongs_to :Waehrung,
    :primary_key => :Code,
    :foreign_key => :WaehrungID

  accepts_nested_attributes_for :EeKonto, :ZeKonto, :KklVerlauf

  # callbacks
  before_save :set_assoc_attributes, :set_wsaldo_psaldo_to_zero, :set_saldo_datum
  before_create :set_valid_time
  before_update :set_new_valid_time
  after_update :save_copy
  after_destroy :destroy_associated_objects


  # Returns the OZBKonto Object for ktoNr and date
  def OzbKonto.get(ktoNr, date = Time.now)
    begin
      return OzbKonto.find(:last, :conditions => ["KtoNr = ? AND GueltigVon <= ? AND GueltigBis > ?", ktoNr, date, date])
    rescue ActiveRecord::RecordNotFound
      return nil
    end
  end
  
  # Returns the latest/newest OZBKonto Object
  def self.latest(ktoNr)
    return OzbKonto.get(ktoNr)
  end

  # (non static) get latest instance of model
  def getLatest()
    return OzbKonto.get(self.KtoNr)
  end
  
  # Static method
  # Returns all EE-Konten for the specified person which are valid AT THE MOMENT
  def self.get_all_ee_for(mnr)
    ozb_konto = self.where(:Mnr => mnr, :GueltigBis => "9999-12-31 23:59:59").order("KtoNr ASC")
    @EeKonto = Array.new
    
    ozb_konto.each do |konto|
      if !konto.EeKonto.nil? 
        @EeKonto.push(konto.EeKonto)
      end
    end
    
    return @EeKonto
  end
  
  # Static method
  # Returns all ZE-Konten for the specified person which are valid AT THE MOMENT
  def self.get_all_ze_for(mnr)
    ozb_konto = self.where(:Mnr => mnr, :GueltigBis => "9999-12-31 23:59:59").order("KtoNr ASC")
    @ZeKonto = Array.new
    
    ozb_konto.each do |konto|
      if !konto.ZeKonto.nil?
        @ZeKonto.push(konto.ZeKonto)
      end
    end
    
    return @ZeKonto
  end

  private
    # bound to callback
    def set_wsaldo_psaldo_to_zero
      if (self.PSaldo.nil?)
        self.PSaldo = 0
      end
      
      if (self.WSaldo.nil?)
        self.WSaldo = 0.0
      end
    end
    
    # bound to callback
    def set_saldo_datum
      if (self.SaldoDatum.nil?)
        self.SaldoDatum = self.KtoEinrDatum
      end
    end
    
    # bound to callback
    def set_assoc_attributes
      eeKonto = EeKonto.latest(self.KtoNr)
      if (!eeKonto.nil?)
        eeKonto.SachPnr = self.SachPnr
      end
    end
    

    # Destroy associated (historic) objects
    def destroy_associated_objects
      # KKL Verlauf
      verlaeufe = KKLVerlauf.find(:all, :conditions => ["KtoNr = ?", self.KtoNr])
      verlaeufe.each do |verlauf|
        verlauf.destroy()
      end

      # EEKonto
      eeKonten = EeKonto.find(:all, :conditions => ["KtoNr = ?", self.KtoNr])
      eeKonten.each do |ee|
        ee.destroy()
      end

      # ZEKonto
      zeKonten = ZeKonto.find(:all, :conditions => ["KtoNr = ?", self.KtoNr])
      zeKonten.each do |ze|
        ze.destroy()
      end

    end
end
