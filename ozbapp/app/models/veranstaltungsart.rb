class Veranstaltungsart < ActiveRecord::Base
	
	self.table_name = "Veranstaltungsart"
	self.primary_key =  :VANr

	# attributes
	attr_accessible  :VANr,:VABezeichnung
	
	# Validations
	validates :VANr, :presence => true, :format => { :with => /^([0-9]+)$/i }
	validates :VABezeichnung, :presence => true

	# Associations 
	has_many :Veranstaltung, :foreign_key => :Vnr
	
	def Veranstaltungsart.get(vanr)
    begin
      Veranstaltungsart.find(:all, :conditions => ["VANr = ?", vanr]).first
    rescue ActiveRecord::RecordNotFound
      return nil
    end
	end
end
