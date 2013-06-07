require 'spec_helper'

describe Bankverbindung do
	# Factory
	it "has a valid factory" do
		expect(FactoryGirl.create(:bankverbindung_with_bank_and_person)).to be_valid
	end

	# Valid/invalid attributes
	# ID
	it "is valid with a valid ID" do
		expect(FactoryGirl.create(:bankverbindung_with_bank_and_person, :ID => 42)).to be_valid
	end

	it "is invalid without a ID" do
		expect(FactoryGirl.build(:bankverbindung_with_bank_and_person, :ID => nil)).to be_invalid
	end

	it "is invalid with an invalid ID" do
		expect(FactoryGirl.build(:bankverbindung_with_bank_and_person, :ID => "A2A")).to be_invalid
	end

	# Pnr
	it "is valid with a valid pnr" do
		expect(FactoryGirl.create(:bankverbindung_with_bank_and_person, :Pnr => 42)).to be_valid
	end

	it "is invalid without a pnr" do
		expect(FactoryGirl.build(:bankverbindung_with_bank_and_person, :Pnr => nil)).to be_invalid
	end

	it "is invalid with an invalid pnr" do
		# set an invalid pnr (person does not exists)
		bankverbindung = FactoryGirl.build(:bankverbindung_with_bank, :Pnr => 45)
		expect(bankverbindung).to be_invalid
	end

	# BLZ
	it "is valid with a valid BLZ" do
		expect(FactoryGirl.create(:bankverbindung_with_bank_and_person, :BLZ => 12345678)).to be_valid
	end

	it "is invalid without a BLZ" do
		expect(FactoryGirl.build(:bankverbindung_with_bank_and_person, :BLZ => nil)).to be_invalid
	end

	it "is invalid with an invalid BLZ" do 
		expect(FactoryGirl.build(:bankverbindung_with_bank_and_person, :BLZ => 1234)).to be_invalid
		expect(FactoryGirl.build(:bankverbindung_with_bank_and_person, :BLZ => "Hello")).to be_invalid
		expect(FactoryGirl.build(:bankverbindung_with_bank_and_person, :BLZ => "1234567890ABC")).to be_invalid
	end

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
