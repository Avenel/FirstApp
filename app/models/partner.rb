class Partner < ActiveRecord::Base

   set_table_name "Partner"

   attr_accessible :mnr, :mnrO, :berechtigung
   
   validates_presence_of :mnrO, :berechtigung

   belongs_to :person

end
