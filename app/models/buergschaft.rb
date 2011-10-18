class Buergschaft < ActiveRecord::Base
   
   set_table_name "Buergschaft"   
   
   attr_accessible :pnrB, :pnrG, :ktoNr, :sichAbDatum, :sichEndDatum, :sichBetrag, :sichKurzBez
   set_primary_keys :pnrB, :pnrG

end
