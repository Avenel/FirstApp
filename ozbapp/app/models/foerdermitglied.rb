#!/bin/env ruby
# encoding: utf-8
require "HistoricRecord.rb"

class Foerdermitglied < ActiveRecord::Base
    include HistoricRecord

	self.table_name = "Foerdermitglied"
 	self.primary_keys = :Pnr, :GueltigVon

  # Necessary for historization
  def get_primary_keys 
    return {"Pnr" => self.Pnr}
  end

  def set_primary_keys(values)
    self.Pnr = values["Pnr"]
  end

  # attributes
  attr_accessible :Pnr, :GueltigVon, :GueltigBis, :Region, 
  								:Foerderbeitrag, :MJ, :SachPnr

  # column names
  HUMANIZED_ATTRIBUTES = {
    :Pnr            => 'Personal-Nr.',
    :Region         => 'Region',
    :Foerderbeitrag => 'Förderbeitrag',
    :SachPnr        => 'SachPnr',    
    :GueltigVon     => 'Gültig von',
    :GueltigBis     => 'Gültig bis'
  }

  def self.human_attribute_name(attr, options={})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end
  
  # Validations
  validates :Pnr, :presence => true, :format => { :with => /^([0-9]+)$/i }
  validates :Region, :presence => true
  validates :Foerderbeitrag, :presence => true

  # Enum MJ
  AVAILABLE_PERIODS = %W(m j) # m = monatlich, j = jaehrlich
  validates :MJ, :presence => true, :inclusion => { :in => AVAILABLE_PERIODS, :message => "%{value} is not a valid period (m, j)" }  

  # callbacks
  before_create :set_valid_time
  before_update :set_new_valid_time
  after_update :save_copy

  # Associations
  belongs_to :Person, :foreign_key => :Pnr

	# Returns nil if at the given time no person object was valid
	def Foerdermitglied.get(pnr, date = Time.now)
    begin
      return Foerdermitglied.find(:all, :conditions => ["Pnr = ? AND GueltigVon <= ? AND GueltigBis > ?", pnr, date, date]).first
    rescue ActiveRecord::RecordNotFound
      return nil
    end
  end

  # (non static) get latest instance of model
  def getLatest()
    return Foerdermitglied.get(self.Pnr)
  end

end
