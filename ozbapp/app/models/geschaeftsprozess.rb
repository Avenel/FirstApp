class Geschaeftsprozess < ActiveRecord::Base
	self.table_name = "Geschaeftsprozess"
	self.primary_key = :ID
	attr_accessible :IT, :MV, :RW, :ZE, :OeA
end
