#!/bin/env ruby
# encoding: utf-8
class KklVerlauf < ActiveRecord::Base
  self.table_name = "kklverlauf"
  self.primary_keys = :KtoNr#, :KKLAbDatum
  
  # aliases
  alias_attribute :kkl, :KKL
  
  # attributes
  attr_accessible :KtoNr, :KKLAbDatum, :KKL
  
  # associations
  belongs_to :ozb_konto,
    :foreign_key => :KtoNr,
    :class_name => "OzbKonto"
    
  belongs_to :kontenklasse,
    :foreign_key => :KKL
  
  # validations
  validates :KtoNr, :presence => { :format => { :with => /[0-9]+/ }, :message => "Bitte geben Sie eine gültige Kontonummer an." }
  validates :KKL, :presence => { :format => { :with => /[0-9]+/ }, :message => "Bitte geben Sie eine gültige Kontenklasse an." }
  
  before_create :set_ab_datum
  after_destroy :destroy_historic_records
  
  # column names
  HUMANIZED_ATTRIBUTES = {
    :KtoNr      => 'Konto-Nr.',
    :KKLAbDatum => 'Ab Datum',
    :KKL        => 'Kontenklasse'
  }

  def self.human_attribute_name(attr, options={})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end
  
  def set_ab_datum
    if (self.KKLAbDatum.blank?)
      self.KKLAbDatum = Date.today
    end
  end
  
  private
    # bound to callback
    def destroy_historic_records
      # find all historic records that belongs to this record and destroy(!) them
      # note: destroy should always destroy all the corresponding association objects
      # if the association option :dependent => :destroy is set correctly
      recs = self.class.find(:all, :conditions => ["KtoNr = ? AND KKLAbDatum < ?", self.KtoNr, self.KKLAbDatum])
      
      recs.each do |r|
        r.destroy
      end
    end
end
