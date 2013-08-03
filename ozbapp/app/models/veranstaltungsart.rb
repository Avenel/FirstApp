class Veranstaltungsart < ActiveRecord::Base
	self.table_name = "Veranstaltungsart"
	self.primary_key =  :VANr

	attr_accessible  :VANr,:VABezeichnung
	
	# Validations
	validates :VANr, :presence => true, :format => { :with => /^([0-9]+)$/i }
	validates :VABezeichnung, :presence => true

	# Relations 
	has_many :Veranstaltung, :foreign_key => :Vnr
	
	def Veranstaltungsart.get(vanr)
		Veranstaltungsart.find(:all, :conditions => {:VANr => vanr})
	end
end
