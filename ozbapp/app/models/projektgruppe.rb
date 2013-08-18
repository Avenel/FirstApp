#!/bin/env ruby
# encoding: utf-8
class Projektgruppe < ActiveRecord::Base
	
	self.table_name = "ProjektGruppe"
	self.primary_key = :Pgnr

	# attributes
	attr_accessible :Pgnr, :ProjGruppenBez

	# Validations
	validates :PgNr, :uniqueness => true, :presence => true, :format => {:with => /^[0-9]{1,2}$/i, :message => "Not a valid PGNnr"}
  validates :ProjGruppenBez, :presence => true

  # Associations
  has_many :ZEKonto, :inverse_of => :Projektgruppe, :foreign_key => :PgNr
end
