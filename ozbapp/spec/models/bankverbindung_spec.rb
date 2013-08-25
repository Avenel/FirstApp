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

	# set_valid_time (callback methode: before_create)
	it "sets the valid time to GueltigVon = now and GueltigBis = 9999-12-31 23:59:59" do
		bank = FactoryGirl.create(:Bank)
		person = FactoryGirl.create(:Person)
		bankverbindung = FactoryGirl.build(:Bankverbindung, :Pnr => person.Pnr, :BLZ => bank.BLZ)
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
		bankverbindung = FactoryGirl.build(	:Bankverbindung, :Pnr => person.Pnr, 
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
		expect(Bankverbindung.where("ID = ?", bankverbindungOrigin.ID).size).to eq 1

		sleep(1.0)

		bankverbindungOrigin.IBAN = "DE12500105170648489890"
		
		gueltigBis = Time.now
		expect(bankverbindungOrigin.save!).to eq true
		expect(Bankverbindung.where("ID = ?", bankverbindungOrigin.ID).size).to eq 2

		oldBankverbindung = Bankverbindung.where("ID = ? AND GueltigBis < ?", bankverbindungOrigin.ID, Time.zone.parse("9999-12-31 23:59:59")).first
		expect(oldBankverbindung.nil?).to eq false
		expect(oldBankverbindung.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq gueltigVon.strftime("%Y-%m-%d %H:%M:%S")
		expect(oldBankverbindung.GueltigBis.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq gueltigBis.strftime("%Y-%m-%d %H:%M:%S")
	end

	it "does not set the valid time of the new copy, if the id not exists" do
		bankverbindungOrigin = FactoryGirl.create(:bankverbindung_with_bank_and_person)
		gueltigVon = Time.now

		expect(Bankverbindung.where("ID = ?", bankverbindungOrigin.ID).size).to eq 1

		sleep(1.0)

		bankverbindungOrigin.ID = nil
		bankverbindungOrigin.IBAN = "DE12500105170648489890"

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

		expect(Bankverbindung.where("ID = ?", bankverbindungOrigin.ID).size).to eq 1
		expect(bankverbindungOrigin.GueltigBis).to eq Time.zone.parse("9999-12-31 23:59:59")

		sleep(1.0)

		bankverbindungOrigin.GueltigBis = Time.zone.parse("9998-12-31 23:59:59")
		expect(bankverbindungOrigin.save).to eq true

		# change nothing, because one can only modify the latest version
		expect(Bankverbindung.where("ID = ?", bankverbindungOrigin.ID).size).to eq 1
		expect(bankverbindungOrigin.GueltigBis).to eq Time.zone.parse("9998-12-31 23:59:59")	
	end

	# get(id, date)
	it "returns the Bankverbindung for a valid ID and date (=now)" do 
		# create valid ozbkonto, in different versions
		bankverbindungOrigin = FactoryGirl.create(:bankverbindung_with_bank_and_person)
		createdAtOrigin = Time.now
		createdAt = Time.now
		for i in 0..1
			sleep(1.0)
			bankverbindungOrigin.IBAN =  "DE12500105170648489890"
			bankverbindungOrigin.save!
			createdAt = Time.now
		end
		expect(Bankverbindung.where("ID = ?", bankverbindungOrigin.ID).size).to eq 3

		latestBankverbindung = Bankverbindung.get(bankverbindungOrigin.ID, Time.now)

		expect(latestBankverbindung.nil?).to eq false
		expect(latestBankverbindung.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq createdAt.strftime("%Y-%m-%d %H:%M:%S")
		expect(latestBankverbindung.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to_not eq createdAtOrigin.strftime("%Y-%m-%d %H:%M:%S")
	end

	it "returns the Bankverbindung for a valid ID and date (=now - 2 seconds)" do 
		# create valid ozbkonto, in different versions
		bankverbindungOrigin = FactoryGirl.create(:bankverbindung_with_bank_and_person)
		createdAtOrigin = Time.now
		createdAt = Time.now
		for i in 0..1
			sleep(1.0)
			bankverbindungOrigin.IBAN =  "DE12500105170648489890"
			bankverbindungOrigin.save!
			createdAt = Time.now
		end
		expect(Bankverbindung.where("ID = ?", bankverbindungOrigin.ID).size).to eq 3

		latestBankverbindung = Bankverbindung.get(bankverbindungOrigin.ID, createdAtOrigin)

		expect(latestBankverbindung.nil?).to eq false
		expect(latestBankverbindung.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to_not eq createdAt.strftime("%Y-%m-%d %H:%M:%S")
		expect(latestBankverbindung.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq createdAtOrigin.strftime("%Y-%m-%d %H:%M:%S")
	end	

	it "returns nil, if there is no Bankverbindung for a invalid ID or date" do
		# Test for an invalid ID
		bankverbindungOrigin = FactoryGirl.create(:bankverbindung_with_bank_and_person)
		expect(Bankverbindung.get(bankverbindungOrigin.ID + 10, Time.now)).to eq nil

		# create valid ozbkonto, in different versions
		originTime = Time.now
		sleep(1.0)

		bankverbindungOrigin = FactoryGirl.create(:bankverbindung_with_bank_and_person)
		createdAtOrigin = Time.now
		createdAt = Time.now
		for i in 0..1
			sleep(1.0)
			bankverbindungOrigin.IBAN =  "DE12500105170648489890"
			bankverbindungOrigin.save!
			createdAt = Time.now
		end
		expect(Bankverbindung.where("ID = ?", bankverbindungOrigin.ID).size).to eq 3

		latestBankverbindung = Bankverbindung.get(bankverbindungOrigin.ID, originTime)
		expect(latestBankverbindung.nil?).to eq true
	end

	# self.latest(id)
	it "returns the latest version of a given Bankverbindung, for a valid ID" do 
		# create valid Bankverbindung, in different versions
		bankverbindungOrigin = FactoryGirl.create(:bankverbindung_with_bank_and_person)
		createdAtOrigin = Time.now
		createdAt = Time.now
		for i in 0..1
			sleep(1.0)
			bankverbindungOrigin.IBAN =  "DE12500105170648489890"
			bankverbindungOrigin.save!
			createdAt = Time.now
		end
		expect(Bankverbindung.where("ID = ?", bankverbindungOrigin.ID).size).to eq 3

		latestBankverbindung = Bankverbindung.latest(bankverbindungOrigin.ID)

		expect(latestBankverbindung.nil?).to eq false
		expect(latestBankverbindung.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq createdAt.strftime("%Y-%m-%d %H:%M:%S")
		expect(latestBankverbindung.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to_not eq createdAtOrigin.strftime("%Y-%m-%d %H:%M:%S")
	end

	it "returns nil, if there is no Bankverbindung for an invalid ID" do
		expect(Bankverbindung.latest(45)).to eq nil
	end

	# bank_already_exists(bank_attr)
	it "returns true, if there already exists a Bank for a given BLZ in the database" do
		bankverbindung = FactoryGirl.create(:bankverbindung_with_bank_and_person)
		expect(bankverbindung).to be_valid

		# Private method, therfore using send methode
		expect(bankverbindung.send(:bank_already_exists, 'BLZ' => bankverbindung.BLZ)).to eq true
	end

	it "returns false, if there do not already exists a Bank for a given BLZ in the databse" do
		bankverbindung = FactoryGirl.create(:bankverbindung_with_bank_and_person, :BLZ => 42)
		expect(bankverbindung).to be_valid

		# Private method, therfore using send methode
		expect(bankverbindung.send(:bank_already_exists, 'BLZ' => 45)).to eq false
	end

end
