class Veranstaltung < ActiveRecord::Base

   set_table_name "Veranstaltung"

   attr_accessible :vnr, :vid, :vaDatum, :vaOrt

end
