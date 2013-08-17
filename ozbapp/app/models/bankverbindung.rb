# encoding: UTF-8
require "HistoricRecord.rb"

class Bankverbindung < ActiveRecord::Base
    include HistoricRecord

  self.table_name = "Bankverbindung"
  self.primary_keys = :ID, :GueltigVon

  # Necessary for historization
  def get_primary_keys 
    return {"ID" => self.ID}
  end

  def set_primary_keys(values)
    self.ID = values["ID"]
  end

  # attributes
  # accept only and really only attr_accessible if you want that a user is able to mass-assign these attributes!
  attr_accessible :ID, :GueltigVon, :GueltigBis, :Pnr, :BankKtoNr, :IBAN, :BLZ,  
                  :SachPnr, :Bank_attributes
  
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
  

  # Validations
  validates :Pnr, :presence => { :message => "Bitte geben Sie die Mitglieder-Nummer der Person an." }
  validates :BankKtoNr, :presence => { :format => { :with => /[0-9]+/ }, :message => "Bitte geben Sie eine gültige Bankkonto-Nummer an (nur Zahlen 0-9)." }
  validates :IBAN, :presence => true, :format => { :with => /^[a-zA-Z]{2}[0-9]{2}[a-zA-Z0-9]{4}[0-9]{7}([a-zA-Z0-9]?){0,16}$/i, :message => "Bitte geben Sie eine valide BLZ an." }
  validates :BLZ, :presence => true, :format => { :with => /^[0-9]{8}$/i, :message => "Bitte geben Sie eine valide BLZ an." }

  validate :bank_exists
  validate :pnr_exists
  
  # callbacks
  before_create :set_valid_time
  before_update :set_new_valid_time
  after_update :save_copy
  
   # Associations
  belongs_to :Person,
    :foreign_key => :Pnr,
    :conditions => proc { ["GueltigBis = ?", self.GueltigBis] }

  has_one :ee_konto,
    :foreign_key => :BankId,
    :autosave => true,
    :conditions => proc { ["GueltigBis = ?", self.GueltigBis] } 

  belongs_to :Bank,
    :foreign_key => :BLZ,
    :autosave => true

  accepts_nested_attributes_for :Bank, :reject_if => :bank_already_exists

  def bank_exists 
    if Bank.where("BLZ = ?", self.blz).empty? then
      return false
    else
      return true
    end
  end

  def pnr_exists 
    if Person.where("Pnr = ?", self.pnr).empty? then
      return false
    else
      return true
    end
  end
  
  def Bankverbindung.get(id, date = Time.now)
    begin
      return Adresse.find(:all, :conditions => ["ID = ? AND GueltigVon <= ? AND GueltigBis > ?", id, date, date]).first
    rescue ActiveRecord::RecordNotFound
      return nil
    end
  end

  # (non static) get latest instance of model
  def getLatest()
    return Bankverbindung.get(self.ID)
  end
  
  def self.latest(id)
    return Bankverbindung.get(self.ID)
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

end
