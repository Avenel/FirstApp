class Gesellschafter < ActiveRecord::Base

  set_table_name "Gesellschafter"
  
  set_primary_key :mnr
  
  attr_accessible :mnr, :faSteuerNr, :faLfdNr, :wohnsitzFinanzamt, :notarPnr, :beurkDatum

  belongs_to :ozbperson
end
