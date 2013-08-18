require "HistoricRecord.rb"

class Mitglied < ActiveRecord::Base
    include HistoricRecord

  self.table_name = "Mitglied"
  self.primary_keys = :Mnr, :GueltigVon

  # Necessary for historization
  def get_primary_keys 
    return {"Mnr" => self.Mnr}
  end

  def set_primary_keys(values)
    self.Mnr = values["Mnr"]
  end

  # attributes  
  attr_accessible :Mnr, :GueltigVon, :GueltigBis, :RVDatum, :SachPnr

  # column names
  HUMANIZED_ATTRIBUTES = {
    :Mnr       => 'Mitglied-Nr.',
    :RVDatum   => 'RVDatum'
  }

  def self.human_attribute_name(attr, options={})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end  

  # Validations
  validates :Mnr, :presence => true, :format => { :with => /^([0-9]+)$/i }

  # callbacks
  before_create :set_valid_time
  before_update :set_new_valid_time
  after_update :save_copy

  # Associations
  belongs_to :OZBPerson, 
          :foreign_key => :Mnr

  # Returns nil if at the given time no person object was valid
  def Mitglied.get(mnr, date = Time.now)
    begin
      return Mitglied.find(:all, :conditions => ["Mnr = ? AND GueltigVon <= ? AND GueltigBis > ?", mnr, date, date]).first
    rescue ActiveRecord::RecordNotFound
      return nil
    end
  end

  # (non static) get latest instance of model
  def getLatest()
    return Mitglied.get(self.Mnr)
  end

end
