class Buchung < ActiveRecord::Base

   set_table_name "Buchung"

	attr_accessible   :buchJahr, :ktoNr, :bnKreis, :belegNr, :typ, :belegDatum, :buchDatum, 
	                  :buchungstext, :sollBetrag, :habenBetrag, :sollKtoNr, :habenKtoNr, 
	                  :wSaldoAcc, :punkte, :pSaldoAcc
	
	set_primary_keys :buchJahr, :ktoNr, :bnKreis, :belegNr, :typ
	
	has_one :OzbKonto

end
