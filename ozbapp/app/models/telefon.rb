#!/bin/env ruby
# encoding: utf-8
class Telefon < ActiveRecord::Base

  self.table_name = "Telefon"

  self.primary_keys = :Pnr, :LfdNr
  attr_accessible :Pnr, :LfdNr, :TelefonNr, :TelefonTyp, :SachPnr

  # column names
  HUMANIZED_ATTRIBUTES = {
    :Pnr        => 'Personal-Nr.',
    :LfdNr      => 'Laufende Nummer',
    :TelefonNr  => 'Telefonnummer',
    :TelefonTyp => 'Telefontyp'
  }
  
  def self.human_attribute_name(attr, options={})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end  

  #validates_presence_of :TelefonNr
   
  belongs_to :Person, :foreign_key => :Pnr
end
