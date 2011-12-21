class Gesellschafter < ActiveRecord::Base

  set_table_name "Gesellschafter"
  
  set_primary_key :mnr
  
  attr_accessible :mnr, :faSteuerNr, :faLfdNr, :wohnsitzFinanzamt, :notarPnr, :beurkDatum
  
  validates_presence_of :faSteuerNr, :faLfdNr, :wohnsitzFinanzamt

  belongs_to :OZBPerson
end
