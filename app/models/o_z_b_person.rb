class OZBPerson < ActiveRecord::Base
   
	 set_table_name "OZBPerson"
	 set_primary_key :mnr
	 
	# Include default devise modules. Others available are:
	# :token_authenticatable, :lockable, :timeoutable, :registerable, 
	# :confirmable, :recoverable and :activatable
	#devise :database_authenticatable, :rememberable, :trackable, :valmnratable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :mnr, :password
  # attr_accessible :mnr, :ueberPnr, :passwort, :pwAendDatum, :gesperrt

   has_one :mitglied, :foreign_key => :mnr
   has_one :student, :foreign_key => :mnr
   has_one :buchungonline, :foreign_key => :mnr
   has_one :tanliste, :foreign_key => :mnr
   has_one :gesellschafter, :foreign_key => :mnr
   belongs_to :person
   
   has_many :buergschaft, :foreign_key => :mnr

end
