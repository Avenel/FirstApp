#!/bin/env ruby
# encoding: utf-8
class Adresse < ActiveRecord::Base
	self.table_name = "Adresse"
  self.primary_keys = :Pnr
     
  attr_accessible :Pnr, :GueltigVon, :GueltigBis, :Strasse, :Nr, :PLZ, :Ort, :Vermerk, :SachPnr

  # Historisation
  has_paper_trail

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

  # Returns nil if at the given time no person object was valid
  def Adresse.get(pnr, date = Time.now)
    # Test - bestanden! :)
    #date = Time.zone.parse("2013-08-10 23:21:25")

    if Adresse.where(:Pnr => pnr).first.versions.where('GueltigBis > ?', date).empty? then
      return Adresse.where(:Pnr => pnr).first  
    else 
      Adresse.where(:Pnr => pnr).first.versions.where('GueltigBis <= ?', date).last.reify
    end
  end

end
