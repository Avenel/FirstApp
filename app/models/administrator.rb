class Administrator < ActiveRecord::Base
   
   set_table_name "Administrator"
   
   
   attr_accessible :adminPw, :adminEmail
   
   validates :adminEmail, :email => true

end
