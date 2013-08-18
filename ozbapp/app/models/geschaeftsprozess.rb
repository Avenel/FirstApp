class Geschaeftsprozess < ActiveRecord::Base
	
	self.table_name = "Geschaeftsprozess"
	self.primary_key = :ID

	# attributes
	attr_accessible :ID, :Beschreibung, :IT, :MV, :RW, :ZE, :OeA

	# Validations
	validates :Beschreibung, :presence => true
	validates :IT, :presence => true
	validates :MV, :presence => true
	validates :RW, :presence => true
	validates :ZE, :presence => true
	validates :OeA, :presence => true
end
