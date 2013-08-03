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
                  :SachPnr, :email, :remember_me, :password

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

  # Validations
  validates :Mnr, :presence => true
  validates :Antragsdatum, :presence => true
  
  # technical attributes
  validate :password_complexity
  validate :person_exists
  validate :ueber_person_exists


  # Wenn es produktiv geht, die minimale länge des passworts auf 6 oder höher Zeichen anseten
  def password_complexity
    if password.present? and password.match(/^(?=.*[^a-zA-Z])(?=.*[a-z])(?=.*[A-Z])\S{2,}$/i) then
      return true
    else
      errors.add :password, "sollte mindestens eine Ziffer und/oder Sonderzeichen wie +-_# usw. enthalten
                 Deutsche Umlaute erlaubt
                 Gross-/Kleinschreibung wird unterschieden
                 Mindestens 2 Zeichen lang"
      return false
    end
  end

  def person_exists
    person = Person.where("pnr = ?", mnr)
    if person.empty? then
      errorString = String.new("Es konnte keine zugehörige Person zu der angegebenen Mnr (#{mnr}) gefunden werden.")
      errors.add :mnr, errorString
      return false
    end
    return true
  end

  def ueber_person_exists
    person = Person.where("pnr = ?", ueberPnr)
    if person.empty? then
      errorString = String.new("Es konnte keine zugehörige Person zu der angegebenen UeberPnr (#{ueberPnr}) gefunden werden.")
      errors.add :ueberPnr, errorString 
      return false
    end
    return true
  end

  ### Beziehungen
  has_many :Person, :foreign_key => :Pnr # Done, getestet  

  has_one :Mitglied, :foreign_key => :Mnr, :dependent => :destroy  # Done, getestet
  has_one :Student, :foreign_key => :Mnr, :dependent => :destroy # Done, ungetestet
  has_one :Gesellschafter, :foreign_key => :Mnr, :dependent => :destroy # Done, getestet

  has_many :Sonderberechtigung, :foreign_key => :Mnr, :dependent => :delete_all 

end