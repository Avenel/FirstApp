class Veranstaltungsart < ActiveRecord::Base
	set_table_name "veranstaltungsart"
	set_primary_key  :VANr
	
	
	
	
	
	attr_accessible  :VANr,:VABezeichnung
	
	has_one :Veranstaltung, :foreign_key => :Vnr, :dependent => :destroy
	
	def Veranstaltungsart.get(vanr)
		#Veranstaltungsart.where(:id => id)
		Veranstaltungsart.find(:all, :conditions => {:VANr => vanr})
	end
end
