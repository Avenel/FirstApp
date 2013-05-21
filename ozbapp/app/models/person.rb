#!/bin/env ruby
# encoding: utf-8
class Person < ActiveRecord::Base
   self.primary_keys = :Pnr, :GueltigVon

   alias_attribute :pnr, :Pnr
   alias_attribute :rolle, :Rolle
   alias_attribute :name, :Name
   alias_attribute :vorname, :Vorname
   alias_attribute :geburtsdatum, :Geburtsdatum
   alias_attribute :email, :Email
   alias_attribute :sperrKZ, :SperrKZ
   alias_attribute :sachPnr, :SachPnr

   attr_accessible :Pnr, :Rolle, :Name, :Vorname, :Geburtsdatum, :Email, :SperrKZ, :SachPnr, :GueltigVon, :GueltigBis

  # column names
  HUMANIZED_ATTRIBUTES = {
    :Pnr        => 'Personal-Nr.',
    :SperrKZ    => 'SperrKZ',
    :GueltigVon => 'Gueltig von',
    :GueltigBis => 'Gueltig bis'
  }
   
   has_many :Partner, :foreign_key => :Mnr, :dependent => :destroy
   has_many :Foerdermitglied, :foreign_key => :Pnr, :dependent => :destroy
   # has_one :OZBPerson, :foreign_key => :Mnr, :dependent => :destroy
   has_many :OZBPerson, :foreign_key => :UeberPnr, :dependent => :destroy # Done, getestet
   #has_many :Partner, :foreign_key => :MnrO, :dependent => :destroy #:delete_all         # Done, getestet
   #has_one :Foerdermitglied, :foreign_key => :Pnr, :dependent => :destroy
   has_many :Adresse, :foreign_key => :Pnr, :dependent => :destroy
   #has_one :Adresse, :foreign_key => :Pnr, :order => "GueltigBis DESC", :conditions => 
   #   proc { "GueltigVon >= '#{self.GueltigVon.to_formatted_s(:db)}' AND " +
   #          "GueltigBis <= '#{self.GueltigBis.to_formatted_s(:db)}' " }, :dependent => :destroy
   has_many :Telefon, :foreign_key => :Pnr, :dependent => :destroy         # Done, getestet

#   has_one :sachbearbeiter, :class_name => "Person", :foreign_key => :Pnr, :primary_key => :SachPNR, :order => "GueltigBis DESC"





  validates :Name, :presence => true
  validates :Vorname, :presence => true
  validates :Email, :presence => true
  validates :Rolle, :presence => true, :inclusion => { :in => %w(G M P S F), :message => "%{value} is not a valid role" }
  
  def self.all_actual
    Person.find(:all, :conditions => { :GueltigBis => "9999-12-31 23:59:59" })
  end
  
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
      Person.where(:Pnr => pnr).where(["GueltigVon <= ?", date]).where(["GueltigBis > ?",date]).first
   end
   
  # Returns the latest/newest OZBKonto Object
  def self.latest(pnr)
    begin
      self.find(pnr, "9999-12-31 23:59:59") # composite primary key gem
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end
  
  # Returns all the latest/newest OZBKonto Objects
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

class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      record.errors[attribute] << (options[:message] || "is not an email")
    end
  end
end
