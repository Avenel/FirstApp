class Veranstaltungsart < ActiveRecord::Base

   set_table_name "Veranstaltungsart"

   attr_accessible :id, :vaBezeichnung

end
