class OZBPerson < ActiveRecord::Base
   
  set_table_name "OZBPerson"
  set_primary_key :mnr
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :mnr, :ueberPnr, :email, :password, :password_confirmation, :remember_me, :passwort, :pwAendDatum, :gesperrt,
                  :canEditA, :canEditB, :canEditC, :canEditD # A: OZBPersonenverwaltung, B: Kontenverwaltung, C: Veranstaltung und Teilnahmeverwaltung,
                                                             # D:Tabellen (Veranstaltung, Kontoklassen, Projektgruppen)
    
  has_one :Mitglied, :foreign_key => :mnr, :dependent => :destroy  # Done, getestet
  has_one :Student, :foreign_key => :mnr, :dependent => :destroy # Done, ungetestet
  has_one :BuchungOnline, :foreign_key => :mnr, :dependent => :destroy # Done, getestet
  has_many :OZBKonto, :foreign_key => :mnr, :dependent => :delete_all # Done, getestet
  has_many :Tanliste, :foreign_key => :mnr, :dependent => :delete_all # Done, getestet
  has_one :Gesellschafter, :foreign_key => :mnr, :dependent => :destroy # Done, getestet
  belongs_to :Person, :foreign_key => :pnr # Done, getestet
  
  has_many :Buergschaft, :foreign_key => :mnrG, :dependent => :delete_all # Done, getestet
end
