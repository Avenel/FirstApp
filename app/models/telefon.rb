class Telefon < ActiveRecord::Base

   set_table_name "Telefon"

   attr_accessible :pnr, :lfdNr, :telefonNr, :telefonTyp
   set_primary_keys :pnr, :lfdNr
   

end
