#!/bin/env ruby
# encoding: utf-8
class Partner < ActiveRecord::Base
  self.table_name = "Partner"
  self.primary_keys = :Mnr, :GueltigVon
  
  alias_attribute :mnr, :Mnr
  alias_attribute :gueltigVon, :GueltigVon 
  alias_attribute :gueltigBis, :GueltigBis
  alias_attribute :pnrp, :Pnr_P
  alias_attribute :berechtigung, :Berechtigung 
  alias_attribute :sachPnr, :SachPnr

  attr_accessible :Mnr, :GueltigVon, :GueltigBis, :Pnr_P, 
                  :Berechtigung, :SachPnr

  # column names
  HUMANIZED_ATTRIBUTES = {
    :Mnr        => 'Mitglied-Nr.',
    :Pnr_P       => 'Partner (Mnr)',
    :SachPnr    => 'SachPnr',
    :GueltigVon => 'Gültig von',
    :GueltigBis => 'Gültig bis'
  }

  def self.human_attribute_name(attr, options={})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  # Validations
  validates :Mnr, :presence => true, :format => { :with => /^([0-9]+)$/i }
  validates :Pnr_P, :presence => true, :format => { :with => /^([0-9]+)$/i }

  # enum Berechtigung
  AVAILABLE_PERMISSIONS = %W(l v) # l = leseberechtigt, v = vollberechtigt 
  validates :Berechtigung, :presence => true, :inclusion => { :in => AVAILABLE_PERMISSIONS, :message => "%{value} is not a valid permission (l, v)" }

  # Relations
  belongs_to :OZBPerson, :foreign_key => :Mnr
  # Pnr vom Partner (eigentliche Mitglied)
  belongs_to :Person, :foreign_key => :Pnr_P

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
        @@copy = Partner.get(self.Mnr)
        @@copy = @@copy.dup
        @@copy.Mnr = self.Mnr
        @@copy.GueltigVon = self.GueltigVon
        @@copy.GueltigBis = Time.now      

        self.GueltigVon = Time.now      
        self.GueltigBis = Time.zone.parse("9999-12-31 23:59:59")      
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
  def Partner.get(mnr, date = Time.now)
    Partner.where(:Mnr => mnr).where(["GueltigVon <= ?", date]).where(["GueltigBis > ?",date]).first
  end

  # Returns nil if at the given time no person object was valid
  def Partner.get_all(pnr, date = Time.now)
	  Partner.where(:Pnr_P => pnr).where(["GueltigVon <= ?", date]).where(["GueltigBis > ?",date])
  end
end
