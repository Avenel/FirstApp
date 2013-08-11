#!/bin/env ruby
# encoding: utf-8
class Person < ActiveRecord::Base
  self.primary_keys = :Pnr, :GueltigVon

  alias_attribute :pnr, :Pnr
  alias_attribute :rolle, :Rolle
  alias_attribute :name, :Name
  alias_attribute :vorname, :Vorname
  alias_attribute :geburtsdatum, :Geburtsdatum
  alias_attribute :sperrKZ, :SperrKZ
  alias_attribute :sachPnr, :SachPnr
  alias_attribute :email, :EMail
  alias_attribute :Email, :EMail

  attr_accessible :Pnr, :GueltigVon, :GueltigBis, :Rolle, :Name, 
                  :Vorname, :Geburtsdatum, :email, :SperrKZ, 
                  :SachPnr, :AVAILABLE_ROLES

  # TEMP enable paper trail for testing purposes
  has_paper_trail

  # column names
  HUMANIZED_ATTRIBUTES = {
    :Pnr        => 'Personal-Nr.',
    :SperrKZ    => 'SperrKZ',
    :GueltigVon => 'Gueltig von',
    :GueltigBis => 'Gueltig bis'
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
  has_many :OZBPerson, :foreign_key => :UeberPnr, :dependent => :destroy 
  has_one :Adresse, :foreign_key => :Pnr, :dependent => :destroy
  has_many :Telefon, :foreign_key => :Pnr, :dependent => :destroy

  before_save do 
    unless(self.GueltigBis || self.GueltigVon)
      self.GueltigVon = Time.now      
      self.GueltigBis = Time.zone.parse("9999-12-31 23:59:59")      
    end
  end

  #NU
  @@copy = nil

  before_update do     
    if(self.Pnr)
       if(self.GueltigBis > "9999-01-01 00:00:00")
          @@copy            = Person.get(self.Pnr)
          @@copy            = @@copy.dup
          @@copy.Pnr        = self.Pnr
          @@copy.GueltigVon = self.GueltigVon
          @@copy.GueltigBis = Time.now      

          self.GueltigVon   = Time.now      
          self.GueltigBis   = Time.zone.parse("9999-12-31 23:59:59")      
       end
    end
  end

  #NU
  after_update do
    if !@@copy.nil?
      @@copy.save(:validation => false)
      @@copy = nil
    end
  end


  # Returns nil if at the given time no person object was valid
  def Person.get(pnr, date = Time.now)
    #Person.where(:Pnr => pnr).where(["GueltigVon <= ?", date]).where(["GueltigBis > ?",date]).first
    date = Time.zone.parse("2013-08-11 00:09:25")

    if Person.where(:Pnr => pnr).first.versions.where('GueltigBis > ?', date).empty? then
      return Person.where(:Pnr => pnr).first  
    else 
      Person.where(:Pnr => pnr).first.versions.where('GueltigBis <= ?', date).last.reify
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
