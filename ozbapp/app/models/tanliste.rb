class Tanliste < ActiveRecord::Base
	self.table_name = "Tanliste"
  self.primary_keys = :Mnr, :ListNr
  
  attr_accessible :Mnr, :ListNr, :TanListDatum, :Status 

  # column names
  HUMANIZED_ATTRIBUTES = {
    :Mnr        => 'Mitglieds-Nr.',
    :ListNr      => 'Tanlisten Nummer',
    :TanListDatum  => 'Tanlisten Datum',
    :Status => 'Status'
  }
  
  def self.human_attribute_name(attr, options={})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end  

  # Validations
  validates :Mnr, :presence => true, :format => { :with => /^([0-9]+)$/i }
  validates :ListNr, :presence => true
  validates :TanListDatum, :presence => true

  # enum Status
  AVAILABLE_STATUS = %W(n d a) # n = neu, a = aktiviert, d = deaktiviert
  validates :Status, :presence => true, :inclusion => { :in => AVAILABLE_STATUS, :message => "%{value} is not a valid status (n, d, a" } 

end