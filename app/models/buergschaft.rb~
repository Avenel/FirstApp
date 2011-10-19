class Buergschaft < ActiveRecord::Base
   
   set_table_name "Buergschaft"   
   
   attr_accessible :pnrB, :mnrG, :ktoNr, :sichAbDatum, :sichEndDatum, :sichBetrag, :sichKurzBez
   set_primary_keys :pnrB, :mnrG
   
   belongs_to :person

end
