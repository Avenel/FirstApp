class Veranstaltungsart < ActiveRecord::Base

   set_table_name "Veranstaltungsart"
   set_primary_key :id

   attr_accessible :id, :vaBezeichnung
   
   has_many :veranstaltung, :foreign_key => :vid, :inverse_of => :veranstaltungsart # Done, getestet

end
