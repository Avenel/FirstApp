class KKLVerlauf < ActiveRecord::Base

  set_table_name "KKLVerlauf"

  attr_accessible :ktoNr, :kklAbDatum, :kkl

  belongs_to :OZBKonto    # Done, ungetestet
  belongs_to :Kontenklasse # Done, ungetestet

end
