#!/bin/env ruby
# encoding: utf-8
class Gesellschafter < ActiveRecord::Base
  
	self.table_name = "Gesellschafter"
  
  self.primary_keys = :Mnr, :GueltigVon
  
  alias_attribute :mnr, :Mnr
  alias_attribute :gueltigVon, :GueltigVon 
  alias_attribute :gueltigBis, :GueltigBis
  alias_attribute :faLfdNr, :FALfdNr  
  alias_attribute :faSteuerNr, :FASteuerNr  
  alias_attribute :faIdNr, :FAIdNr 
  alias_attribute :wohnsitzFinanzamt, :Wohnsitzfinanzamt  
  alias_attribute :notarPnr, :NotarPnr 
  alias_attribute :beurkDatum, :BeurkDatum  
  alias_attribute :sachPnr, :SachPnr
  	
  attr_accessible :Mnr, :GueltigVon, :GueltigBis, :FALfdNr, :FASteuerNr, :FAIdNr, :Wohnsitzfinanzamt, :NotarPnr, :BeurkDatum, :SachPnr

  # column names
  HUMANIZED_ATTRIBUTES = {
    :Mnr               => 'Mitglied-Nr.',
    :FALfdNr           => 'FA Lfd. Nr.',
    :FASteuerNr        => 'FA Steuernummer',
    :FAIdNr            => 'FA ID Nr',
    :Wohnsitzfinanzamt => 'Wohnsitzfinanzamt',
    :NotarPnr          => 'Notar Pnr',
    :BeurkDatum        => 'BeurkDatum',
    :SachPnr           => 'SachPnr',    
    :GueltigVon        => 'Gültig von',
    :GueltigBis        => 'Gültig bis',
  }
  
  def self.human_attribute_name(attr, options={})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end
    
  validates_presence_of :FALfdNr, :FASteuerNr, :Wohnsitzfinanzamt

  belongs_to :OZBPerson, :foreign_key => :Mnr
#  has_one :sachbearbeiter, :class_name => "Person", :foreign_key => :Pnr, :primary_key => :SachPNR, :order => "GueltigBis DESC"
#  has_one :notar, :class_name => "Person", :foreign_key => :Pnr, 
#  		:primary_key => :NotarPnr, :order => "GueltigBis DESC"

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
          @@copy            = Gesellschafter.get(self.Mnr)
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
  def Gesellschafter.get(pnr, date = Time.now)
    Gesellschafter.where(:Mnr => pnr).where(["GueltigVon <= ?", date]).where(["GueltigBis > ?",date]).first
  end
end
