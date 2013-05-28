# encoding: UTF-8
class OZBPerson < ActiveRecord::Base
  self.table_name = "OZBPerson"

  self.primary_key = :Mnr
  
  alias_attribute :mnr, :Mnr
  alias_attribute :ueberPnr, :UeberPnr
  alias_attribute :pwAendDatum, :PWAendDatum
  alias_attribute :antragsdatum, :Antragsdatum
  alias_attribute :aufnahmedatum, :Aufnahmedatum
  alias_attribute :austrittsdatum, :Austrittsdatum
  alias_attribute :schulungsdatum, :Schulungsdatum
  alias_attribute :gesperrt, :Gesperrt
  alias_attribute :sachPnr, :SachPnr
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :trackable,
         :validatable
  
  attr_accessible :Mnr, :UeberPnr, :PWAendDatum, 
                  :Antragsdatum, :Aufnahmedatum, :Austrittsdatum, :Schulungsdatum,
                  :Gesperrt, :SachPnr,
                  :password, :email

  # column names
  HUMANIZED_ATTRIBUTES = {
    :Mnr            => 'Mitglied-Nr.',
    :Antragsdatum   => 'Antragsdatum',
    :Aufnahmedatum  => 'Aufnahmedatum',
    :Austrittsdatum => 'Austrittsdatum',
    :Schulungsdatum => 'Schulungsdatum'    
  }

  def self.human_attribute_name(attr, options={})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  ### Validierung
  validates_presence_of :Mnr, :UeberPnr, :Antragsdatum, :email

  validate :password_complexity
  validate :person_exists

  def password_complexity
    if password.present? and not password.match(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+/)
     errors.add :password, "sollte mindestens eine Ziffer und/oder Sonderzeichen wie +-_# usw. enthalten
                 Deutsche Umlaute erlaubt
                 Gross-/Kleinschreibung wird unterschieden"
    end
  end

  def person_exists
    person = Person.where("pnr = ?", ueberPnr)
    if person.empty? then
      errors.add :ueberPnr, "Es konnte keine zugehörige Person zu der angegebenen UeberPnr gefunden werden."
    end
  end

  ### Beziehungen
  has_many :Person, :foreign_key => :Pnr # Done, getestet  

  has_one :Mitglied, :foreign_key => :Mnr, :dependent => :destroy  # Done, getestet
  has_one :Student, :foreign_key => :Mnr, :dependent => :destroy # Done, ungetestet
  has_one :Gesellschafter, :foreign_key => :Mnr, :dependent => :destroy # Done, getestet

  has_many :Sonderberechtigung, :foreign_key => :Mnr, :dependent => :delete_all 

end