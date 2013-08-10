class BuchungOnline < ActiveRecord::Base
	self.table_name = "BuchungOnline"
  self.primary_keys = :ID
  
  # attributes
  attr_accessible :ID, :Mnr, :UeberwDatum, :SollKtoNr, :HabenKtoNr,
  								:Punkte, :Tan, :BlockNr

  # column names
  HUMANIZED_ATTRIBUTES = {
    :Mnr        => 'Mitglieds-Nr.',
    :UeberwDatum => "Ueberweisungsdatum",
    :Tan => "Tannummer"
  }
  
  def self.human_attribute_name(attr, options={})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end  

  # Validations
  validates :Mnr, :presence => true, :format => { :with => /^([0-9]+)$/i }
  validates :UeberwDatum, :presence => true
  validates :SollKtoNr, :presence => true, :format => { :with => /^([0-9]{5})$/i }
  validates :HabenKtoNr, :presence => true, :format => { :with => /^([0-9]{5})$/i }
  validates :Tan, :presence => true, :format => { :with => /^([0-9]{5})$/i }
  validates :BlockNr, :presence => true, :format => { :with => /^([0-9]{1,5})$/i }

  # Relations
  belongs_to :OZBPerson, :foreign_key => :Mnr

end