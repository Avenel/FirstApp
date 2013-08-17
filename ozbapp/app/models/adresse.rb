#!/bin/env ruby
# encoding: utf-8
require "HistoricRecord.rb"

class Adresse < ActiveRecord::Base
    include HistoricRecord

	self.table_name = "Adresse"
  self.primary_keys = :Pnr, :GueltigVon
  
  # Necessary for historization
  def get_primary_keys 
    return {"Pnr" => self.Pnr}
  end

  def set_primary_keys(values)
    self.Pnr = values["Pnr"]
  end
  
  # column names   
  attr_accessible :Pnr, :GueltigVon, :GueltigBis, :Strasse, :Nr, :PLZ, :Ort, :Vermerk, :SachPnr

  HUMANIZED_ATTRIBUTES = {
    :Pnr        => 'Personal-Nr.',
    :Nr         => 'Hausnummer',
    :PLZ        => 'PLZ',
    :Ort        => 'Ort',    
    :GueltigVon => 'Gültig von',
    :GueltigBis => 'Gültig bis',
    :Vermerk    => 'Vermerk'
  }

  def self.human_attribute_name(attr, options={})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  # Validations
  validates :Pnr, :presence => true, :format => { :with => /^([0-9]+)$/i }
  validates :Strasse, :presence => true  
  validates :Ort, :presence => true

  # Associations
  belongs_to :Person,
          :primary_key => :Pnr,
          :foreign_key => :Pnr,
          :conditions => proc { ["GueltigBis = ?", self.GueltigBis] }

  # callbacks
  before_create :set_valid_time
  before_update :set_new_valid_time
  after_update :save_copy

  # Returns nil if at the given time no person object was valid
  def Adresse.get(pnr, date = Time.now)
    begin
      return Adresse.find(:all, :conditions => ["Pnr = ? AND GueltigVon <= ? AND GueltigBis > ?", pnr, date, date]).first
    rescue ActiveRecord::RecordNotFound
      return nil
    end
  end

  # (non static) get latest instance of model
  def getLatest()
    return Adresse.get(self.Pnr)
  end

end
