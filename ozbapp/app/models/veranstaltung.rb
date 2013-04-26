class Veranstaltung < ActiveRecord::Base
	self.set_table_name "veranstaltung"
	set_primary_key  :Vnr
	
	
  	attr_accessible :VADatum, :VAOrt, :VANr, :Vnr, :SachPnr
	
	belongs_to :Veranstaltungsart, :foreign_key => :id
	has_many :Teilnahme, :foreign_key => :Vnr
end
