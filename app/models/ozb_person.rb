class OZBPerson < ActiveRecord::Base
   
  set_table_name "OZBPerson"
  set_primary_key :mnr
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :mnr, :ueberPnr, :email, :password, :password_confirmation, :remember_me, :passwort, :pwAendDatum, :gesperrt
    
  has_one :mitglied, :foreign_key => :mnr  # Done, ungetestet
  has_one :student, :foreign_key => :mnr # Done, ungetestet
  has_one :buchungonline, :foreign_key => :mnr # Done, ungetestet
  has_many :ozbkonto, :foreign_key => :mnr # Done, ungetestet
  has_many :tanliste, :foreign_key => :mnr # Done, ungetestet
  has_one :gesellschafter, :foreign_key => :mnr # Done, ungetestet
  belongs_to :person # Done, getestet
  
  has_many :buergschaft, :foreign_key => :mnrG # Done, ungetestet

end
