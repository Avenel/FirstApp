class Foerdermitglied < ActiveRecord::Base

   set_table_name "Foerdermitglied"

   attr_acessible :pnr, :region, :foerderbeitrag

end
