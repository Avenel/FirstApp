class Veranstaltung < ActiveRecord::Base
	self.table_name = "Veranstaltung"
	self.primary_key = :Vnr
	
	
  	attr_accessible :VADatum, :VAOrt, :VANr, :Vnr, :SachPnr
	
	belongs_to :Veranstaltungsart, :foreign_key => :id
	has_many :Teilnahme, :foreign_key => :Vnr
end
