class OzbPerson < ActiveRecord::Base
   
   set_table_name "OZBPerson"

   attr_accessible :mnr, :ueberPnr, :passwort, :pwAendDatum, :gesperrt

end
