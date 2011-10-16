class OzbKonto < ActiveRecord::Base

   attr_accessible :ktoNr, :mnr, :ktoEinrDatum, :waehrung, :wSaldo, :pSaldo, :saldoDatum

end
