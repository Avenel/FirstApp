class Tanliste < ActiveRecord::Base
  
	self.table_name = "Tanliste"
  self.primary_keys = :Mnr, :ListNr
  
  # attributes
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

  belongs_to :OZBPerson,
    :primary_key => :Mnr,
    :foreign_key => :Mnr

  has_many :Tan,
    :primary_key => :Mnr,
    :foreign_key => :Mnr,
    :conditions => proc { ["ListNr = ?", self.ListNr] },
    :dependant => :destroy

  # Callbacks
  before_destroy :check_destroy_conditions

  # Destroy Regel
  # Tanliste inkl. Tans dürfen nur gelöscht werden, wenn diese noch nicht aktiviert oder deaktiviert wurden:
  # Status != a && != d => Status = n 
  def check_destroy_conditions
    if self.Status == "n" then
      return true
    else
      return false
    end
  end


end