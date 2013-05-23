#!/bin/env ruby
# encoding: utf-8
class Student < ActiveRecord::Base
  
  self.table_name = "Student"
  self.primary_keys = :Mnr, :GueltigVon

  alias_attribute :mnr, :Mnr
  alias_attribute :ausbildBez, :AusbildBez 
  alias_attribute :institutName, :InstitutName 
  alias_attribute :studienort, :Studienort 
  alias_attribute :studienbeginn, :Studienbeginn 
  alias_attribute :studienende, :Studienende 
  alias_attribute :abschluss, :Abschluss 
  alias_attribute :sachPnr, :SachPnr
  
  attr_accessible :Mnr, :AusbildBez, :InstitutName, :Studienort, :Studienbeginn, :Studienende, :Abschluss, :SachPnr, :GueltigVon   

  # column names
  HUMANIZED_ATTRIBUTES = {
    :Mnr          => 'Mitglied-Nr.',
    :AusbildBez   => 'Ausbildungsbezeichnung',
    :InstitutName => 'Institutname',
    :SachPnr      => 'SachPnr'
  }

  def self.human_attribute_name(attr, options={})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end
    
  validates_presence_of :AusbildBez, :InstitutName, :Studienort, :Studienbeginn, :Abschluss
  
  belongs_to :OZBPerson, :foreign_key => :Mnr

#  has_one :sachbearbeiter, :class_name => "Person", :foreign_key => :Pnr, :primary_key => :SachPNR, :order => "GueltigBis DESC"

  @@copy = nil

  before_save do 
    unless(self.GueltigBis || self.GueltigVon)
        self.GueltigVon = Time.now      
        self.GueltigBis = Time.zone.parse("9999-12-31 23:59:59")      
    end
  end

  before_update do      
    if(self.Mnr)
      if(self.GueltigBis > "9999-01-01 00:00:00")
          @@copy            = Student.get(self.Mnr)
          @@copy            = @@copy.dup
          @@copy.Mnr        = self.Mnr
          @@copy.GueltigVon = self.GueltigVon
          @@copy.GueltigBis = Time.now      
          
          self.GueltigVon   = Time.now      
          self.GueltigBis   = Time.zone.parse("9999-12-31 23:59:59")      
      end
    end
  end

   after_update do
      if !@@copy.nil?
        @@copy.save(:validation => false)
        @@copy = nil
      end
   end


  # Returns nil if at the given time no person object was valid
  def Student.get(pnr, date = Time.now)
    Student.where(:Mnr => pnr).where(["GueltigVon <= ?", date]).where(["GueltigBis > ?",date]).first
  end

end
