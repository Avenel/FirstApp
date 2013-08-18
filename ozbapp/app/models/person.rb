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
  AVAILABLE_STATES = %W(0 1)
  validates :SperrKZ, :presence => true, :inclusion => { :in => AVAILABLE_STATES, :message => "%{value} is not a valid state (0, 1)" }  


  # Associations
  has_many :Partner, :foreign_key => :Mnr, :dependent => :destroy
  has_many :Foerdermitglied, :foreign_key => :Pnr, :dependent => :destroy
  has_one :OZBPerson, :foreign_key => :Pnr, :dependent => :destroy 
  has_many :Telefon, :foreign_key => :Pnr, :dependent => :destroy

  has_one :Adresse,
          :primary_key => :Pnr,
          :foreign_key => :Pnr,
          :conditions => proc { ["GueltigBis = ?", self.GueltigBis] }
    

  # Callbacks
  before_create :set_valid_time
  before_update :set_new_valid_time
  after_update :save_copy

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
    retur Person.get(self.pnr)
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
end
