#!/bin/env ruby
# encoding: utf-8
require "HistoricRecord.rb"

class Person < ActiveRecord::Base
    include HistoricRecord

  self.primary_keys = :Pnr, :GueltigVon

  # Necessary for historization 
  def get_primary_keys 
    return {"Pnr" => self.Pnr}
  end

   def set_primary_keys(values)
    self.Pnr = values["Pnr"]
  end

  # attributes
  attr_accessible :Pnr, :GueltigVon, :GueltigBis, :Rolle, :Name, 
                  :Vorname, :Geburtsdatum, :EMail, :SperrKZ, 
                  :SachPnr, :AVAILABLE_ROLES

  # column names
  HUMANIZED_ATTRIBUTES = {
    :Pnr        => 'Personal-Nr.',
    :SperrKZ    => 'SperrKZ'
  }
   
  def self.human_attribute_name(attr, options={})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  # Validations
  validates :Pnr, :presence => true, :format => { :with => /^([0-9]+)$/i }
  
  # Role enum
  AVAILABLE_ROLES = %W(G M P S F)
  validates :Rolle, :presence => true, :inclusion => { :in => AVAILABLE_ROLES, :message => "%{value} is not a valid role" }

  validates :Name, :presence => true
  validates :Vorname, :presence => true
  validates :EMail, :presence => true, :format => { :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i }
  
  # SperrKZ enum
  AVAILABLE_STATES = [true, false]
  validates :SperrKZ, :inclusion => { :in => AVAILABLE_STATES, :message => "%{value} - #{self.inspect} is not a valid state (#{AVAILABLE_STATES.to_s})" }  

  # Associations
  has_one :Partner,
    :primary_key => :Mnr, 
    :foreign_key => :Pnr,
    # Nur mit derselben Version verknüpfen 
    :conditions => proc { ["GueltigBis = ?", self.GueltigBis] },
    :dependent => :destroy

  has_many :Foerdermitglied, 
    :primary_key => :Pnr,
    :foreign_key => :Pnr,
    # Nur mit derselben Version verknüpfen 
    :conditions => proc { ["GueltigBis = ?", self.GueltigBis] },
    :dependent => :destroy

  has_one :OZBPerson,
    :primary_key => :Mnr,
    :foreign_key => :Pnr,
    :dependent => :destroy

  has_many :Telefon, 
    :primary_key => :Pnr,
    :foreign_key => :Pnr,
    :dependent => :destroy

  has_one :Adresse,
    :primary_key => :Pnr,
    :foreign_key => :Pnr,
    :conditions => proc { ["GueltigBis = ?", self.GueltigBis] },
    :dependent => :destroy

  has_many :Teilnahme,
    :primary_key => :Pnr,
    :foreign_key => :Pnr,
    :dependent => :destroy

  has_many :Bankverbindung, 
    :primary_key => :Pnr,
    :foreign_key => :Pnr,
    # Nur mit derselben Version verknüpfen 
    :conditions => proc { ["GueltigBis = ?", self.GueltigBis] },
    :dependent => :destroy
  
  has_many :Buergschaft, 
    :primary_key => :Pnr_B,
    :foreign_key => :Pnr,
    # Nur mit derselben Version verknüpfen 
    :conditions => proc { ["GueltigBis = ?", self.GueltigBis] },
    :dependent => :destroy

  # Callbacks
  before_create :set_valid_time
  before_update :set_new_valid_time
  after_update :save_copy
  before_destroy :check_destroy_conditions
  after_destroy :destroy_associated_objects

  # Returns nil if at the given time no person object was valid
  def Person.get(pnr, date = Time.now)
    begin
      Person.find(:all, :conditions => ["Pnr = ? AND GueltigVon <= ? AND GueltigBis > ?", pnr, date, date]).first
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end
   
  # (static) Returns the latest/newest Person Object
  def self.latest(pnr)
    return Person.get(pnr)
  end

  # (non static) get latest instance of model
  def getLatest()
    return Person.get(self.Pnr)
  end
  
  # Returns all the latest/newest Person Objects
  def self.latest_all
    begin
      self.find(:all, :conditions => { :GueltigBis => "9999-12-31 23:59:59" }) # composite primary key gem
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end
  
  # Returns the full name of the current person
  def fullname
    self.Name + ", " + self.Vorname
  end

  # On Destroy Regeln
  # Eine Person, die keine: OZBPerson, Bürge, Fördermitglied oder Partner ist, darf gelöscht werden.
  # Es werden in diesem Falle alle assozierten Objekte gelöscht (Delete Cascade).
  def check_destroy_conditions
    # Check OZBPerson
    if (self.OZBPerson.any? and self.OZBPerson.check_destroy_conditions) or 
      # Check Buerge
      (self.Buergschaft.any?) or
      # Check Fördermitglied
      (self.Foerdermitglied.any?) or
      # Check Partner 
      (self.Partner.any?) then

      return false

    else
      return true
    end
  end

  # Destroy associated (historic) objects
  def destroy_associated_objects
    # Partner
    partner = Partner.find(:all, :conditions => ["Pnr = ?", self.Pnr])
    partner.each do |p|
      p.destroy()
    end

    # Foerdermitglied
    fmitglieder = Foerdermitglied.find(:all, :conditions => ["Pnr = ?", self.Pnr])
    fmitglieder.each do |f|
      f.destroy()
    end

    # Adresse
    adressen = Adresse.find(:all, :conditions => ["Pnr = ?", self.Pnr])
    adressen.each do |a|
      a.destroy()
    end

    # Bankverbindung
    bverbindungen = Bankverbindung.find(:all, :conditions => ["Pnr = ?", self.Pnr])
    bverbindungen.each do |b|
      b.destroy()
    end

    # Buergschaft
    buergschaften = Buergschaft.find(:all, :conditions => ["Pnr = ?", self.Pnr])
    buergschaften.each do |b|
      b.destroy()
    end
  end

end
