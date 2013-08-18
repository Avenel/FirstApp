#!/bin/env ruby
# encoding: utf-8
require "HistoricRecord.rb"

class Gesellschafter < ActiveRecord::Base 
    include HistoricRecord
  
	self.table_name = "Gesellschafter"
  self.primary_keys = :Mnr, :GueltigVon
  
  # Necessary for historization
  def get_primary_keys 
    return {"Mnr" => self.Mnr}
  end

  def set_primary_keys(values)
    self.Mnr = values["Mnr"]
  end

  # attributes	
  attr_accessible :Mnr, :GueltigVon, :GueltigBis, :FALfdNr, 
                  :FASteuerNr, :FAIdNr, :Wohnsitzfinanzamt, 
                  :NotarPnr, :BeurkDatum, :SachPnr

  # column names
  HUMANIZED_ATTRIBUTES = {
    :Mnr               => 'Mitglied-Nr.',
    :FALfdNr           => 'FA Lfd. Nr.',
    :FASteuerNr        => 'FA Steuernummer',
    :FAIdNr            => 'FA ID Nr',
    :Wohnsitzfinanzamt => 'Wohnsitzfinanzamt',
    :NotarPnr          => 'Notar Pnr',
    :BeurkDatum        => 'BeurkDatum',
    :SachPnr           => 'SachPnr',    
    :GueltigVon        => 'Gültig von',
    :GueltigBis        => 'Gültig bis',
  }
  
  def self.human_attribute_name(attr, options={})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end
  
  # Validations
  validates :Mnr, :presence => true, :format => { :with => /^([0-9]+)$/i }
  validates :FALfdNr, :presence => true
  validates :FASteuerNr, :presence => true
  validates :Wohnsitzfinanzamt, :presence => true

  # callbacks
  before_create :set_valid_time
  before_update :set_new_valid_time
  after_update :save_copy

  # Associations
  belongs_to :OZBPerson, 
          :foreign_key => :Mnr


  # Returns nil if at the given time no person object was valid
  def Gesellschafter.get(mnr, date = Time.now)
    begin
      return Gesellschafter.find(:all, :conditions => ["Mnr = ? AND GueltigVon <= ? AND GueltigBis > ?", mnr, date, date]).first
    rescue ActiveRecord::RecordNotFound
      return nil
    end
  end

  # (non static) get latest instance of model
  def getLatest()
    return Gesellschafter.get(self.Mnr)
  end

end
