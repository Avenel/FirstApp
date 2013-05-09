# encoding: UTF-8
class Bankverbindung < ActiveRecord::Base
  self.table_name = "Bankverbindung"
  self.primary_keys = :ID, :GueltigVon
  
  # aliases
  alias_attribute :id, :ID
  alias_attribute :pnr, :Pnr
  alias_attribute :bankKtoNr, :BankKtoNr
  alias_attribute :blz, :BLZ
  alias_attribute :iban, :IBAN
  
  # associations
  belongs_to :person,
    :foreign_key => :Pnr,
    :conditions => proc { ["GueltigBis = ?", self.GueltigBis] } # condition -> for historic db
                                                                # do never ever rely that the current record is the newest one (GueltigBis = "9999-12-31 23:59:59")
                                                                # it might be possible that older records are focused. So you should come in trouble when selecting 
                                                                # not the corresponding record for that association.
                                                                # PLEASE NOTE: This associated child records must be updated to the SAME DateTime and EVERYTIME this
                                                                # record is updated, otherwise it would corrupt the underlying logic model.

  has_one :ee_konto,
    :foreign_key => :BankId,
    :autosave => true,
    :conditions => proc { ["GueltigBis = ?", self.GueltigBis] } # condition -> for historic db
                                                                # do never ever rely that the current record is the newest one (GueltigBis = "9999-12-31 23:59:59")
                                                                # it might be possible that older records are focused. So you should come in trouble when selecting 
                                                                # not the corresponding record for that association.
                                                                # PLEASE NOTE: This associated child records must be updated to the SAME DateTime and EVERYTIME this
                                                                # record is updated, otherwise it would corrupt the underlying logic model.

  belongs_to :Bank,
    :foreign_key => :BLZ,
    :autosave => true
  
  # attributes
  # accept only and really only attr_accessible if you want that a user is able to mass-assign these attributes!
  attr_accessible :ID, :Pnr, :BankKtoNr, :BLZ, :IBAN, :GueltigVon, :GueltigBis, :Bank_attributes
  accepts_nested_attributes_for :Bank, :reject_if => :bank_already_exists
  
  # validations
  validates :BankKtoNr, :presence => { :format => { :with => /[0-9]+/ }, :message => "Bitte geben Sie eine gültige Bankkonto-Nummer an (nur Zahlen 0-9)." }
  #validates :BLZ, :presence => { :message => "Bitte geben Sie eine BLZ an!" }
  validates :Pnr, :presence => { :message => "Bitte geben Sie die Mitglieder-Nummer der Person an." }
  #validates_associated :Bank
  
  # callbacks
  #after_commit :set_id_for_eekonto
  before_create :set_valid_time, :set_valid_id
  before_update :set_new_valid_time
  after_destroy :destroy_historic_records, :destroy_bank_if_this_is_last_bankverbindung
  
  # column names
  HUMANIZED_ATTRIBUTES = {
    :ID         => 'Bank ID',
    :GueltigVon => 'Gültig von',
    :GueltigBis => 'Gültig bis',
    :Pnr        => 'Personen-Nr.',
    :BankKtoNr  => 'Bank Konto-Nr.',
    :IBAN       => 'IBAN',
    :BLZ        => 'BLZ'
  }

  def self.human_attribute_name(attr, options={})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end
  
  # bound to callback
  def set_valid_id
    if (self.ID.nil?)
      b = Bankverbindung.find(:all, :order => "ID ASC").last
      self.ID = b.ID + 1
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
    if(self.GueltigBis > "9999-01-01 00:00:00")
      @@copy            = self.get(self.id)
      @@copy            = @@copy.dup
      @@copy.id         = self.id
      @@copy.GueltigVon = self.GueltigVon
      @@copy.GueltigBis = Time.now
      
      self.GueltigVon   = Time.now
      self.GueltigBis   = Time.zone.parse("9999-12-31 23:59:59")
    end
  end

   after_update do
      if !@@copy.nil?
        @@copy.save(:validation => false)
        @@copy = nil
      end
   end
  
  def get(id, date = Time.now)
    Bankverbindung.find(:all, :conditions => ["ID = ? AND GueltigVon <= ? AND GueltigBis > ?", id, date, date]).first
  end
  
  def self.latest(id)
    begin
      self.find(:all, :conditions => ["ID = ? AND GueltigVon <= ? AND GueltigBis > ?", id, Time.now, Time.now]).first
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end
  
  private
    # Checks if already a Bank with given primary key (BLZ) exists
    # returns true if so, false otherwise
    def bank_already_exists(bank_attr)
      if (Bank.find_by_BLZ(bank_attr["BLZ"]).nil?)
        return false
      else
        return true
      end
    end

    # bound to callback
    def destroy_historic_records
      # find all historic records that belongs to this record and destroy(!) them
      # note: destroy should always destroy all the corresponding association objects
      # if the association option :dependent => :destroy is set correctly
      recs = self.class.find(:all, :conditions => ["ID = ? AND GueltigBis < ?", self.ID, self.GueltigBis])
      
      recs.each do |r|
        r.destroy
      end
    end
    
    def destroy_bank_if_this_is_last_bankverbindung
      Bank.destroy_yourself_if_you_are_alone(self.BLZ)
    end
end
