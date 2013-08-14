#!/bin/env ruby
# encoding: utf-8
class Person < ActiveRecord::Base
  self.primary_keys = :Pnr

  alias_attribute :pnr, :Pnr
  alias_attribute :rolle, :Rolle
  alias_attribute :name, :Name
  alias_attribute :vorname, :Vorname
  alias_attribute :geburtsdatum, :Geburtsdatum
  alias_attribute :sperrKZ, :SperrKZ
  alias_attribute :sachPnr, :SachPnr
  alias_attribute :email, :EMail
  alias_attribute :Email, :EMail

  attr_accessible :Pnr, :Rolle, :Name, 
                  :Vorname, :Geburtsdatum, :email, :SperrKZ, 
                  :SachPnr, :AVAILABLE_ROLES

  # TEMP enable paper trail for testing purposes
  has_paper_trail

  # column names
  HUMANIZED_ATTRIBUTES = {
    :Pnr        => 'Personal-Nr.',
    :SperrKZ    => 'SperrKZ'
  }
   

  # Validations
  validates :Pnr, :presence => true, :format => { :with => /^([0-9]+)$/i }
  
  # Role enum
  AVAILABLE_ROLES = %W(G M P S F)
  validates :Rolle, :presence => true, :inclusion => { :in => AVAILABLE_ROLES, :message => "%{value} is not a valid role" }

  validates :Name, :presence => true
  validates :Vorname, :presence => true
  validates :email, :presence => true, :format => { :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i }
  
  # SperrKZ enum
  AVAILABLE_STATES = %W(0 1)
  validates :SperrKZ, :presence => true, :inclusion => { :in => AVAILABLE_STATES, :message => "%{value} is not a valid state (0, 1)" }  


  # Relations
  has_many :Partner, :foreign_key => :Mnr, :dependent => :destroy
  has_many :Foerdermitglied, :foreign_key => :Pnr, :dependent => :destroy
  has_one :OZBPerson, :foreign_key => :Pnr, :dependent => :destroy 
  has_one :Adresse, :foreign_key => :Pnr, :dependent => :destroy
  has_many :Telefon, :foreign_key => :Pnr, :dependent => :destroy

  # Returns nil if at the given time no person object was valid
  def Person.get(pnr, date = Time.now)
    if Person.where(:Pnr => pnr).first.versions.where('GueltigBis > ?', date).empty? then
      return Person.where(:Pnr => pnr).first  
    else 
      Person.where(:Pnr => pnr).first.versions.where('GueltigBis >= ?', date).order("GueltigBis ASC").last
    end
  end
   
  # Returns the latest/newest Person Object
  def self.latest(pnr)
    begin
      Person.where("Pnr = ? AND GueltigBis = ?", pnr, "9999-12-31 23:59:59").first # composite primary key gem
    rescue ActiveRecord::RecordNotFound
      nil
    end
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
