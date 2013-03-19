#!/bin/env ruby
# encoding: utf-8
class Partner < ActiveRecord::Base

  set_table_name "partner"

  set_primary_keys :Mnr, :GueltigVon
  
  alias_attribute :mnr, :Mnr
  alias_attribute :gueltigVon, :GueltigVon 
  alias_attribute :gueltigBis, :GueltigBis
  alias_attribute :mnro, :MnrO
  alias_attribute :berechtigung, :Berechtigung 
  alias_attribute :sachPnr, :SachPnr

  attr_accessible :Mnr, :GueltigVon, :GueltigBis, :MnrO, :Berechtigung, :SachPnr

  # column names
  HUMANIZED_ATTRIBUTES = {
    :Mnr        => 'Mitglied-Nr.',
    :MnrO       => 'Partner (Mnr)',
    :SachPnr    => 'SachPnr',
    :GueltigVon => 'Gültig von',
    :GueltigBis => 'Gültig bis'
  }

  def self.human_attribute_name(attr, options={})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end
    
  validates_presence_of :MnrO, :Berechtigung

  belongs_to :Person, :foreign_key => :Pnr


#	has_one :sachbearbeiter, :class_name => "Person", :foreign_key => :Pnr, :primary_key => :SachPNR, :order => "GueltigBis DESC"

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
  def Partner.get_all(mnrO, date = Time.now)
	  Partner.where(:MnrO => mnrO).where(["GueltigVon <= ?", date]).where(["GueltigBis > ?",date])
  end
end
