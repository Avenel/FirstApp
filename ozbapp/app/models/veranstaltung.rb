class Veranstaltung < ActiveRecord::Base
	
	self.table_name = "Veranstaltung"
	self.primary_key = :Vnr
	
  # attributes
  attr_accessible :Vnr,  :VANr, :VADatum, :VAOrt, :SachPnr
	
  # Validations
  validates :Vnr, :presence => true, :format => { :with => /^([0-9]+)$/i }
  validates :VANr, :presence => true, :format => { :with => /^([0-9]+)$/i }
  validates :VADatum, :presence => true
  validates :VAOrt, :presence => true

  # Associations
  belongs_to :Veranstaltungsart, 
    :foreign_key => :VANr

  has_many :Teilnahme, 
    :primary_key => :Vnr,
    :foreign_key => :Vnr,
    :dependent => :restrict
    
end
