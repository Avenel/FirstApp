#!/bin/env ruby
# encoding: utf-8
class Adresse < ActiveRecord::Base
	self.table_name = "Adresse"
  self.primary_keys = :Pnr, :GueltigVon
  
#  alias_attribute :pnr, :Pnr
   
  attr_accessible :Pnr, :GueltigVon, :GueltigBis, :Strasse, :Nr, :PLZ, :Ort, :Vermerk, :SachPnr

  # column names
  HUMANIZED_ATTRIBUTES = {
    :Pnr        => 'Personal-Nr.',
    :Nr         => 'Hausnummer',
    :PLZ        => 'PLZ',
    :Ort        => 'Ort',    
    :GueltigVon => 'Gültig von',
    :GueltigBis => 'Gültig bis',
    :Vermerk    => 'Vermerk'
  }

  # Validations
  validates :Pnr, :presence => true, :format => { :with => /^([0-9]+)$/i }
  validates :Strasse, :presence => true  
  validates :Ort, :presence => true

  def self.human_attribute_name(attr, options={})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end


  belongs_to :Person, :foreign_key => :Pnr

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
          @@copy = Adresse.get(self.Pnr)
          @@copy = @@copy.dup
          @@copy.Pnr = self.Pnr
          @@copy.GueltigVon = self.GueltigVon
          @@copy.GueltigBis = Time.now      

          self.GueltigVon = Time.now      
          self.GueltigBis = Time.zone.parse("9999-12-31 23:59:59")      
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
  def Adresse.get(pnr, date = Time.now)
    Adresse.where(:Pnr => pnr).where(["GueltigVon <= ?", date]).where(["GueltigBis > ?",date]).first
  end
end
