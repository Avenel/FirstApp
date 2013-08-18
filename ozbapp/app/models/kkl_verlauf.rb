#!/bin/env ruby
# encoding: utf-8
class KklVerlauf < ActiveRecord::Base

  self.table_name = "KKLVerlauf"
  self.primary_keys = :KtoNr, :KKLAbDatum
  
  # attributes
  attr_accessible :KtoNr, :KKLAbDatum, :KKL
  
  # column names
  HUMANIZED_ATTRIBUTES = {
    :KtoNr      => 'Konto-Nr.',
    :KKLAbDatum => 'Ab Datum',
    :KKL        => 'Kontenklasse'
  }

  def self.human_attribute_name(attr, options={})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end
  
  # Validations
  validates :KtoNr, 
    :presence => { :format => { :with => /^[0-9]{5}$/i  },
      :message => "Bitte geben Sie eine Kontonummer an." }, 
    :length => { :is => 5, :message => "Die Kontonummer darf nur 5-stellig sein." }, 
    :numericality => { :only_integer => true, 
      :message => "Die Kontonummer darf nur Zahlen beinhalten." }
  validates :KKLAbDatum, :presence => true
  validates :KKL, :presence => { :format => { :with => /^[A-Z]{1}$/i }, :message => "Bitte geben Sie eine gültige Kontenklasse an." }
  
  validate :kto_exists

  def kto_exists
    kto = OzbKonto.latest(self.KtoNr)
    if kto.nil? then
      errors.add :KtoNr, "existiert nicht: #{self.KtoNr}."
      return false
    else
      return true
    end
  end
  
  # Associations
  belongs_to :OzbKonto,
          :foreign_key => :KtoNr
    
  belongs_to :kontenklasse,
          :foreign_key => :KKL

  # callbacks
  before_create :set_ab_datum

  def set_ab_datum
    if (self.KKLAbDatum.blank?)
      self.KKLAbDatum = Date.today
    end
  end

end
