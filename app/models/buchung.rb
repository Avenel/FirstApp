class Buchung < ActiveRecord::Base

	set_primary_keys :buchjahr, :ktonr, :bnkreis, :belegnr, :typ
	
	has_one :OzbKonto

end
