# encoding: UTF-8
class OzbKonto < ActiveRecord::Base
  self.table_name = "OZBKonto"
  self.primary_keys = :KtoNr, :GueltigVon # two primary keys define an unique record
  
  # aliases
  alias_attribute :ktoNr, :KtoNr
  alias_attribute :mnr, :Mnr
  alias_attribute :ktoEinrDatum, :KtoEinrDatum
  alias_attribute :waehrung, :Waehrung
  alias_attribute :wSaldo, :WSaldo
  alias_attribute :pSaldo, :PSaldo
  alias_attribute :saldoDatum, :SaldoDatum
  alias_attribute :sachPnr, :SachPnr
  
  # attributes
  # accept only and really only attr_accessible if you want that a user is able to mass-assign these attributes!
  attr_accessible :KtoNr, :GueltigVon, :GueltigBis, :Mnr, :KtoEinrDatum, :Waehrung, :WSaldo, 
                  :PSaldo, :SaldoDatum, :SachPnr, :ee_konto_attributes, 
                  :ze_konto_attributes, :kkl_verlauf_attributes
  accepts_nested_attributes_for :ee_konto, :ze_konto, :kkl_verlauf
  
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

  # validations
  # validate always things you will accept nested attributes for!
  validates :KtoNr, :presence => { :format => { :with => /^[0-9]{5}$/i }, :message => "Bitte geben Sie eine gültige Kontonummer (5 stellig) an." }
  validates :Mnr, :presence => { :format => { :with => /[0-9]+/ }, :message => "Bitte geben Sie eine gültige Mitgliedsnummer an." }  
  validates :KtoEinrDatum, :presence => true
  validates :Waehrung, :presence => { :format => { :with => /[a-zA-Z]{3}/ }, :message => "Bitte geben Sie eine gültige Währung an." }
  
  # GueltigVon und GueltigBis wird durch Model selbst gesetzt
  
  # Sachbearbeiter muss durch Controller gesetzt werden!
  validates :SachPnr, :format => { :with => /[0-9]+/, :message => "Bitte geben Sie eine gültige Mitgliedsnummer für den Sachbearbeiter an." }
  
  validate :ozbperson_exists, :sachPnr_exists

  def ozbperson_exists
    ozbperson = OZBPerson.where("Mnr = ?", mnr)
    if ozbperson.empty? then
      errorString = String.new("Es konnte keine zugehörige OZBPerson zu der angegebenen Mnr (#{mnr}) gefunden werden.")
      errors.add :mnr, errorString
      return false
    end
    return true
  end


  # SachPnr should be an ozb member, so check if there is an OZBPerson with the given Pnr (=Mnr)
  def sachPnr_exists
    ozbperson = OZBPerson.where("Mnr = ?", sachPnr)
    if ozbperson.empty? then
      ozbpersons = OZBPerson.all()
      
      errorString = String.new("Es konnte keinen zugehörigen Sachbearbeiter zu der angegebenen Mnr (#{sachPnr}) gefunden werden.")
      errors.add :mnr, errorString
      return false
    end
    return true
  end

  # Relations
  belongs_to :ozb_person, :foreign_key => :Mnr
  has_many :buchung, :foreign_key => :KtoNr, :dependent => :destroy
  
  # this differs from the db schema -> there are in 'real' many KKLVerlauf 
  # for this record, but we have a historic database where at a point 
  # of time only one record is valid!
  #
  # NOTE: Here's another problem: If someone updates the KKL-Klasse multiple
  # times at a day, it is not specified if the latest read column from the
  # db is the newest because we can't make a more specific query than on a
  # per day basis -> datatype of kklverlauf-column should be DatTime instead
  # of Date
  has_one :kkl_verlauf, 
    :foreign_key => :KtoNr,
    :primary_key => :KtoNr,
    :dependent => :destroy,
    :class_name => "KklVerlauf",
    :autosave => true,
    :order => "KKLAbDatum DESC" # the order is important: we have a historic db schema but we have at ONE TIME only a :has_one relationship, so we need to pick the first record
    #:conditions => proc { ["KtoNr = ? AND KKLAbDatum = ?", self.KtoNr, KklVerlauf.find(:all, :conditions => { :KtoNr => self.KtoNr }, :order => "KKLAbDatum DESC").first.KKLAbDatum] } # condition -> for historic db
                                                                # do never ever rely that the current record is the newest one (GueltigBis = "9999-12-31 23:59:59")
                                                                # it might be possible that older records are focused. So you should come in trouble when selecting 
                                                                # not the corresponding record for that association.
                                                                # PLEASE NOTE: This associated child records must be updated to the SAME DateTime and EVERYTIME this
                                                                # record is updated, otherwise it would corrupt the underlying logic model.

  # this differs from the db schema -> there are in 'real' many ZeKonto
  # for this record, but we have a historic database where at a point 
  # of time only one record is valid!
  has_one :ze_konto, 
    :foreign_key => :KtoNr,
    :primary_key => :KtoNr, 
    :dependent => :destroy, 
    :class_name => "ZeKonto",
    :autosave => true,
    :conditions => proc { ["GueltigBis = ?", self.GueltigBis] } # condition -> for historic db
                                                                # do never ever rely that the current record is the newest one (GueltigBis = "9999-12-31 23:59:59")
                                                                # it might be possible that older records are focused. So you should come in trouble when selecting 
                                                                # not the corresponding record for that association.
                                                                # PLEASE NOTE: This associated child records must be updated to the SAME DateTime and EVERYTIME this
                                                                # record is updated, otherwise it would corrupt the underlying logic model.

  # this differs from the db schema -> there are in 'real' many EeKonto
  # for this record, but we have a historic database where at a point 
  # of time only one record is valid!
  has_one :ee_konto,
    :foreign_key => :KtoNr, 
    :primary_key => :KtoNr,
    :dependent => :destroy,
    :class_name => "EeKonto", 
    :autosave => true, 
    :conditions => proc { ["GueltigBis = ?", self.GueltigBis] } # condition -> for historic db
                                                                # do never ever rely that the current record is the newest one (GueltigBis = "9999-12-31 23:59:59")
                                                                # it might be possible that older records are focused. So you should come in trouble when selecting 
                                                                # not the corresponding record for that association.
                                                                # PLEASE NOTE: This associated child records must be updated to the SAME DateTime and EVERYTIME this
                                                                # record is updated, otherwise it would corrupt the underlying logic model.

  belongs_to :sachbearbeiter,
    :foreign_key => :Pnr, 
    :primary_key => :SachPnr, 
    :class_name => "Person"


  # callbacks
  before_save :set_assoc_attributes, :set_wsaldo_psaldo_to_zero, :set_saldo_datum
  before_create :set_valid_time
  before_update :set_new_valid_time
  after_destroy :destroy_historic_records
  
  
  # Static method
  # Returns all EE-Konten for the specified person which are valid AT THE MOMENT
  def self.get_all_ee_for(mnr)
    ozb_konto = self.where(:Mnr => mnr, :GueltigBis => "9999-12-31 23:59:59").order("KtoNr ASC")
    @ee_konto = Array.new
    
    ozb_konto.each do |konto|
      #if konto.ee_konto.count > 0 then
      #  @ee_konto.push(konto.ee_konto.first)
      #end
      if !konto.ee_konto.nil? #&& konto.ee_konto.GueltigBis == "9999-12-31 23:59:59"
        @ee_konto.push(konto.ee_konto)
      end
    end
    
    return @ee_konto
  end
  
  # Static method
  # Returns all ZE-Konten for the specified person which are valid AT THE MOMENT
  def self.get_all_ze_for(mnr)
    ozb_konto = self.where(:Mnr => mnr, :GueltigBis => "9999-12-31 23:59:59").order("KtoNr ASC")
    @ze_konto = Array.new
    
    ozb_konto.each do |konto|
      #if konto.ze_konto.count > 0 then
      #  @ze_konto.push(konto.ze_konto.first)
      #end
      if !konto.ze_konto.nil?
        @ze_konto.push(konto.ze_konto)
      end
    end
    
    return @ze_konto
  end

  # Returns the OZBKonto Object for ktoNr and date
  def get(ktoNr, date = Time.now)
    #self.where(:KtoNr => ktoNr).where(["GueltigVon <= ?", date]).where(["GueltigBis > ?",date]).first
    OzbKonto.find(:last, :conditions => ["KtoNr = ? AND GueltigVon <= ? AND GueltigBis > ?", ktoNr, date, date])
  end
  
  # Returns the latest/newest OZBKonto Object
  def self.latest(ktoNr)
    begin
      self.find(:all, :conditions => ["KtoNr = ? AND GueltigBis = ?", ktoNr, "9999-12-31 23:59:59"]).first # composite primary key gem
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end
  
  # is called from EeKonto and ZeKonto when they're deleted and
  # checks if the last konto was deleted that corresponds to a
  # lonely OzbKonto object. The function destroys the record if
  # it's a record without any children.
  def self.destroy_yourself_if_you_are_alone(ktoNr)
    o = self.latest(ktoNr)
      
    if !o.nil?
      # checks if the latest EeKonto and ZeKonto are available
      # if not -> delete Ozb
      # otherwise -> do not delete Ozb
      if o.ee_konto.nil? && o.ze_konto.nil?
        o.destroy
      end
    end
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
    def set_assoc_attributes
      eeKonto = EeKonto.latest(self.ktoNr)
      if (!eeKonto.nil?)
        eeKonto.sachPnr = self.sachPnr
      end
    end
    
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
end
