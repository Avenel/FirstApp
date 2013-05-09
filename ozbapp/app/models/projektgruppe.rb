#!/bin/env ruby
# encoding: utf-8
class Projektgruppe < ActiveRecord::Base

  set_table_name "ProjektGruppe"

  set_primary_key :Pgnr
  
  attr_accessible :Pgnr, :ProjGruppenBez
  
  has_many :ZEKonto, :inverse_of => :Projektgruppe, :foreign_key => :Pgnr # Done, getestet

end
