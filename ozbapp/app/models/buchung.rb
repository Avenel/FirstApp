#!/bin/env ruby
# encoding: utf-8
class Buchung < ActiveRecord::Base
  self.table_name = "Buchung"
  self.primary_keys = :BuchJahr, :KtoNr, :BnKreis, :BelegNr, :Typ
  
  # attributes
  attr_accessible :BuchJahr, :KtoNr, :BnKreis, :BelegNr, :Typ, :Belegdatum, 
                  :BuchDatum, :Buchungstext, :Sollbetrag, :Habenbetrag, :SollKtoNr, 
                  :HabenKtoNr, :WSaldoAcc, :Punkte, :PSaldoAcc

  # associations
  belongs_to :OZBKonto, :foreign_key => :KtoNr
  
  # validations
  # ...
  
  # column names
  HUMANIZED_ATTRIBUTES = {
    :BuchJahr       => 'Jahr',
    :KtoNr          => 'Konto-Nr.',
    :BnKreis        => 'Buchungskreis',
    :Typ            => 'Typ',
    :Belegdatum     => 'Belegdatum',
    :BuchDatum      => 'Buchungsdatum',
    :BuchungsText   => 'Verwendungszweck',
    :SollBetrag     => 'Betrag (Soll)',
    :HabenBetrag    => 'Betrag (Haben)',
    :SollKtoNr      => 'sollKtoNr',
    :HabenKtoNr     => 'habenKtoNr',
    :WSaldoAcc      => 'wSaldoAcc',
    :Punkte         => 'Punkte',
    :PSaldoAcc      => 'pSaldoAcc'
  }

  def self.human_attribute_name(attr, options={})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end
end
