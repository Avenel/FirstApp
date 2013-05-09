class Geschaeftsprozess < ActiveRecord::Base
	set_table_name "Geschaeftsprozess"
	set_primary_key :ID
	attr_accessible :IT, :MV, :RW, :ZE, :OeA
end
