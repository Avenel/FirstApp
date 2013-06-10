#!/bin/env ruby
# encoding: utf-8
class Projektgruppe < ActiveRecord::Base

	# table config
  	self.table_name = "ProjektGruppe"
  	self.primary_key = :Pgnr
  
  	# aliases
  	alias_attribute :pgNr, :Pgnr

  	# attributes
  	attr_accessible :pgNr, :Pgnr, :ProjGruppenBez
  
  	# associations
  	has_many :ZEKonto, :inverse_of => :Projektgruppe, :foreign_key => :pgNr # Done, getestet

  	# validations
  	validates :pgNr, :presence => { :format => { :with => /^([0-9]+)$/i }, :message => "Bitte geben Sie eine gültige Projektgruppennummer an." }

end
