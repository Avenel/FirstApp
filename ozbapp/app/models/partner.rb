#!/bin/env ruby
# encoding: utf-8
require "HistoricRecord.rb"

class Partner < ActiveRecord::Base
	include HistoricRecord
	
  self.table_name = "Partner"
  self.primary_keys = :Mnr, :GueltigVon
  
  # Necessary for historization
  def get_primary_keys 
    return {"Mnr" => self.Mnr}
  end

  def set_primary_keys(values)
    self.Mnr = values["Mnr"]
  end

  # attributes
  attr_accessible :Mnr, :GueltigVon, :GueltigBis, :Pnr_P, 
                  :Berechtigung, :SachPnr

  # column names
  HUMANIZED_ATTRIBUTES = {
    :Mnr        => 'Mitglied-Nr.',
    :Pnr_P       => 'Partner (Mnr)',
    :SachPnr    => 'SachPnr',
    :GueltigVon => 'Gültig von',
    :GueltigBis => 'Gültig bis'
  }

  def self.human_attribute_name(attr, options={})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  # Validations
  validates :Mnr, :presence => true, :format => { :with => /^([0-9]+)$/i }
  validates :Pnr_P, :presence => true, :format => { :with => /^([0-9]+)$/i }

  # enum Berechtigung
  AVAILABLE_PERMISSIONS = %W(l v) # l = leseberechtigt, v = vollberechtigt 
  validates :Berechtigung, :presence => true, :inclusion => { :in => AVAILABLE_PERMISSIONS, :message => "%{value} is not a valid permission (l, v)" }

  # Associations
  belongs_to :OZBPerson, 
		:foreign_key => :Mnr

  # Pnr vom Partner (eigentliche Mitglied)
  belongs_to :Person, 
    :primary_key => :Pnr,
		:foreign_key => :Pnr_P,
		:conditions => proc { ["GueltigBis = ?", self.GueltigBis] }

  # callbacks
  before_create :set_valid_time
  before_update :set_new_valid_time
  after_update :save_copy

  # Returns nil if at the given time no person object was valid
  def Partner.get(mnr, date = Time.now)
    begin
      return Partner.find(:all, :conditions => ["Mnr = ? AND GueltigVon <= ? AND GueltigBis > ?", Mnr, date, date]).first
    rescue ActiveRecord::RecordNotFound
      return nil
    end
  end

  # Returns nil if at the given time no person object was valid
  def Partner.get_all(pnr, date = Time.now)
    begin
      return Partner.find(:all, :conditions => ["Pnr_P = ? AND GueltigVon <= ? AND GueltigBis > ?", pnr, date, date])
    rescue ActiveRecord::RecordNotFound
      return nil
    end
  end
  
  # (non static) get latest instance of model
  def getLatest()
    return Partner.get(self.Mnr)
  end
end
