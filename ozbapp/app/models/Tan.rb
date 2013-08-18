class Tan < ActiveRecord::Base
  
	self.table_name = "Tan"
  self.primary_keys = :Mnr, :ListNr, :TanNr
  
  # attributes
  attr_accessible :Mnr, :ListNr, :TanNr, :Tan, :VerwendetAm, :Status 

  # column names
  HUMANIZED_ATTRIBUTES = {
    :Mnr        => 'Mitglieds-Nr.',
    :ListNr      => 'Tanlisten Nummer',
    :TanNr  => "Tanlisten Nummer (FK)",
    :Tan => "Tannummer",
    :VerwendetAm => "Verwendet Am",
    :Status => "Status"
  }
  
  def self.human_attribute_name(attr, options={})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end  

  # Validations
  validates :Mnr, :presence => true, :format => { :with => /^([0-9]+)$/i }
  validates :ListNr, :presence => true
  validates :TanNr, :presence => true
  validates :Tan, :presence => true
  validates :VerwendetAm, :presence => true

  # enum Status
  AVAILABLE_STATUS = %W(n d a) # n = neu, a = aktiviert, d = deaktiviert
  validates :Status, :presence => true, :inclusion => { :in => AVAILABLE_STATUS, :message => "%{value} is not a valid status (n, d, a" } 
end