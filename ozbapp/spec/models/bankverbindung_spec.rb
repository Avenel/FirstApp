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

	# valid_id
	it "returns true if id is valid (a Number)" do
		bankverbindung = FactoryGirl.build(:bankverbindung_with_bank_and_person, :id => 42)
		expect(bankverbindung.valid_id).to eq true
	end

	it "returns false if id is invalid (a String)" do
		bankverbindung = FactoryGirl.build(:bankverbindung_with_bank_and_person, :id => "ABCD")
		expect(bankverbindung.valid_id).to eq false
	end

	# set_valid_id (callback methode: before_create)
	it "sets a valid id, if id does not exists. (auto-increment)" do
		bankverbindung = FactoryGirl.create(:bankverbindung_with_bank_and_person, :id => nil)
		expect(bankverbindung).to be_valid
		expect(bankverbindung.id).to eq 1
	end

	# set_valid_time (callback methode: before_create)
	it "sets the valid time to GueltigVon = now and GueltigBis = 9999-12-31 23:59:59" do
		bank = FactoryGirl.create(:Bank)
		person = FactoryGirl.create(:Person)
		bankverbindung = FactoryGirl.build(:Bankverbindung, :Pnr => person.pnr, :BLZ => bank.BLZ)
		expect(bankverbindung).to be_valid

		expect(bankverbindung.GueltigVon).to eq nil		
		expect(bankverbindung.GueltigBis).to eq nil

		expect(bankverbindung.save!).to eq true
		expect(bankverbindung.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq Time.now.strftime("%Y-%m-%d %H:%M:%S")
		expect(bankverbindung.GueltigBis.strftime("%Y-%m-%d %H:%M:%S")).to eq "9999-12-31 23:59:59"
	end

	it "does not set the valid time, if it is already set" do
		bank = FactoryGirl.create(:Bank)
		person = FactoryGirl.create(:Person)
		bankverbindung = FactoryGirl.build(	:Bankverbindung, :Pnr => person.pnr, 
										:BLZ => bank.BLZ, 
										:GueltigVon => Time.zone.parse("2013-01-01 23:59:59"), :GueltigBis => Time.zone.parse("2013-12-31 23:59:59"))
		expect(bankverbindung).to be_valid

		expect(bankverbindung.GueltigVon).to eq Time.zone.parse("2013-01-01 23:59:59")
		expect(bankverbindung.GueltigBis).to eq Time.zone.parse("2013-12-31 23:59:59")

		expect(bankverbindung.save!).to eq true

		expect(bankverbindung.GueltigVon).to eq Time.zone.parse("2013-01-01 23:59:59")
		expect(bankverbindung.GueltigBis).to eq Time.zone.parse("2013-12-31 23:59:59")		
	end

	# set_new_valid_time (callback methode: before_update)
	it "sets the valid time of the new copy to GueltigVon = self.GueltigVon and GueltigBis = Time.now and updates himself to the latest record" do
		bankverbindungOrigin = FactoryGirl.create(:bankverbindung_with_bank_and_person)
		gueltigVon = Time.now
		expect(Bankverbindung.where("ID = ?", bankverbindungOrigin.id).size).to eq 1

		sleep(1.0)

		bankverbindungOrigin.iban = "gueltigeIBAN"
		
		gueltigBis = Time.now
		expect(bankverbindungOrigin.save!).to eq true
		expect(Bankverbindung.where("ID = ?", bankverbindungOrigin.id).size).to eq 2

		oldBankverbindung = Bankverbindung.where("ID = ? AND GueltigBis < ?", bankverbindungOrigin.id, Time.zone.parse("9999-12-31 23:59:59")).first
		expect(oldBankverbindung.nil?).to eq false
		expect(oldBankverbindung.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq gueltigVon.strftime("%Y-%m-%d %H:%M:%S")
		expect(oldBankverbindung.GueltigBis.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq gueltigBis.strftime("%Y-%m-%d %H:%M:%S")
	end

	it "does not set the valid time of the new copy, if the id not exists" do
		bankverbindungOrigin = FactoryGirl.create(:bankverbindung_with_bank_and_person)
		gueltigVon = Time.now

		expect(Bankverbindung.where("ID = ?", bankverbindungOrigin.id).size).to eq 1

		sleep(1.0)

		bankverbindungOrigin.id = nil
		bankverbindungOrigin.iban = "gueltigeIBAN"

		# one cannot save a bankverbindung without a valid id
		exceptionThrown = false
		begin
			bankverbindungOrigin.save!
		rescue Exception => e
			exceptionThrown = true
		end

		expect(exceptionThrown).to eq true
	end

	it "does not set the valid time of the new copy, if GuelitgBis < 9999-01-01 00:00:00" do 
		bankverbindungOrigin = FactoryGirl.create(:bankverbindung_with_bank_and_person)
		gueltigVon = Time.now

		expect(Bankverbindung.where("ID = ?", bankverbindungOrigin.id).size).to eq 1
		expect(bankverbindungOrigin.GueltigBis).to eq Time.zone.parse("9999-12-31 23:59:59")

		sleep(1.0)

		bankverbindungOrigin.GueltigBis = Time.zone.parse("9998-12-31 23:59:59")
		expect(bankverbindungOrigin.save).to eq true

		# change nothing, because one can only modify the latest version
		expect(Bankverbindung.where("ID = ?", bankverbindungOrigin.id).size).to eq 1
		expect(bankverbindungOrigin.GueltigBis).to eq Time.zone.parse("9998-12-31 23:59:59")	
	end

	# get(id, date)
	# self.latest(id)
	# bank_already_exists(bank_attr)
	# destoy_historic_records
	# destroy_bank_if_this_is_last_bankverbindung

end
