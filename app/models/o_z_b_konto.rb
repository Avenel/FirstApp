class OZBKonto < ActiveRecord::Base

      set_table_name "OZBKonto"

   attr_accessible :ktoNr, :mnr, :ktoEinrDatum, :waehrung, :wSaldo, :pSaldo, :saldoDatum

end
