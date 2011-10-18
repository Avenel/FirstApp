class Telefon < ActiveRecord::Base

   set_table_name "Telefon"

   attr_accessible :pnr, :lfdNr, :telefonNr, :telefonTyp
   set_primary_key :lfdNr
   
   belongs_to :Person
end
