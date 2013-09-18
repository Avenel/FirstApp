#!/bin/env ruby
# encoding: utf-8
class Telefon < ActiveRecord::Base
  
  self.table_name = "Telefon"
  self.primary_keys = :Pnr, :LfdNr
  
  # attributes
  attr_accessible :Pnr, :LfdNr, :TelefonNr, :TelefonTyp

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

  # Validations
  validates :Pnr, :presence => true, :format => { :with => /^([0-9]+)$/i }
  validates :LfdNr, :presence => true
  validates :TelefonNr, :presence => true

  # enum TelefonTyp
  AVAILABLE_TYPES = %W(tel mob fax gesch) # tel = Festnetz, mob = Mobilfunk, fax = FAX, gesch = Geschaeft
  validates :TelefonTyp, :presence => true, :inclusion => { :in => AVAILABLE_TYPES, :message => "%{value} is not a valid telephone type (tel, mob, fax" } 

  # Associations 
  belongs_to :Person, 
    :primary_key => :Pnr,
    :foreign_key => :Pnr,
    # Nur mit der aktuellsten Version der Person verknüpfen 
    :conditions => proc { ["GueltigBis = ?", "9999-12-31 23:59:59"] }

end
