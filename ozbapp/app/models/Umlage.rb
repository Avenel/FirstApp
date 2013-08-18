class Umlage < ActiveRecord::Base
	
	self.table_name = "Umlage"
	self.primary_keys = :Jahr

	# attributes
	attr_accessible :Jahr, :RDU, :KDU

	# Validations
	validates :Jahr, :presence => true, :numericality =>{:greater_than_or_equal_to => 0 }
	validates :KDURate, :presence => true, :numericality =>{:greater_than_or_equal_to => 0.01 }
 	validates :RDURate, :presence => true, :numericality =>{:greater_than_or_equal_to => 0.01 }
end