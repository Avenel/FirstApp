class Geschaeftsprozess < ActiveRecord::Base
	
	self.table_name = "Geschaeftsprozess"
	self.primary_key = :ID

	# attributes
	attr_accessible :ID, :Beschreibung, :IT, :MV, :RW, :ZE, :OeA

	# Validations
	validates :Beschreibung, :presence => true
	validates :IT, :inclusion => {:in => [true, false]}
	validates :MV, :inclusion => {:in => [true, false]}
	validates :RW, :inclusion => {:in => [true, false]}
	validates :ZE, :inclusion => {:in => [true, false]}
	validates :OeA, :inclusion => {:in => [true, false]}
end
