# encoding: UTF-8
class EeKonto < ActiveRecord::Base
  self.table_name = "EEKonto"
  self.primary_keys = :KtoNr, :GueltigVon # two primary keys define an unique record
  
  # aliases
  alias_attribute :ktoNr, :KtoNr
  alias_attribute :bankId, :BankID
  alias_attribute :kreditlimit, :Kreditlimit
  alias_attribute :sachPnr, :SachPnr
  
  # attributes
  # accept only and really only attr_accessible if you want that a user is able to mass-assign these attributes!
  accepts_nested_attributes_for :Bankverbindung
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
  # validate always things you will accept nested attributes for!
  # do never validate things twice, this is silly for auto-error
  
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

  # GueltigVon und GueltigBis wird durch Model selbst gesetzt
  # Sachbearbeiter muss durch Controller oder abhängiges Model gesetzt werden!
  
  # Relations
  belongs_to :ozb_konto,
    :primary_key => :KtoNr, 
    :foreign_key => :KtoNr, 
    :conditions => proc { ["GueltigBis = ?", self.GueltigBis] } # condition -> for historic db
                                                                # do never ever rely that the current record is the newest one (GueltigBis = "9999-12-31 23:59:59")
                                                                # it might be possible that older records are focused. So you should come in trouble when selecting 
                                                                # not the corresponding record for that association.
                                                                # PLEASE NOTE: This associated child records must be updated to the SAME DateTime and EVERYTIME this
                                                                # record is updated, otherwise it would corrupt the underlying logic model.

  belongs_to :Bankverbindung,
    :primary_key => :ID,
    :foreign_key => :BankID, # associated column in ee_konto table!
    :class_name => "Bankverbindung", 
    :autosave => true, 
    #:dependent => :destroy, # does not work --> manually done via :after_destroy callback, see below!
    :conditions => proc { ["GueltigBis = ?", self.GueltigBis] } # condition -> for historic db
    
  has_one :ze_konto, 
    :foreign_key => :KtoNr,
    :dependent => :destroy, # must destroy the ze_konto, because it makes no sense that ze exists any longer
    :conditions => proc { ["GueltigBis = ?", self.GueltigBis] } # condition -> for historic db
                                                                # do never ever rely that the current record is the newest one (GueltigBis = "9999-12-31 23:59:59")
                                                                # it might be possible that older records are focused. So you should come in trouble when selecting 
                                                                # not the corresponding record for that association.
                                                                # PLEASE NOTE: This associated child records must be updated to the SAME DateTime and EVERYTIME this
                                                                # record is updated, otherwise it would corrupt the underlying logic model.

  belongs_to :sachbearbeiter, 
    :class_name => "Person", 
    :foreign_key => :Pnr, 
    :primary_key => :SachPnr, 
    :conditions => proc { ["GueltigBis = ?", self.GueltigBis] } # condition -> for historic db
                                                                # do never ever rely that the current record is the newest one (GueltigBis = "9999-12-31 23:59:59")
                                                                # it might be possible that older records are focused. So you should come in trouble when selecting 
                                                                # not the corresponding record for that association.
                                                                # PLEASE NOTE: This associated child records must be updated to the SAME DateTime and EVERYTIME this
                                                                # record is updated, otherwise it would corrupt the underlying logic model.


  # callbacks
  before_create :set_valid_time
  before_update :set_new_valid_time
  after_destroy :destroy_historic_records, :destroy_ozb_konto_if_this_is_last_konto, :destroy_bankverbindung
  
  
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
  def get(ktoNr, date = Time.now)
    EeKonto.find(:all, :conditions => ["KtoNr = ? AND GueltigVon <= ? AND GueltigBis > ?", ktoNr, date, date]).first
  end
  
  def self.latest(ktoNr)
    begin
      self.find(:all, :conditions => ["KtoNr = ? AND GueltigBis = ?", ktoNr, "9999-12-31 23:59:59"]).first # composite primary key gem
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end

  #NU  
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