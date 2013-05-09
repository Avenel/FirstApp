#!/bin/env ruby
# encoding: utf-8
class Foerdermitglied < ActiveRecord::Base

  set_table_name "Foerdermitglied"
  set_primary_keys :Pnr, :GueltigVon

	alias_attribute :pnr, :Pnr
	alias_attribute :gueltigVon, :GueltigVon 
	alias_attribute :gueltigBis, :GueltigBis
	alias_attribute :region, :Region 
	alias_attribute :foerderbeitrag, :Foerderbeitrag
	alias_attribute :sachPnr, :SachPnr
  
  attr_accessible :Pnr, :GueltigVon, :GueltigBis, :Region, :Foerderbeitrag, :SachPnr

  # column names
  HUMANIZED_ATTRIBUTES = {
    :Pnr            => 'Personal-Nr.',
    :Region         => 'Region',
    :Foerderbeitrag => 'Förderbeitrag',
    :SachPnr        => 'SachPnr',    
    :GueltigVon     => 'Gültig von',
    :GueltigBis     => 'Gültig bis'
  }

  def self.human_attribute_name(attr, options={})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end
  	   
  validates_presence_of :Region, :Foerderbeitrag 

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
		if(self.Pnr)
			if(self.GueltigBis > "9999-01-01 00:00:00")
				@@copy            = Foerdermitglied.get(self.Pnr)
				@@copy            = @@copy.dup
				@@copy.Pnr        = self.Pnr
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
	def Foerdermitglied.get(pnr, date = Time.now)
		Foerdermitglied.where(:Pnr => pnr).where(["GueltigVon <= ?", date]).where(["GueltigBis > ?",date]).first
	end
end
