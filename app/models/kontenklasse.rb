class Kontenklasse < ActiveRecord::Base

   set_table_name "Kontenklasse"

   attr_accessible :kkl, :kklAbDatum, :prozent

end
