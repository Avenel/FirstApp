#!/bin/env ruby
# encoding: utf-8
class Projektgruppe < ActiveRecord::Base

	# table config
  	self.table_name = "ProjektGruppe"
  	self.primary_key = :Pgnr
  
  	# aliases
  	alias_attribute :pgNr, :Pgnr
    alias_attribute :projGruppenBez, :ProjGruppenBez

  	# attributes
  	attr_accessible :pgNr, :Pgnr, :ProjGruppenBez
  
  	# associations
  	has_many :ZEKonto, :inverse_of => :Projektgruppe, :foreign_key => :pgNr # Done, getestet

  	# validations
  	validates :pgNr, :presence => true 

    validate :valid_pgNr

    def valid_pgNr 
      # every projektgruppennummer is > 0
      # if a string is passed to pgNr, it equals 0 => false
      if self.pgNr == 0 then
        errors.add :Pgnr, "projektgruppennummer ist nicht valide."
        return false
      else 
        # already exists?
        pg = Projektgruppe.where("Pgnr = ?", self.pgNr).first

        if pg.nil? then
          return true
        else
          errors.add :Pgnr, "projektgruppennummer bereits vergeben."
          return false
        end
      end

    end

end
