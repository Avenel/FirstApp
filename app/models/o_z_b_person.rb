class OZBPerson < ActiveRecord::Base
   
	 set_table_name "OZBPerson"
	 set_primary_key :id
	 
	# Include default devise modules. Others available are:
	# :token_authenticatable, :lockable, :timeoutable, :registerable, 
	# :confirmable, :recoverable and :activatable
	devise :database_authenticatable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :id, :password
  # attr_accessible :id, :ueberPnr, :passwort, :pwAendDatum, :gesperrt

   has_one :mitglied, :foreign_key => :id
   has_one :student, :foreign_key => :id
   has_one :buchungonline, :foreign_key => :id
   has_one :tanliste, :foreign_key => :id
   has_one :gesellschafter, :foreign_key => :id
   belongs_to :person
   
   has_many :buergschaft, :foreign_key => :id

end
