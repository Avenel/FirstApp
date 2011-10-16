class Bankverbindung < ActiveRecord::Base

   attr_accessible :id, :pnr, :bankKtoNr, :blz, :bic, :iban, :bankName   

end
