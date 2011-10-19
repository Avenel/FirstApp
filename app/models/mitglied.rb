class Mitglied < ActiveRecord::Base

  set_table_name "Mitglied"

  attr_accessible :mnr, :rvDatum

  belongs_to :ozb_person
  
end
