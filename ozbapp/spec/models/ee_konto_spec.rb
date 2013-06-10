require 'spec_helper'

describe EeKonto do 
	# Factory
	it "has a valid factory"

	# Valid/invalid attributes
	# Kontonummer
	it "is valid with a valid Kontonummer"
	it "is invalid without a Kontonummer"
	it "is invalid with an invalid Kontonummer"

	# BankID
	it "is valid with a valid BankID"
	it "is invalid without a BankID"
	it "is invalid with an invalid BankID"

	# Kreditlimit
	it "is valid with a valid Kreditlimit"
	it "is valid without a Kreditlimit"

	# SachPnr
	it "is valid with a valid SachPnr"
	it "is valid without a SachPnr"
	it "is invalid with an invalid SachPnr"

	# Class and instance methods 

	# get (ktoNr, date)
	it "returns the EEKonto for a valid Kontonummer and date (=now)"
	it "returns the EEKonto for a valid Kontonummer and date (=now - 2 seconds)"
	it "returns nil, if there is no EEKonto for a invalid Kontonummer"

	# self.latest(ktoNr)
	it "returns the latest version of a given EEKonto, for a valid Kontonummer"
	it "returns nil, if there is no EEKonto for an invalid Kontonummer"

	# ktonr_with_name
	it "returns the last- and firstname of the EEKonto-owner, if owner exists"
	it "returns nil, if owner does not exist"

  	# set_valid_time (callback methode: before_create)
  	it "sets the valid time to GueltigVon = now and GueltigBis = 9999-12-31 23:59:59"
  	it "does not set the valid time, if it is already set"

  	# set_new_valid_time (callback methode: before_update)
  	it "sets the valid time of the new copy to GueltigVon = self.GueltigVon and GueltigBis = Time.now and updates himself to the latest record"
  	it "does not set the valid time of the new copy, if the Kontonummer not exists"
  	it "does not set the valid time of the new copy, if GuelityBis < 9999-01-01 00:00:00"

  	# destroy_historic_records (callback methode: after_destroy)
  	it "destroys all historic records except himself"
  	it "destroys zero records, because there are no historic records"

  	# destroy_ozb_konto_if_this_is_last_konto (callback methode: after_destroy)
  	it "destroys the related ozbKonto, if there are no other historic versions of this record exists"
  	it "does not destroy the related ozbKonto, if there are other historic versions of this record"

  	# destroy_bankverbindung (callback methode: after_destroy)
  	it "destroys the related bankverbindung, if there is any related to this EEKonto"
  	it "does not destroy any bankverbindung, if there is none related to this EEKonto"
end