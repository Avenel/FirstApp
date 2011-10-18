class Teilnahme < ActiveRecord::Base

   set_table_name "Tanliste"

   attr_accessible :pnr, :vnr, :teilnArt
   set_primary_keys :pnr, :vnr

end
