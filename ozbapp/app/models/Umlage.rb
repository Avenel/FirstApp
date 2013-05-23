class Umlage < ActiveRecord::Base
	self.table_name = "Umlage"
	self.primary_keys = :Jahr

	#attributes
	attr_accessible :Jahr, :RDU, :KDU
end