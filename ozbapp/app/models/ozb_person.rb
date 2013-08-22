# encoding: UTF-8
class OZBPerson < ActiveRecord::Base

  self.table_name = "OZBPerson"
  self.primary_key = :Mnr

  # attributes  
  attr_accessible :Mnr, :UeberPnr, :PWAendDatum, 
                  :Antragsdatum, :Aufnahmedatum, :Austrittsdatum, :Schulungsdatum, :SachPnr

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
  
  validate :person_exists

  def person_exists
    person = Person.where("pnr = ?", self.Mnr)
    if person.empty? then
      errorString = String.new("Es konnte keine zugehörige Person zu der angegebenen Mnr (#{mnr}) gefunden werden.")
      errors.add :mnr, errorString
      return false
    end
    return true
  end

  # Associations
  has_many :Sonderberechtigung,
    :primary_key => :Mnr, # column in Sonderberechtigung 
    :foreign_key => :Mnr, # column in OZBPerson,
    :dependent => :destroy

  belongs_to :Person,
    :primary_key => :Pnr,
    :foreign_key => :Mnr,
    # Nur mit der aktuellsten Version der Person verknüpfen 
    :conditions => proc { ["GueltigBis = ?", "9999-12-31 23:59:59"] }

  has_one :Gesellschafter,
    :primary_key => :Mnr,
    :foreign_key => :Mnr,
    # Nur mit der aktuellsten Version verknüpfen 
    :conditions => proc { ["GueltigBis = ?", "9999-12-31 23:59:59"] },
    :dependent => :destroy

  has_one :Partner,
    :primary_key => :Mnr,
    :foreign_key => :Mnr,
    # Nur mit der aktuellsten Version verknüpfen 
    :conditions => proc { ["GueltigBis = ?", "9999-12-31 23:59:59"] },
    :dependent => :destroy

  has_one :Mitglied,
    :primary_key => :Mnr,
    :foreign_key => :Mnr,
    # Nur mit der aktuellsten Version verknüpfen 
    :conditions => proc { ["GueltigBis = ?", "9999-12-31 23:59:59"] },
    :dependent => :destroy

  has_one :Student,
    :primary_key => :Mnr,
    :foreign_key => :Mnr,
    # Nur mit der aktuellsten Version verknüpfen 
    :conditions => proc { ["GueltigBis = ?", "9999-12-31 23:59:59"] },
    :dependent => :destroy

  has_many :Tanliste,
    :foreign_key => :Mnr,
    :dependent => :destroy

  has_many :OzbKonto,
    :primary_key => :Mnr,
    :foreign_key => :Mnr,
    # Nur mit der aktuellsten Version verknüpfen 
    :conditions => proc { ["GueltigBis = ?", "9999-12-31 23:59:59"] },
    :dependent => :destroy

  has_one :Buergschaft,
    :primary_key => :Mnr_G,
    :foreign_key => :Mnr,
    # Nur mit der aktuellsten Version verknüpfen 
    :conditions => proc { ["GueltigBis = ?", "9999-12-31 23:59:59"] },
    :dependent => :destroy

  has_many :BuchungOnline,
    :primary_key => :Mnr,
    :foreign_key => :Mnr,
    :dependent => :destroy

  # "Experimental"
  has_many :EeKonto,
    :through => :OzbKonto

  has_many :ZeKonto,
    :through => :OzbKonto


  # Calbacks
  before_destroy :check_destroy_conditions
  after_destroy :destroy_associated_objects

  # On Destroy Regel
  # 1. Wenn es zu der Mnr eine Buchung gegeben hat, darf die Person nicht mehr
  #    gelöscht werden.
  # 2. Wenn ein neues Mitglied ein Konto mit einer KKL besitzt, innerhalb von 6 Wochen keinen Zahlungseingang (Einlage)
  #    getätigt hat, darf diese gelöscht werden.
  def check_destroy_conditions
    # Check 1.
    if self.Buchung.any? then
      return false
    end

    # Check 2.
    if self.EeKonto.any? and self.Buchung.any? then
      buchungen = self.Buchung.find().order("BuchDatum ASC")

      buchungen.each do |buchung| 
        # Buchung innerhalb der ersten 6 Wochgen getätigt?
        if buchung.BuchDatum < self.Aufnahmedatum + 7.weeks then 
          # Buchung auf ein EEKonto?
          if buchung.OzbKonto.EeKonto.any? then
            return false
          end
        end
      end
    end

    return true
  end

  # Destroy associated (historic) objects
  def destroy_associated_objects
    # Gesellschafter
    gesellschafter = Gesellschafter.find(:all, :conditions => ["Mnr = ?", self.Mnr])
    gesellschafter.each do |g|
      g.destroy()
    end

    # Partner
    partner = Partner.find(:all, :conditions => ["Mnr = ?", self.Mnr])
    partner.each do |p|
      p.destroy()
    end

    # Mitglied
    mitglieder = Mitglied.find(:all, :conditions => ["Mnr = ?", self.Mnr])
    mitglieder.each do |m|
      m.destroy()
    end

    # Student
    studenten = Student.find(:all, :conditions => ["Mnr = ?", self.Mnr])
    studenten.each do |s|
      s.destroy()
    end

    # OzbKonto
    konten = OzbKonto.find(:all, :conditions => ["Mnr = ?", self.Mnr])
    konten.each do |k|
      k.destroy()
    end

    # Buergschaft
    buergschaften = Buergschaft.find(:all, :conditions => ["Mnr = ?", self.Mnr])
    buergschaften.each do |b|
      b.destroy()
    end

    # BuchungOnline
    buchungenOnline = BuchungOnline.find(:all, :conditions => ["Mnr = ?", self.Mnr])
    buchungenOnline.each do |bO|
      bO.destroy()
    end
  end

end