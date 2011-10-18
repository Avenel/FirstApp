class Administrator < ActiveRecord::Base
   
   set_table_name "Administrator"
   
   
   attr_accessible :adminPw, :adminEmail
   
   #validates :adminEmail, :email => true

   belongs_to :Person, :foreign_key => :ueberPnr
   set_primary_key :pnr

end
