class Bankverbindung < ActiveRecord::Base
   
   set_table_name "Bankverbindung"

   attr_accessible :id, :pnr, :bankKtoNr, :blz, :bic, :iban, :bankName   

end
