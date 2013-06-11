require 'spec_helper'

describe EeKonto do 
	# Factory
	it "has a valid factory" do
		expect(FactoryGirl.create(:eekonto_with_ozbkonto_and_sachPerson_and_bankverbindung)).to be_valid
	end

	# Valid/invalid attributes
	# Kontonummer
	it "is valid with a valid Kontonummer" do
		expect(FactoryGirl.create(:eekonto_with_ozbkonto_and_sachPerson_and_bankverbindung, :ktoNr => 12345)).to be_valid
	end

	it "is invalid without a Kontonummer" do
		eeKonto = FactoryGirl.build(:eekonto_with_ozbkonto_and_sachPerson_and_bankverbindung, :ktoNr => nil)
		expect(eeKonto).to be_invalid
	end

	it "is invalid with an invalid Kontonummer" do
		# invalid ktoNr
		eeKonto = FactoryGirl.build(:eekonto_with_ozbkonto_and_sachPerson_and_bankverbindung, :ktoNr => 123456)
		expect(eeKonto).to be_invalid

		# non existent ktoNr
		eeKonto = FactoryGirl.build(:eekonto_with_ozbkonto_and_sachPerson_and_bankverbindung, :ktoNr => 12345)
		eeKonto.ktoNr = 11111
		expect(eeKonto).to be_invalid
	end

	# BankID
	it "is valid with a valid BankID" do
		eeKonto = FactoryGirl.create(:eekonto_with_ozbkonto_and_sachPerson_and_bankverbindung)
		expect(eeKonto).to be_valid

		ozbKonto = OzbKonto.where("KtoNr = ?", eeKonto.ktoNr).first
		expect(ozbKonto.nil?).to eq false
		
		person = Person.where("Pnr = ?", ozbKonto.mnr).first
		expect(person.nil?).to eq false

		bankverbindung = FactoryGirl.create(:bankverbindung_with_bank_and_person, :pnr => person.pnr)
		expect(bankverbindung).to be_valid

		eeKonto.bankId = bankverbindung.id

		sleep(1.0)
		expect(eeKonto).to be_valid
		expect(eeKonto.save).to eq true
	end

	it "is invalid without a BankID" do
		eeKonto = FactoryGirl.build(:eekonto_with_ozbkonto_and_sachPerson_and_bankverbindung, :bankId => nil)
		expect(eeKonto).to be_invalid
	end

	it "is invalid with an invalid BankID" do
		eeKonto = FactoryGirl.build(:eekonto_with_ozbkonto_and_sachPerson_and_bankverbindung, :bankId => 45)
		expect(eeKonto).to be_invalid
	end

	# Kreditlimit
	it "is valid with a valid Kreditlimit" do
		expect(FactoryGirl.create(:eekonto_with_ozbkonto_and_sachPerson_and_bankverbindung, :kreditlimit => 10000)).to be_valid
	end

	it "is invalid without a Kreditlimit" do
		eeKonto = FactoryGirl.build(:eekonto_with_ozbkonto_and_sachPerson_and_bankverbindung, :kreditlimit => nil)
		expect(eeKonto).to be_invalid
	end

	it "is invalid with an invalid Kreditlimit" do
		eeKonto = FactoryGirl.build(:eekonto_with_ozbkonto_and_sachPerson_and_bankverbindung, :kreditlimit => "ABCDE")
		expect(eeKonto).to be_invalid

		eeKonto = FactoryGirl.build(:eekonto_with_ozbkonto_and_sachPerson_and_bankverbindung, :kreditlimit => -1000)
		expect(eeKonto).to be_invalid
	end

	# SachPnr
	it "is valid with a valid SachPnr" do
		sachPerson = FactoryGirl.create(:ozbperson_with_person)
		expect(sachPerson).to be_valid

		expect(FactoryGirl.create(:eekonto_with_ozbkonto_and_sachPerson_and_bankverbindung, :sachPnr => sachPerson.mnr)).to be_valid
	end

	it "is valid without a SachPnr" do
		expect(FactoryGirl.create(:eekonto_with_ozbkonto_and_sachPerson_and_bankverbindung, :sachPnr => nil)).to be_valid
	end

	it "is invalid with an invalid SachPnr" do
		expect(FactoryGirl.create(:eekonto_with_ozbkonto_and_sachPerson_and_bankverbindung, :sachPnr => 45)).to be_valid
	end

	# Class and instance methods 

	# kto_exists
	it "returns true, if the OZBKonto for a given Kontonummer exists" do
		# create one eekonto
		ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson, :ktoNr => 42)
		sachPerson = FactoryGirl.create(:ozbperson_with_person)
		bankverbindung = FactoryGirl.create(:bankverbindung_with_bank, :pnr => ozbKonto.mnr)

  		eeKontoOrigin = FactoryGirl.build(:EeKonto, :ktoNr => 42, :sachPnr => sachPerson.mnr, 
  									:bankId => bankverbindung.id)
		
		expect(eeKontoOrigin.kto_exists).to eq true
	end

	it "returns false, if the OZBKonto for a given Kontonummer does not exist" do
		# non existent ktoNr
		eeKonto = FactoryGirl.build(:eekonto_with_ozbkonto_and_sachPerson_and_bankverbindung)
		eeKonto.ktoNr = 11111
		expect(eeKonto.kto_exists).to eq false
	end

	# bankId_exists
	it "returns true, if the Bankverbindung for a given BankID exists" do
		# create one eekonto
		ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson)
		sachPerson = FactoryGirl.create(:ozbperson_with_person)
		bankverbindung = FactoryGirl.create(:bankverbindung_with_bank, :pnr => ozbKonto.mnr, :id => 42)

  		eeKontoOrigin = FactoryGirl.build(:EeKonto, :ktoNr => ozbKonto.ktoNr, :sachPnr => sachPerson.mnr, 
  									:bankId => 42)
		
		expect(eeKontoOrigin.bankId_exists).to eq true
	end

	it "returns false, if the Bankverbindung for a given BankID does not exist" do
		eeKonto = FactoryGirl.build(:eekonto_with_ozbkonto_and_sachPerson_and_bankverbindung)
		eeKonto.bankId = 45

		expect(eeKonto.bankId_exists).to eq false
	end

	# sachPnr_exists
	it "returns true if a valid sachPnr exists" do
		eeKonto = FactoryGirl.create(:eekonto_with_ozbkonto_and_sachPerson_and_bankverbindung)
		
		ozbperson = FactoryGirl.create(:ozbperson_with_person)
		eeKonto.sachPnr = ozbperson.mnr
		
		expect(eeKonto.sachPnr_exists).to eq true
	end

	it "returns false if an invalid sachPnr exists" do
		eeKonto = FactoryGirl.create(:eekonto_with_ozbkonto_and_sachPerson_and_bankverbindung)
		eeKonto.sachPnr = 45

		expect(eeKonto.sachPnr_exists).to eq false
	end

	# get (ktoNr, date)
	it "returns the EEKonto for a valid Kontonummer and date (=now)" do 
		# create valid eeKonto, in different versions
		eeKontoOrigin = FactoryGirl.create(:eekonto_with_ozbkonto_and_sachPerson_and_bankverbindung)
		createdAtOrigin = Time.now
		createdAt = Time.now
		for i in 0..1
			sleep(1.0)
			eeKontoOrigin.kreditlimit +=  1
			eeKontoOrigin.save!
			createdAt = Time.now
		end
		expect(EeKonto.where("KtoNr = ?", eeKontoOrigin.ktoNr).size).to eq 3

		latestEEKonto = eeKontoOrigin.get(eeKontoOrigin.ktoNr, Time.now)

		expect(latestEEKonto.nil?).to eq false
		expect(latestEEKonto.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq createdAt.strftime("%Y-%m-%d %H:%M:%S")
		expect(latestEEKonto.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to_not eq createdAtOrigin.strftime("%Y-%m-%d %H:%M:%S")
	end

	it "returns the EEKonto for a valid Kontonummer and date (=now - 2 seconds)" do
		# create valid eekonto, in different versions
		eeKontoOrigin = FactoryGirl.create(:eekonto_with_ozbkonto_and_sachPerson_and_bankverbindung)
		createdAtOrigin = Time.now
		createdAt = Time.now
		for i in 0..1
			sleep(1.0)
			eeKontoOrigin.kreditlimit +=  1
			eeKontoOrigin.save!
			createdAt = Time.now
		end
		expect(EeKonto.where("KtoNr = ?", eeKontoOrigin.ktoNr).size).to eq 3

		latestEEKonto = eeKontoOrigin.get(eeKontoOrigin.ktoNr, createdAtOrigin)

		expect(latestEEKonto.nil?).to eq false
		expect(latestEEKonto.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to_not eq createdAt.strftime("%Y-%m-%d %H:%M:%S")
		expect(latestEEKonto.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq createdAtOrigin.strftime("%Y-%m-%d %H:%M:%S")
	end

	it "returns nil, if there is no EEKonto for an invalid Kontonummer or date" do
		# Test for an invalid Kontonummer
		eeKontoOrigin = FactoryGirl.create(:eekonto_with_ozbkonto_and_sachPerson_and_bankverbindung)
		expect(eeKontoOrigin.get(eeKontoOrigin.ktoNr + 10, Time.now)).to eq nil

		# create valid eekonto, in different versions
		originTime = Time.now
		sleep(1.0)

		eeKontoOrigin = FactoryGirl.create(:eekonto_with_ozbkonto_and_sachPerson_and_bankverbindung)
		createdAtOrigin = Time.now
		createdAt = Time.now
		for i in 0..1
			sleep(1.0)
			eeKontoOrigin.kreditlimit +=  1
			eeKontoOrigin.save!
			createdAt = Time.now
		end
		expect(EeKonto.where("KtoNr = ?", eeKontoOrigin.ktoNr).size).to eq 3

		latestEEKonto = eeKontoOrigin.get(eeKontoOrigin.ktoNr, originTime)
		expect(latestEEKonto.nil?).to eq true
	end

	# self.latest(ktoNr)
	it "returns the latest version of a given EEKonto, for a valid Kontonummer" do
		# create valid ozbkonto, in different versions
		eeKontoOrigin = FactoryGirl.create(:eekonto_with_ozbkonto_and_sachPerson_and_bankverbindung)
		createdAtOrigin = Time.now
		createdAt = Time.now
		for i in 0..1
			sleep(1.0)
			eeKontoOrigin.kreditlimit +=  1
			eeKontoOrigin.save
			createdAt = Time.now
		end
		expect(EeKonto.where("KtoNr = ?", eeKontoOrigin.ktoNr).size).to eq 3

		latestEEKonto = EeKonto.latest(eeKontoOrigin.ktoNr)

		expect(latestEEKonto.nil?).to eq false
		expect(latestEEKonto.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq createdAt.strftime("%Y-%m-%d %H:%M:%S")
		expect(latestEEKonto.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to_not eq createdAtOrigin.strftime("%Y-%m-%d %H:%M:%S")
	end

	it "returns nil, if there is no EEKonto for an invalid Kontonummer" do
		expect(EeKonto.latest(45)).to eq nil
	end

	# ktonr_with_name
	it "returns the last- and firstname of the EEKonto-owner, if owner exists" do
		person = FactoryGirl.create(:Person, :Vorname => "Max", :Name => "Mustermann")
		expect(person).to be_valid

		ozbPerson = FactoryGirl.create(:OZBPerson, :mnr => person.pnr, :ueberPnr => person.pnr)
		expect(ozbPerson).to be_valid

		sachPerson = FactoryGirl.create(:ozbperson_with_person)
		expect(sachPerson).to be_valid

		ozbKonto = FactoryGirl.create(:OzbKonto, :mnr => ozbPerson.mnr, :sachPnr => sachPerson.mnr)
		expect(ozbKonto).to be_valid

		bankverbindung = FactoryGirl.create(:bankverbindung_with_bank, :pnr => person.pnr)
		expect(bankverbindung).to be_valid

		eeKonto = FactoryGirl.create(:eekonto_with_sachPerson, :ktoNr => ozbKonto.ktoNr, :bankId => bankverbindung.id)	
		expect(EeKonto.where("KtoNr = ?", eeKonto.ktoNr).size).to eq 1

		expect(eeKonto.ktonr_with_name).to eq "[" + ozbKonto.ktoNr.to_s + "] " + "Mustermann, Max"
	end


	it "returns nil, if owner does not exist" do
		# the owner does not exists, if the related ozbkonto does not exists, therefore ozbKonto = nil
		# should be failing validation anyway.
		eeKonto = FactoryGirl.build(:eekonto_with_ozbkonto_and_sachPerson_and_bankverbindung, :ktoNr => nil)
		
		expect(eeKonto.ktonr_with_name).to eq nil
	end

  	# set_valid_time (callback methode: before_create)
  	it "sets the valid time to GueltigVon = now and GueltigBis = 9999-12-31 23:59:59" do
  		ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson)
		sachPerson = FactoryGirl.create(:ozbperson_with_person)
		bankverbindung = FactoryGirl.create(:bankverbindung_with_bank, :pnr => ozbKonto.mnr)

  		eeKonto = FactoryGirl.build(:EeKonto, :ktoNr => ozbKonto.ktoNr, :sachPnr => sachPerson.mnr, 
  									:bankId => bankverbindung.id)
		expect(eeKonto).to be_valid

		expect(eeKonto.GueltigVon).to eq nil		
		expect(eeKonto.GueltigBis).to eq nil

		expect(eeKonto.save!).to eq true
		expect(eeKonto.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq Time.now.strftime("%Y-%m-%d %H:%M:%S")
		expect(eeKonto.GueltigBis.strftime("%Y-%m-%d %H:%M:%S")).to eq "9999-12-31 23:59:59"
	end

  	it "does not set the valid time, if it is already set" do
  		ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson)
		sachPerson = FactoryGirl.create(:ozbperson_with_person)
		bankverbindung = FactoryGirl.create(:bankverbindung_with_bank, :pnr => ozbKonto.mnr)

  		eeKonto = FactoryGirl.build(:EeKonto, :ktoNr => ozbKonto.ktoNr, :sachPnr => sachPerson.mnr, 
  									:bankId => bankverbindung.id, 
  									:GueltigVon => Time.zone.parse("2013-01-01 23:59:59"), :GueltigBis => Time.zone.parse("2013-12-31 23:59:59"))
		expect(eeKonto).to be_valid

		expect(eeKonto.GueltigVon).to eq Time.zone.parse("2013-01-01 23:59:59")
		expect(eeKonto.GueltigBis).to eq Time.zone.parse("2013-12-31 23:59:59")

		expect(eeKonto.save!).to eq true

		expect(eeKonto.GueltigVon).to eq Time.zone.parse("2013-01-01 23:59:59")
		expect(eeKonto.GueltigBis).to eq Time.zone.parse("2013-12-31 23:59:59")
  	end

  	# set_new_valid_time (callback methode: before_update)
  	it "sets the valid time of the new copy to GueltigVon = self.GueltigVon and GueltigBis = Time.now and updates himself to the latest record" do
  		eeKontoOrigin = FactoryGirl.create(:eekonto_with_ozbkonto_and_sachPerson_and_bankverbindung)
		gueltigVon = Time.now
		
		expect(EeKonto.where("KtoNr = ?", eeKontoOrigin.ktoNr).size).to eq 1

		sleep(1.0)

		eeKontoOrigin.kreditlimit += 1
		
		gueltigBis = Time.now
		expect(eeKontoOrigin.save!).to eq true
		expect(EeKonto.where("KtoNr = ?", eeKontoOrigin.ktoNr).size).to eq 2

		oldEEKonto = EeKonto.where("KtoNr = ? AND GueltigBis < ?", eeKontoOrigin.ktoNr, Time.zone.parse("9999-12-31 23:59:59")).first
		expect(oldEEKonto.nil?).to eq false
		expect(oldEEKonto.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq gueltigVon.strftime("%Y-%m-%d %H:%M:%S")
		expect(oldEEKonto.GueltigBis.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq gueltigBis.strftime("%Y-%m-%d %H:%M:%S")
	end

  	it "does not set the valid time of the new copy, if the Kontonummer not exists" do
  		eeKontoOrigin = FactoryGirl.create(:eekonto_with_ozbkonto_and_sachPerson_and_bankverbindung)
		gueltigVon = Time.now

		expect(EeKonto.where("KtoNr = ?", eeKontoOrigin.ktoNr).size).to eq 1

		sleep(1.0)

		eeKontoOrigin.ktoNr = nil
		eeKontoOrigin.kreditlimit += 1

		# one cannot save an eekonto without a valid kontonummer
		expect(eeKontoOrigin.save).to eq false
  	end

  	it "does not set the valid time of the new copy, if GuelityBis < 9999-01-01 00:00:00" do
  		eeKontoOrigin = FactoryGirl.create(:eekonto_with_ozbkonto_and_sachPerson_and_bankverbindung)
		gueltigVon = Time.now

		expect(EeKonto.where("KtoNr = ?", eeKontoOrigin.ktoNr).size).to eq 1

		expect(eeKontoOrigin.GueltigBis).to eq Time.zone.parse("9999-12-31 23:59:59")

		sleep(1.0)

		eeKontoOrigin.GueltigBis = Time.zone.parse("9998-12-31 23:59:59")
		expect(eeKontoOrigin.save).to eq true

		# change nothing, because one can only modify the latest version
		expect(EeKonto.where("KtoNr = ?", eeKontoOrigin.ktoNr).size).to eq 1
		expect(eeKontoOrigin.GueltigBis).to eq Time.zone.parse("9998-12-31 23:59:59")
	end

  	# destroy_historic_records (callback methode: after_destroy)
  	it "destroys all historic records except himself" do
  		# create valid ozbkonto, in different versions
		eeKontoOrigin = FactoryGirl.create(:eekonto_with_ozbkonto_and_sachPerson_and_bankverbindung)
		for i in 0..1
			sleep(1.0)
			eeKontoOrigin.kreditlimit +=  1
			eeKontoOrigin.save!
		end
		expect(EeKonto.where("KtoNr = ?", eeKontoOrigin.ktoNr).size).to eq 3

		# Private method, therfore using send methode
		eeKontoOrigin.send(:destroy_historic_records)

		expect(EeKonto.where("KtoNr = ?", eeKontoOrigin.ktoNr).size).to eq 1
	end

  	it "destroys zero records, because there are no historic records" do
  		# non-existing eekonto
  		expect(EeKonto.where("KtoNr = ?", 42).size).to eq 0

  		# create one eekonto
		ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson, :ktoNr => 42)
		sachPerson = FactoryGirl.create(:ozbperson_with_person)
		bankverbindung = FactoryGirl.create(:bankverbindung_with_bank, :pnr => ozbKonto.mnr)

  		eeKontoOrigin = FactoryGirl.create(:EeKonto, :ktoNr => ozbKonto.ktoNr, :sachPnr => sachPerson.mnr, 
  									:bankId => bankverbindung.id)
		expect(eeKontoOrigin).to be_valid

		expect(eeKontoOrigin.ktoNr).to eq 42
		expect(EeKonto.where("KtoNr = ?", eeKontoOrigin.ktoNr).size).to eq 1

		# Private method, therfore using send methode
		eeKontoOrigin.send(:destroy_historic_records)

		expect(EeKonto.where("KtoNr = ?", eeKontoOrigin.ktoNr).size).to eq 1
	end

  	# destroy_ozb_konto_if_this_is_last_konto (callback methode: after_destroy)
  	it "destroys the related ozbKonto, if there are no other historic versions of this record exists" do
  		eeKontoOrigin = FactoryGirl.create(:eekonto_with_ozbkonto_and_sachPerson_and_bankverbindung)
  		expect(eeKontoOrigin).to be_valid
  		expect(EeKonto.where("KtoNr = ?", eeKontoOrigin.ktoNr).size).to eq 1

  		ozbKonto = OzbKonto.where("KtoNr = ?", eeKontoOrigin.ktoNr).first
  		expect(ozbKonto.nil?).to eq false

  		ktoNr = eeKontoOrigin.ktoNr

  		eeKontoOrigin.destroy
		expect(EeKonto.where("KtoNr = ?", ktoNr).size).to eq 0
		expect(OzbKonto.where("KtoNr = ?", ktoNr).size).to eq 0
  	end
  	it "does not destroy the related ozbKonto, if there are other historic versions of this record" do
  		eeKontoOrigin = FactoryGirl.create(:eekonto_with_ozbkonto_and_sachPerson_and_bankverbindung)
  		createdAtOrigin = Time.now
  		expect(eeKontoOrigin).to be_valid

		ozbKonto = OzbKonto.where("KtoNr = ?", eeKontoOrigin.ktoNr).first
  		expect(ozbKonto.nil?).to eq false

  		ktoNr = eeKontoOrigin.ktoNr

  		# create more than one version of this record
		for i in 0..1
			sleep(1.0)
			eeKontoOrigin.kreditlimit +=  1
			eeKontoOrigin.save!
		end
		expect(EeKonto.where("KtoNr = ?", eeKontoOrigin.ktoNr).size).to eq 3

		# delete the first record
		eeKontoToDelete = eeKontoOrigin.get(ktoNr, createdAtOrigin)
		expect(eeKontoToDelete.nil?).to eq false

		eeKontoToDelete.destroy
		expect(EeKonto.where("KtoNr = ?", ktoNr).size).to eq 2
		expect(OzbKonto.where("KtoNr = ?", ktoNr).size).to eq 1
  	end

  	# destroy_bankverbindung (callback methode: after_destroy)
  	# Why one destroys the related bankverbindung?!
  	it "destroys the related bankverbindung, if there is any related to this EEKonto"
  	it "does not destroy any bankverbindung, if there is none related to this EEKonto"
end