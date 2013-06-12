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
  belongs_to :OZBKonto, 
    :foreign_key => :KtoNr, 
    :class_name => "OzbKonto"
  
  # validations
  validates :BuchJahr, 
    :presence => {:message => "Bitte geben Sie ein {HUMANIZED_ATTRIBUTES[:BuchJahr]} an."},
    :length => { :is => 4, 
      :message => "Das {HUMANIZED_ATTRIBUTES[:BuchJahr]} muss 4-stellig sein."},
    :numericality => { :only_integer => true, 
      :message => "Das Jahr darf nur aus Ziffern bestehen." }

  validates :KtoNr, 
    :presence => { :format => { :with => /^[0-9]{5}$/i  },
      :message => "Bitte geben Sie eine Konto-Nr. an." }, 
    :length => { :is => 5, :message => "Die Konto-Nr. darf nur 5-stellig sein." }, 
    :numericality => { :only_integer => true, 
      :message => "Die Konto-Nr. darf nur Zahlen beinhalten." }

  #Nicht spezifiziert (außer DB-Einschraenkung)
  validates :BnKreis, 
    :presence => {:message => "Bitte geben Sie einen Belegnummernkreis an." }

  #Nicht spezifiziert (außer DB-Einschraenkung)
  validates :BelegNr, 
    :presence => {:message => "Bitte geben Sie eine Belegnummer an." }

  #Nicht spezifiziert (außer DB-Einschraenkung)
  validates :Typ, 
    :presence => {:message => "Bitte geben Sie einen Typ an." }

  #Nicht spezifiziert (außer DB-Einschraenkung)
  validates :Belegdatum, 
    :presence => { :format => { :with => /\d{4}-\d{2}-\d{2}/ }, 
      :message => "Bitte geben Sie ein gültiges Belegdatum an." }

  #Nicht spezifiziert (außer DB-Einschraenkung)
  validates :BuchDatum, 
    :presence => { :format => { :with => /\d{4}-\d{2}-\d{2}/ }, 
      :message => "Bitte geben Sie ein gültiges Buchungsdatum an." }

  #Nicht spezifiziert (außer DB-Einschraenkung)
  validates :Buchungstext, 
    :presence => {:message => "Bitte geben Sie einen Verwendungszweck an." },
    :length => {:maximum => 50, 
      :message => "Der Verwendungszweck ist zu lang. Maximal 50 Zeichen erlaubt."}

  #Nicht spezifiziert (außer DB-Einschraenkung)
  validates :Sollbetrag, 
    :presence => {:message => "Bitte geben Sie einen Betrag (Soll) an." }, 
    :format => { :with => /^\d{,10}[.]?\d{0,2}$/, 
      :message => "Bitte geben Sie einen gültigen Betrag an." }

  #Nicht spezifiziert (außer DB-Einschraenkung)
  validates :Habenbetrag, 
    :presence => {:message => "Bitte geben Sie einen Betrag (Haben) an." }, 
    :format => { :with => /^\d{,10}[.]?\d{0,2}$/, 
      :message => "Bitte geben Sie einen gültigen Betrag an." }

  validates :SollKtoNr, 
    :presence => { :format => { :with => /^[0-9]{5}$/i  },
      :message => "Bitte geben Sie eine Konto-Nr. (Soll) an." }, 
    :length => { :is => 5, :message => "Die Konto-Nr. (Soll) darf nur 5-stellig sein." }, 
    :numericality => { :only_integer => true, 
      :message => "Die Konto-Nr. (Soll) darf nur Zahlen beinhalten." }

  validates :HabenKtoNr, 
    :presence => { :format => { :with => /^[0-9]{5}$/i  },
      :message => "Bitte geben Sie eine Konto-Nr. (Haben) an." }, 
    :length => { :is => 5, :message => "Die Konto-Nr. (Haben) darf nur 5-stellig sein." }, 
    :numericality => { :only_integer => true, 
      :message => "Die Konto-Nr. (Haben) darf nur Zahlen beinhalten." }

  #Nicht spezifiziert (außer DB-Einschraenkung)
  validates :WSaldoAcc, 
    :presence => {:message => "Bitte geben Sie einen wSaldoAcc an." }, 
    :format => { :with => /^\d{,10}[.]?\d{0,2}$/, 
      :message => "Bitte geben Sie einen gültigen wSaldoAcc an." }

  #Nicht spezifiziert (außer DB-Einschraenkung)
  validates :Punkte, 
    :presence => {:message => "Bitte geben Sie die Punkte an." }

  #Nicht spezifiziert (außer DB-Einschraenkung)
  validates :PSaldoAcc, 
    :presence => {:message => "Bitte geben Sie die pSaldoAcc an." }
    
  # column names
  HUMANIZED_ATTRIBUTES = {
    :BuchJahr       => 'Jahr',
    :KtoNr          => 'Konto-Nr.',
    :BnKreis        => 'Belegnummernkreis',
    :BelegNr        => 'Belegnummer',
    :Typ            => 'Typ',
    :Belegdatum     => 'Belegdatum',
    :BuchDatum      => 'Buchungsdatum',
    :Buchungstext   => 'Verwendungszweck',
    :Sollbetrag     => 'Betrag (Soll)',
    :Habenbetrag    => 'Betrag (Haben)',
    :SollKtoNr      => 'Konto (Soll)',
    :HabenKtoNr     => 'Konto (Haben)',
    :WSaldoAcc      => 'wSaldoAcc',
    :Punkte         => 'Punkte',
    :PSaldoAcc      => 'pSaldoAcc'
  }

  def self.human_attribute_name(attr, options={})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end
end