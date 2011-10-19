class Veranstaltung < ActiveRecord::Base

   set_table_name "Veranstaltung"

   set_primary_key :vnr   
   
   attr_accessible :vnr, :vid, :vaDatum, :vaOrt

   has_many :teilnahme, :foreign_key => :vnr

end
