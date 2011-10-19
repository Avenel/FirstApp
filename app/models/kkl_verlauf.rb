class KKLVerlauf < ActiveRecord::Base

   set_table_name "KKLVerlauf"

   attr_accessible :ktoNr, :kklAbDatum, :kkl
   set_primary_keys :ktoNr, :kklAbDatum    

end
