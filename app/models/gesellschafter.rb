class Gesellschafter < ActiveRecord::Base

   set_table_name "Gesellschafter"

   attr_accessible :mnr, :faSteuerNr, :faLfdNr, :wohnsitzFinanzamt, :notarPnr, :beurkDatum

end
