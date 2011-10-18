class Administrator < ActiveRecord::Base
   
   set_table_name "Administrator"
   
   set_primary_key :pnr
   
   attr_accessible :adminPw, :adminEmail
   
   #validates :adminEmail, :email => true

   belongs_to :Person

end
