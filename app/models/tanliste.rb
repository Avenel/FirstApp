class Tanliste < ActiveRecord::Base

  set_table_name "Tanliste"

  attr_accessible :mnr, :listNr, :status
  set_primary_keys :mnr, :listNr
  
  belongs_to :ozbperson

end
