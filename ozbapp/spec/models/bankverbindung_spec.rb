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

	# BankKtoNr
	it "is valid with a valid Kontonummer" do
		expect(FactoryGirl.create(:bankverbindung_with_bank_and_person, :BankKtoNr => 12345678)).to be_valid
	end

	it "is invalid without a Kontonummer" do
		expect(FactoryGirl.build(:bankverbindung_with_bank_and_person, :BankKtoNr => nil)).to be_invalid
	end

	it "is invalid with an invalid Kontonummer" do
		expect(FactoryGirl.build(:bankverbindung_with_bank_and_person, :BankKtoNr => "ABCDEFG")).to be_invalid
	end

	# Class and instance methods	

	# bank_exists
	it "returns true if a bank, given by a BLZ, exists in the database" do
		bank = FactoryGirl.create(:Bank)
		expect(bank).to be_valid
		expect(Bank.where("BLZ = ?", bank.BLZ).size).to eq 1

		bankverbindung = FactoryGirl.create(:bankverbindung_with_person, :BLZ => bank.BLZ)
		expect(bankverbindung).to be_valid

		expect(bankverbindung.bank_exists).to eq true		
	end

	it "returns false if a bank, given by a BLZ, does not exists in the database" do
		bankverbindung = FactoryGirl.create(:bankverbindung_with_bank_and_person, :BLZ => 12345678)
		expect(bankverbindung).to be_valid

		bankverbindung.BLZ = 45
		expect(bankverbindung.bank_exists).to eq false
	end

	# set_valid_id (callback methode: before_create)
	it "sets a valid id, if id does not exists. (auto-increment)" do
		bankverbindung = FactoryGirl.create(:bankverbindung_with_bank_and_person, :id => nil)
		expect(bankverbindung).to be_valid
		expect(bankverbindung.id).to eq 1
	end

	# set_valid_time
	# set_new_valid_time
	# get(id, date)
	# self.latest(id)
	# bank_already_exists(bank_attr)
	# destoy_historic_records
	# destroy_bank_if_this_is_last_bankverbindung

end
