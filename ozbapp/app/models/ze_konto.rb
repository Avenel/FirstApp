# encoding: UTF-8
class ZeKonto < ActiveRecord::Base
  self.table_name = "ZEKonto"
  self.primary_keys = :KtoNr, :GueltigVon
  
  # aliases
  alias_attribute :ktoNr, :KtoNr
  alias_attribute :eeKtoNr, :EEKtoNr
  alias_attribute :pgNr, :Pgnr
  alias_attribute :zeNr, :ZENr
  alias_attribute :zeAbDatum, :ZEAbDatum
  alias_attribute :zeEndDatum, :ZEEndDatum
  alias_attribute :zeBetrag, :ZEBetrag
  alias_attribute :laufzeit, :Laufzeit
  alias_attribute :zahlModus, :ZahlModus
  alias_attribute :tilgRate, :TilgRate
  alias_attribute :ansparRate, :AnsparRate
  alias_attribute :kduRate, :KDURate
  alias_attribute :rduRate, :RDURate
  alias_attribute :zeStatus, :ZEStatus 
  
  # attributes
  attr_accessible :KtoNr, :EEKtoNr, :Pgnr, :ZENr, :ZEAbDatum, :ZEEndDatum, :ZEBetrag, 
                  :Laufzeit, :ZahlModus, :TilgRate, :AnsparRate, :KDURate, :RDURate, :ZEStatus, :GueltigVon, :GueltigBis, :SachPnr, :Kalk_Leihpunkte, :Tats_Leihpunkte
  
  # associations
  belongs_to :ozb_konto,
    :primary_key => :KtoNr,
    :foreign_key => :KtoNr,
    :conditions => proc { ["GueltigBis = ?", self.GueltigBis] } # condition -> for historic db
                                                                # do never ever rely that the current record is the newest one (GueltigBis = "9999-12-31 23:59:59")
                                                                # it might be possible that older records are focused. So you should come in trouble when selecting 
                                                                # not the corresponding record for that association.
                                                                # PLEASE NOTE: This associated child records must be updated to the SAME DateTime and EVERYTIME this
                                                                # record is updated, otherwise it would corrupt the underlying logic model.

  belongs_to :ee_konto,
    :foreign_key => :EEKtoNr,
    :conditions => proc { ["GueltigBis = ?", self.GueltigBis] } # condition -> for historic db
                                                                # do never ever rely that the current record is the newest one (GueltigBis = "9999-12-31 23:59:59")
                                                                # it might be possible that older records are focused. So you should come in trouble when selecting 
                                                                # not the corresponding record for that association.
                                                                # PLEASE NOTE: This associated child records must be updated to the SAME DateTime and EVERYTIME this
                                                                # record is updated, otherwise it would corrupt the underlying logic model.

  has_many :buergschaft,
    :foreign_key => :KtoNr # no one or many

  belongs_to :projektgruppe,
    :inverse_of => :ZEKonto,
    :foreign_key => :Pgnr

  has_one :sachbearbeiter,
    :class_name => "Person",
    :foreign_key => :Pnr,
    :primary_key => :SachPnr,
    #:order => "GueltigBis DESC", # ????????????????????????????????????????????
    :conditions => proc { ["GueltigBis = ?", self.GueltigBis] } # condition -> for historic db
                                                                # do never ever rely that the current record is the newest one (GueltigBis = "9999-12-31 23:59:59")
                                                                # it might be possible that older records are focused. So you should come in trouble when selecting 
                                                                # not the corresponding record for that association.
                                                                # PLEASE NOTE: This associated child records must be updated to the SAME DateTime and EVERYTIME this
                                                                # record is updated, otherwise it would corrupt the underlying logic model.

  # validations
  # validate always things you will accept nested attributes for!
  #validates :KtoNr, :presence => { :format => { :with => /[0-9]+/ }, :message => "Bitte geben Sie eine gültige Kontonummer an." }
  validates :EEKtoNr, :presence => { :format => { :with => /[0-9]+/ }, :message => "Bitte geben Sie eine gültige EE-Kontonummer an." }
  validates :Pgnr, :presence => { :format => { :with => /[0-9]+/ }, :message => "Bitte geben Sie eine gültige Projektgruppe an." }
  validates :ZENr, :presence => { :format => { :with => /[0-9]+/ }, :message => "Bitte geben Sie eine gültige ZE-Nr. an." }
  validates :Laufzeit, :presence => { :format => { :with => /[1-9]+/ }, :message => "Bitte geben Sie eine gültige Laufzeit an." }
  
  after_destroy :destroy_historic_records, :destroy_ozb_konto_if_this_is_last_konto
  
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
    :AnsparRate => 'Ansparrate',
    :KDURate    => 'KDU',
    :RDURate    => 'RDU',
    :ZEStatus   => 'Status',
    :SachPnr    => 'Sachbearbeiter-Nr.'
  }

  def self.human_attribute_name(attr, options={})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end
  
  before_save do
    unless(self.GueltigBis || self.GueltigVon)
      self.GueltigVon = Time.now
      self.GueltigBis = Time.zone.parse("9999-12-31 23:59:59")
    end
  end

  @@copy = nil

  before_update do
    if(self.KtoNr)
      if(self.GueltigBis > "9999-01-01 00:00:00")
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

   after_update do
      if !@@copy.nil?
        @@copy.save(:validation => false)
        @@copy = nil
      end
   end

  # Returns nil if at the given time no person object was valid
  def get(ktoNr, date = Time.now)
    ZeKonto.find(:all, :conditions => ["KtoNr = ? AND GueltigVon <= ? AND GueltigBis > ?", ktoNr, date, date]).first
  end
  
  def self.latest(ktoNr)
    begin
      self.find(ktoNr, "9999-12-31 23:59:59")
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end
  
  def self.latest_all_for(mnr)
    ozb = OzbKonto.find(:all, :conditions => { :Mnr => mnr })
    
    k = Array.new
    ozb.each do |o|
      k << o.ze_konto unless o.ze_konto.nil?
    end
    
    return k
  end
  
  private
    # bound to callback
    def destroy_historic_records
      # find all historic records that belongs to this record and destroy(!) them
      # note: destroy should always destroy all the corresponding association objects
      # if the association option :dependent => :destroy is set correctly
      recs = self.class.find(:all, :conditions => ["KtoNr = ? AND GueltigBis < ?", self.KtoNr, self.GueltigBis])
      
      recs.each do |r|
        r.destroy
      end
    end
    
    # bound to callback
    def destroy_ozb_konto_if_this_is_last_konto
      OzbKonto.destroy_yourself_if_you_are_alone(self.ktoNr)
    end
end
