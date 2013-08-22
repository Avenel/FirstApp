#!/bin/env ruby
# encoding: utf-8
class Projektgruppe < ActiveRecord::Base
	
	self.table_name = "ProjektGruppe"
	self.primary_key = :Pgnr

	# attributes
	attr_accessible :Pgnr, :ProjGruppenBez

	# Validations
	validates :Pgnr, :uniqueness => true, :presence => true, :format => {:with => /^[0-9]{1,2}$/i, :message => "Not a valid PGNnr"}
  validates :ProjGruppenBez, :presence => true

  # Associations
  has_many :ZeKonto, 
    :primary_key => :Pgnr,
    :foreign_key => :Pgnr,
    # Nur mit der aktuellsten Version verknüpfen 
    :conditions => proc { ["GueltigBis = ?", "9999-12-31 23:59:59"] },
    :dependent => :restrict_with_error
    
end
