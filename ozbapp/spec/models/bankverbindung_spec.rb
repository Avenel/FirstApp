require 'spec_helper'

describe Bankverbindung do
	# Factory
	it "has a valid factory" do
		expect(FactoryGirl.create(:bankverbindung_with_bank_and_person)).to be_valid
	end

	# Valid/invalid attributes
	# ID
	it "is valid with a valid ID"
	it "is invalid without a ID"
	it "is invalid with an invalid ID"

	# Pnr
	it "is valid with a valid pnr"
	it "is invalid without a pnr"
	it "is invalid with an invalid pnr"

	# BLZ
	it "is valid with a valid BLZ"
	it "is invalid without a BLZ"
	it "is invalid with an invalid BLZ"

	# KtoNr
	it "is valid with a valid Kontonummer"
	it "is invalid without a Kontonummer"
	it "is invalid with an invalid Kontonummer"

	# Class and instance methods	

	# bank_exists
	# set_valid_id
	# set_valid_time
	# set_new_valid_time
	# get(id, date)
	# self.latest(id)
	# bank_already_exists(bank_attr)
	# destoy_historic_records
	# destroy_bank_if_this_is_last_bankverbindung

end
