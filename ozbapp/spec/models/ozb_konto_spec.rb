require 'spec_helper'

describe OzbKonto do

	# Factory 
	it "has a valid factory" do
		ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson)
		expect(ozbKonto).to be_valid

		expect(ozbKonto.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq Time.now.strftime("%Y-%m-%d %H:%M:%S")
		expect(ozbKonto.GueltigBis.strftime("%Y-%m-%d %H:%M:%S")).to eq "9999-12-31 23:59:59"
	end

	# Valid/invalid attributes

	# Kontonummer (ktoNr)
	it "is valid with a valid Kontonummer" do
		expect(FactoryGirl.create(:ozbkonto_with_ozbperson, :KtoNr => 51234)).to be_valid
	end

	it "is invalid without a Kontonummer" do 
		expect(FactoryGirl.build(:ozbkonto_with_ozbperson, :KtoNr => nil)).to be_invalid
	end

	it "is invalid with an invalid Kontonummer" do 
		expect(FactoryGirl.build(:ozbkonto_with_ozbperson, :KtoNr => "a1234")).to be_invalid

		expect(FactoryGirl.build(:ozbkonto_with_ozbperson, :KtoNr => 123456)).to be_invalid

		expect(FactoryGirl.build(:ozbkonto_with_ozbperson, :KtoNr => 45)).to be_invalid

		expect(FactoryGirl.build(:ozbkonto_with_ozbperson, :KtoNr => "hellow")).to be_invalid
	end

	# Mitgliedsnummer (mnr)
	it "is valid with a valid Mitgliedsnummer" do
		person = FactoryGirl.create(:Person, :Pnr => 42)
		expect(person).to be_valid

		ozbperson = FactoryGirl.create(:OZBPerson, :Mnr => 42, :UeberPnr => 42)
		expect(ozbperson).to be_valid

		sachbearbeiter = FactoryGirl.create(:ozbperson_with_person)
		expect(sachbearbeiter).to be_valid

		expect(FactoryGirl.build(:ozbkonto_with_waehrung, :Mnr => 42, :SachPnr => sachbearbeiter.Mnr, 
								:WaehrungID => FactoryGirl.create(:Waehrung))).to be_valid
	end

	it "is invalid without a Mitgliedsnummer" do
		expect(FactoryGirl.build(:OzbKonto, :Mnr => nil)).to be_invalid
	end

	it "is invalid with an invalid Mitgliedsnummer" do 
		person = FactoryGirl.create(:Person, :Pnr => 42)
		expect(person).to be_valid

		ozbperson = FactoryGirl.create(:OZBPerson, :Mnr => 42, :UeberPnr => 42)
		expect(ozbperson).to be_valid

		expect(FactoryGirl.build(:OzbKonto, :Mnr => 45)).to be_invalid
		expect(FactoryGirl.build(:OzbKonto, :Mnr => "as")).to be_invalid
	end


	# Sachbearbeiter Personalnummer (sachPnr)
	it "is valid with a valid Sachbearbeiter Personalnummer" do 
		sachbearbeiter = FactoryGirl.create(:ozbperson_with_person)
		expect(sachbearbeiter).to be_valid

		expect(FactoryGirl.create(:ozbkonto_with_ozbperson, :SachPnr => sachbearbeiter.Mnr)).to be_valid		
	end

	# Ist nun der Sachbearbeiter pflicht, oder nicht?
	it "is invalid without a Sachbearbeiter Personalnummer" do 
		expect(FactoryGirl.build(:ozbkonto_with_ozbperson, :SachPnr => nil)).to be_invalid		
	end

	it "is invalid with an invalid Sachbearbeiter Personalnummer" do
		expect(FactoryGirl.build(:ozbkonto_with_ozbperson, :SachPnr => 45)).to be_invalid
		expect(FactoryGirl.build(:ozbkonto_with_ozbperson, :SachPnr => "hello")).to be_invalid
	end

	# Währung
	it "is valid with a valid Waehrung" do
		expect(FactoryGirl.create(:ozbkonto_with_ozbperson, :Waehrung => FactoryGirl.create(:Waehrung))).to be_valid
	end

	it "is invalid without a Waehrung" do
		expect(FactoryGirl.build(:ozbkonto_with_ozbperson, :Waehrung => nil)).to be_invalid
	end

	it "is invalid with an invalid Waehrung" do
		expect(FactoryGirl.build(:ozbkonto_with_ozbperson, :Waehrung => FactoryGirl.create(:Waehrung))).to be_invalid
	end


	# Class and instance methods 

	# ozbperson_exists
	it "returns true if a valid person exists" do
		ozbkonto = FactoryGirl.create(:ozbkonto_with_ozbperson)
		
		ozbperson = FactoryGirl.create(:ozbperson_with_person)
		ozbkonto.Mnr = ozbperson.Mnr
		
		expect(ozbkonto.ozbperson_exists).to eq true
	end

	it "returns false if an invalid person exists" do
		ozbkonto = FactoryGirl.create(:ozbkonto_with_ozbperson)
		ozbkonto.Mnr = 1337
		
		expect(ozbkonto.ozbperson_exists).to eq false
	end

	# sachPnr_exists
	it "returns true if a valid sachPnr exists" do
		ozbkonto = FactoryGirl.create(:ozbkonto_with_ozbperson)
		
		ozbperson = FactoryGirl.create(:ozbperson_with_person)
		ozbkonto.SachPnr = ozbperson.Mnr
		
		expect(ozbkonto.sachPnr_exists).to eq true
	end

	it "returns false if an invalid sachPnr exists" do
		ozbkonto = FactoryGirl.create(:ozbkonto_with_ozbperson)
		ozbkonto.SachPnr = 45
		
		expect(ozbkonto.sachPnr_exists).to eq false
	end

	# self.get_all_ee_for(mnr)
	it "returns all EE-Konten for a given Mitgliedsnummer" do
		# create 1 OZBPerson
		ozbPerson = FactoryGirl.create(:ozbperson_with_person)
		pnr = ozbPerson.UeberPnr

		sachPerson = FactoryGirl.create(:ozbperson_with_person)
		sachPnr = sachPerson.UeberPnr
		
		expect(OZBPerson.where("Mnr = ?", pnr).size).to eq 1
		expect(OZBPerson.where("Mnr = ?", sachPnr).size).to eq 1

		# create 1 bankverbindung
		bankverbindung = FactoryGirl.create(:bankverbindung_with_bank, :Pnr => pnr)

		# create 3 EEKonten
		ktoNr = 12345
		for i in 0..2
			ozbKonto = FactoryGirl.create(:ozbkonto_with_waehrung, :KtoNr => ktoNr, :Mnr => pnr, :SachPnr => sachPnr)
			eeKonto = FactoryGirl.create(:EeKonto, :SachPnr => sachPnr, :BankID => bankverbindung.ID, :KtoNr => ktoNr)
			ktoNr += 1

			# create more versions
			sleep(1.0)
			eeKonto.Kreditlimit += 1
			expect(eeKonto.save).to eq true
		end

		expect(EeKonto.find(:all).size).to eq 6

		expect(OzbKonto.get_all_ee_for(pnr).size).to eq 3
	end

	it "returns nil for an invalid Mitgliedsnummer" do
		expect(OzbKonto.get_all_ee_for(45).size).to eq 0
	end

	# self.get_all_ze_for(mnr)
	it "returns all ZE-Konten for a given Mitgliedsnummer" do
		ozbPerson = FactoryGirl.create(:ozbperson_with_person)
		pnr = ozbPerson.UeberPnr

		sachPerson = FactoryGirl.create(:ozbperson_with_person)
		sachPnr = sachPerson.UeberPnr
		
		expect(OZBPerson.where("Mnr = ?", pnr).size).to eq 1
		expect(OZBPerson.where("Mnr = ?", sachPnr).size).to eq 1

		ktoNr = 12345
		for i in 0..2
			ozbKonto = FactoryGirl.create(:ozbkonto_with_waehrung, :KtoNr => ktoNr, :Mnr => pnr, :SachPnr => sachPnr)
			zeKonto = FactoryGirl.create(:zeKonto_with_EEKonto_Projektgruppe, :KtoNr => ktoNr)
			expect(zeKonto).to be_valid

			#create more versions
			sleep(1.0)
			zeKonto.Laufzeit += 1
			expect(zeKonto.save).to eq true

			ktoNr += 1
		end

		expect(ZeKonto.find(:all).size).to eq 6

		expect(OzbKonto.get_all_ze_for(pnr).size).to eq 3
	end

	it "returns nil for an invalid Mitgliedsnummer" do
		expect(OzbKonto.get_all_ze_for(45).size).to eq 0
	end

	# get(ktoNr, date = Time.now)
	it "returns the OZBKonto for a valid Kontonummer and date (=now)" do 
		# create valid ozbkonto, in different versions
		ozbKontoOrigin = FactoryGirl.create(:ozbkonto_with_ozbperson)
		createdAtOrigin = Time.now
		createdAt = Time.now
		for i in 0..1
			sleep(1.0)
			ozbKontoOrigin.WSaldo +=  1
			ozbKontoOrigin.save!
			createdAt = Time.now
		end
		expect(OzbKonto.where("KtoNr = ?", ozbKontoOrigin.KtoNr).size).to eq 3

		latestOzbKonto = OzbKonto.get(ozbKontoOrigin.KtoNr, Time.now)

		expect(latestOzbKonto.nil?).to eq false
		expect(latestOzbKonto.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq createdAt.strftime("%Y-%m-%d %H:%M:%S")
		expect(latestOzbKonto.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to_not eq createdAtOrigin.strftime("%Y-%m-%d %H:%M:%S")
	end

	it "returns the OZBKonto for a valid Kontonummer and date (=now - 2 seconds)" do 
		# create valid ozbkonto, in different versions
		ozbKontoOrigin = FactoryGirl.create(:ozbkonto_with_ozbperson)
		createdAtOrigin = Time.now
		createdAt = Time.now
		for i in 0..1
			sleep(1.0)
			ozbKontoOrigin.WSaldo +=  1
			ozbKontoOrigin.save!
			createdAt = Time.now
		end
		expect(OzbKonto.where("KtoNr = ?", ozbKontoOrigin.KtoNr).size).to eq 3

		latestOzbKonto = OzbKonto.get(ozbKontoOrigin.KtoNr, createdAtOrigin)

		expect(latestOzbKonto.nil?).to eq false
		expect(latestOzbKonto.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to_not eq createdAt.strftime("%Y-%m-%d %H:%M:%S")
		expect(latestOzbKonto.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq createdAtOrigin.strftime("%Y-%m-%d %H:%M:%S")
	end	

	it "returns nil, if there is no OZBKonto for an invalid Kontonummer" do
		# Test for an invalid Kontonummer
		ozbKontoOrigin = FactoryGirl.create(:ozbkonto_with_ozbperson)
		expect(OzbKonto.get(ozbKontoOrigin.KtoNr + 10, Time.now)).to eq nil

		# create valid ozbkonto, in different versions
		originTime = Time.now
		sleep(1.0)

		ozbKontoOrigin = FactoryGirl.create(:ozbkonto_with_ozbperson)
		createdAtOrigin = Time.now
		createdAt = Time.now
		for i in 0..1
			sleep(1.0)
			ozbKontoOrigin.WSaldo +=  1
			ozbKontoOrigin.save!
			createdAt = Time.now
		end
		expect(OzbKonto.where("KtoNr = ?", ozbKontoOrigin.KtoNr).size).to eq 3

		latestOzbKonto = OzbKonto.get(ozbKontoOrigin.KtoNr, originTime)
		expect(latestOzbKonto.nil?).to eq true
	end

	# self.latest(ktoNr)
	it "returns the latest version of a given OZBKonto, for a valid Kontonummer" do 
		# create valid ozbkonto, in different versions
		ozbKontoOrigin = FactoryGirl.create(:ozbkonto_with_ozbperson)
		createdAtOrigin = Time.now
		createdAt = Time.now
		for i in 0..1
			sleep(1.0)
			ozbKontoOrigin.WSaldo +=  1
			ozbKontoOrigin.save
			createdAt = Time.now
		end
		expect(OzbKonto.where("KtoNr = ?", ozbKontoOrigin.KtoNr).size).to eq 3

		latestOzbKonto = OzbKonto.latest(ozbKontoOrigin.KtoNr)

		expect(latestOzbKonto.nil?).to eq false
		expect(latestOzbKonto.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq createdAt.strftime("%Y-%m-%d %H:%M:%S")
		expect(latestOzbKonto.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to_not eq createdAtOrigin.strftime("%Y-%m-%d %H:%M:%S")
	end

	it "returns nil, if there is no OZBKonto for an invalid Kontonummer" do
		expect(OzbKonto.latest(45)).to eq nil
	end

	# set_wsaldo_psaldo_to_zero (callback methode: before_save)
	it "sets WSaldo and PSaldo to 0, even if they are nil" do 
		ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson)

		ozbKonto.WSaldo = nil
		ozbKonto.PSaldo = nil

		expect(ozbKonto.WSaldo).to eq nil
		expect(ozbKonto.PSaldo).to eq nil

		# Private method, therfore using send methode
		ozbKonto.send(:set_wsaldo_psaldo_to_zero)

		expect(ozbKonto.WSaldo.nil?).to eq false
		expect(ozbKonto.WSaldo).to eq 0

		expect(ozbKonto.PSaldo.nil?).to eq false
		expect(ozbKonto.PSaldo).to eq 0
	end

	it "does not set WSaldo and PSaldo to 0, if they != nil" do 
		ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson, :WSaldo => 42, :PSaldo => 42)

		expect(ozbKonto.WSaldo).to eq 42
		expect(ozbKonto.PSaldo).to eq 42

		# Private method, therfore using send methode
		ozbKonto.send(:set_wsaldo_psaldo_to_zero)

		expect(ozbKonto.WSaldo).to_not eq 0
		expect(ozbKonto.PSaldo).to_not eq 0
	end

	# set_saldo_datum (callback methode: before_save)
	it "sets Saldo Datum to Kontoeinrichtungsdatum, if SaldoDatum is nil" do
		originDate = Time.now
		ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson, :KtoEinrDatum => originDate)
		ozbKonto.SaldoDatum = nil

		expect(ozbKonto.SaldoDatum).to eq nil
		expect(ozbKonto.KtoEinrDatum).to eq originDate

		# Private method, therfore using send methode
		ozbKonto.send(:set_saldo_datum)

		expect(ozbKonto.SaldoDatum).to eq ozbKonto.KtoEinrDatum
	end

	it "does not set Saldo Datum to Kontoeinrichtungsdatum, if SaldoDatum != nil" do
		originDate = Time.now
		sleep(1.0)
		saldoDate = Time.now
		ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson, :KtoEinrDatum => originDate, :SaldoDatum => saldoDate)

		expect(originDate).to_not eq saldoDate
		
		expect(ozbKonto.SaldoDatum.nil?).to eq false
		expect(ozbKonto.SaldoDatum).to eq saldoDate

		# Private method, therfore using send methode
		ozbKonto.send(:set_saldo_datum)

		expect(ozbKonto.SaldoDatum).to eq saldoDate
	end

	# destroy_historic_records (callback methode: after_destroy)
	it "destroys all historic records except himself"

	it "destroys zero records, because there are no historic records"

	# set_assoc_attributes (callback methode: before_save)
	it "sets the value of the SachPnr attribute in the associated EE Konto" 

	it "does not set the value of the SachPnr attribute in the associated EE Konto, if the EE Konto does not exists"

	# set_valid_time (callback methode: before_create)
	it "sets the valid time to GueltigVon = now and GueltigBis = 9999-12-31 23:59:59" do
		ozbPerson = FactoryGirl.create(:ozbperson_with_person)
		sachbearbeiter = FactoryGirl.create(:ozbperson_with_person)
		ozbKonto = FactoryGirl.build(	:ozbkonto_with_ozbperson, :Mnr => ozbPerson.Mnr, 
										:SachPnr => sachbearbeiter.Mnr, :Waehrung => FactoryGirl.create(:Waehrung))
		expect(ozbKonto).to be_valid

		expect(ozbKonto.GueltigVon).to eq nil		
		expect(ozbKonto.GueltigBis).to eq nil

		expect(ozbKonto.save!).to eq true
		expect(ozbKonto.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq Time.now.strftime("%Y-%m-%d %H:%M:%S")
		expect(ozbKonto.GueltigBis.strftime("%Y-%m-%d %H:%M:%S")).to eq "9999-12-31 23:59:59"
	end

	it "does not set the valid time, if it is already set" do
		ozbPerson = FactoryGirl.create(:ozbperson_with_person)
		sachbearbeiter = FactoryGirl.create(:ozbperson_with_person)
		ozbKonto = FactoryGirl.build(	:ozbkonto_with_ozbperson, :Mnr => ozbPerson.Mnr, 
										:SachPnr => sachbearbeiter.Mnr, 
										:GueltigVon => Time.zone.parse("2013-01-01 23:59:59"), :GueltigBis => Time.zone.parse("2013-12-31 23:59:59"),
										:WaehrungID => FactoryGirl.create(:Waehrung))
		expect(ozbKonto).to be_valid

		expect(ozbKonto.GueltigVon).to eq Time.zone.parse("2013-01-01 23:59:59")
		expect(ozbKonto.GueltigBis).to eq Time.zone.parse("2013-12-31 23:59:59")

		expect(ozbKonto.save!).to eq true

		expect(ozbKonto.GueltigVon).to eq Time.zone.parse("2013-01-01 23:59:59")
		expect(ozbKonto.GueltigBis).to eq Time.zone.parse("2013-12-31 23:59:59")		
	end


	# set_new_valid_time (callback methode: before_update)
	it "sets the valid time of the new copy to GueltigVon = self.GueltigVon and GueltigBis = Time.now and updates himself to the latest record" do
		ozbKontoOrigin = FactoryGirl.create(:ozbkonto_with_ozbperson)
		gueltigVon = Time.now
		expect(OzbKonto.where("KtoNr = ?", ozbKontoOrigin.KtoNr).size).to eq 1

		sleep(1.0)

		ozbKontoOrigin.WSaldo += 1
		
		gueltigBis = Time.now
		expect(ozbKontoOrigin.save!).to eq true
		expect(OzbKonto.where("KtoNr = ?", ozbKontoOrigin.KtoNr).size).to eq 2

		oldOzbKonto = OzbKonto.where("KtoNr = ? AND GueltigBis < ?", ozbKontoOrigin.KtoNr, Time.zone.parse("9999-12-31 23:59:59")).first
		expect(oldOzbKonto.nil?).to eq false
		expect(oldOzbKonto.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq gueltigVon.strftime("%Y-%m-%d %H:%M:%S")
		expect(oldOzbKonto.GueltigBis.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq gueltigBis.strftime("%Y-%m-%d %H:%M:%S")
	end

	it "does not set the valid time of the new copy, if the Kontonummer not exists" do
		ozbKontoOrigin = FactoryGirl.create(:ozbkonto_with_ozbperson)
		gueltigVon = Time.now

		expect(OzbKonto.where("KtoNr = ?", ozbKontoOrigin.KtoNr).size).to eq 1

		sleep(1.0)

		ozbKontoOrigin.KtoNr = nil
		ozbKontoOrigin.WSaldo += 1

		# one cannot save an ozbkonto without a valid kontonummer
		expect(ozbKontoOrigin.save).to eq false
	end

	it "does not set the valid time of the new copy, if GuelityBis < 9999-01-01 00:00:00" do 
		ozbKontoOrigin = FactoryGirl.create(:ozbkonto_with_ozbperson)
		gueltigVon = Time.now

		expect(OzbKonto.where("KtoNr = ?", ozbKontoOrigin.KtoNr).size).to eq 1
		expect(ozbKontoOrigin.GueltigBis).to eq Time.zone.parse("9999-12-31 23:59:59")

		sleep(1.0)

		ozbKontoOrigin.GueltigBis = Time.zone.parse("9998-12-31 23:59:59")
		expect(ozbKontoOrigin.save).to eq true

		# change nothing, because one can only modify the latest version
		expect(OzbKonto.where("KtoNr = ?", ozbKontoOrigin.KtoNr).size).to eq 1
		expect(ozbKontoOrigin.GueltigBis).to eq Time.zone.parse("9998-12-31 23:59:59")	
	end
end