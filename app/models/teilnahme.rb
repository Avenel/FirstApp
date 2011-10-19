class Teilnahme < ActiveRecord::Base

   set_table_name "Teilnahme"

   attr_accessible :pnr, :vnr, :teilnArt
   set_primary_keys :pnr, :vnr

   belongs_to :person # Done, getestet
   belongs_to :veranstaltung, :inverse_of => :teilnahme, :foreign_key => :vnr # Done, getestet

end
