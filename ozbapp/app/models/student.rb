#!/bin/env ruby
# encoding: utf-8
require "HistoricRecord.rb"

class Student < ActiveRecord::Base
	include HistoricRecord
	
  self.table_name = "Student"
  self.primary_keys = :Mnr, :GueltigVon

  # Necessary for historization
  def get_primary_keys 
    return {"Mnr" => self.Mnr}
  end

  def set_primary_keys(values)
    self.Mnr = values["Mnr"]
  end
  
  # attributes
  attr_accessible :Mnr, :GueltigVon, :GueltigBis, :AusbildBez, 
                  :InstitutName, :Studienort, :Studienbeginn,
                  :Studienende, :Abschluss, :SachPnr   

  # column names
  HUMANIZED_ATTRIBUTES = {
    :Mnr          => 'Mitglied-Nr.',
    :AusbildBez   => 'Ausbildungsbezeichnung',
    :InstitutName => 'Institutname',
    :SachPnr      => 'SachPnr'
  }

  def self.human_attribute_name(attr, options={})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end
    
  # Validations
  validates :Mnr, :presence => true, :format => { :with => /^([0-9]+)$/i }
  validates :AusbildBez, :presence => true
  validates :InstitutName, :presence => true
  validates :Studienort, :presence => true
  validates :Studienbeginn, :presence => true
  validates :Studienende, :presence => true
  validates :Abschluss, :presence => true
  
  # Associations
  belongs_to :OZBPerson, 
		:foreign_key => :Mnr

  # callbacks
  before_create :set_valid_time
  before_update :set_new_valid_time
  after_update :save_copy
  
  # Returns nil if at the given time no person object was valid
  def Student.get(mnr, date = Time.now)
    begin
      return Student.find(:all, :conditions => ["Mnr = ? AND GueltigVon <= ? AND GueltigBis > ?", mnr, date, date]).first
    rescue ActiveRecord::RecordNotFound
      return nil
    end
  end

  # (non static) get latest instance of model
  def getLatest()
    return Student.get(self.Mnr)
  end

end
