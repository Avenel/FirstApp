require 'spec_helper'

describe OzbKonto do

	#Factory
	it "has a valid factory" do
		ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson)
		expect(ozbKonto).to be_valid

		expect(ozbKonto.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq Time.now.strftime("%Y-%m-%d %H:%M:%S")
		expect(ozbKonto.GueltigBis.strftime("%Y-%m-%d %H:%M:%S")).to eq "9999-12-31 23:59:59"
	end

	# Valid/invalid attributes

	# Kontonummer (ktoNr)
	it "is valid with a valid Kontonummer" do
		expect(FactoryGirl.create(:ozbkonto_with_ozbperson, :ktoNr => 51234)).to be_valid
	end

	it "is invalid without a Kontonummer" do 
		expect(FactoryGirl.build(:ozbkonto_with_ozbperson, :ktoNr => nil)).to be_invalid
	end

	it "is invalid with an invalid Kontonummer" do 
		expect(FactoryGirl.build(:ozbkonto_with_ozbperson, :ktoNr => "a1234")).to be_invalid

		expect(FactoryGirl.build(:ozbkonto_with_ozbperson, :ktoNr => 123456)).to be_invalid

		expect(FactoryGirl.build(:ozbkonto_with_ozbperson, :ktoNr => "hellow")).to be_invalid
	end

	# Mitgliedsnummer (mnr)
	it "is valid with a valid Mitgliedsnummer" do
		person = FactoryGirl.create(:Person, :pnr => 42)
		expect(person).to be_valid

		ozbperson = FactoryGirl.create(:OZBPerson, :mnr => 42, :ueberPnr => 42)
		expect(ozbperson).to be_valid

		sachbearbeiter = FactoryGirl.create(:ozbperson_with_person)
		expect(sachbearbeiter).to be_valid

		expect(FactoryGirl.build(:OzbKonto, :mnr => 42, :sachPnr => sachbearbeiter.mnr)).to be_valid
	end

	it "is invalid without a Mitgliedsnummer" do
		expect(FactoryGirl.build(:OzbKonto, :mnr => nil)).to be_invalid
	end

	it "is invalid with an invalid Mitgliedsnummer" do 
		person = FactoryGirl.create(:Person, :pnr => 42)
		expect(person).to be_valid

		ozbperson = FactoryGirl.create(:OZBPerson, :mnr => 42, :ueberPnr => 42)
		expect(ozbperson).to be_valid

		expect(FactoryGirl.build(:OzbKonto, :mnr => 45)).to be_invalid
		expect(FactoryGirl.build(:OzbKonto, :mnr => "as")).to be_invalid
	end


	# Sachbearbeiter Personalnummer (sachPnr)
	it "is valid with a valid Sachbearbeiter Personalnummer" do 
		sachbearbeiter = FactoryGirl.create(:ozbperson_with_person)
		expect(sachbearbeiter).to be_valid

		expect(FactoryGirl.create(:ozbkonto_with_ozbperson, :sachPnr => sachbearbeiter.mnr)).to be_valid		
	end

	# Ist nun der Sachbearbeiter pflicht, oder nicht?
	it "is invalid without a Sachbearbeiter Personalnummer" do 
		expect(FactoryGirl.build(:ozbkonto_with_ozbperson, :sachPnr => nil)).to be_invalid		
	end

	it "is invalid with an invalid Sachbearbeiter Personalnummer" do
		expect(FactoryGirl.build(:ozbkonto_with_ozbperson, :sachPnr => 45)).to be_invalid
		expect(FactoryGirl.build(:ozbkonto_with_ozbperson, :sachPnr => "hello")).to be_invalid
	end

	# Währung
	it "is valid with a valid Waehrung" do
		expect(FactoryGirl.create(:ozbkonto_with_ozbperson, :waehrung => "STR")).to be_valid
	end

	it "is invalid without a Waehrung" do
		expect(FactoryGirl.build(:ozbkonto_with_ozbperson, :waehrung => nil)).to be_invalid
	end

	it "is invalid with an invalid Waehrung" do
		expect(FactoryGirl.build(:ozbkonto_with_ozbperson, :waehrung => "12Asd")).to be_invalid
	end


	# Class and instance methods 

	# ozbperson_exists
	it "returns true if a valid person exists" do
		ozbkonto = FactoryGirl.create(:ozbkonto_with_ozbperson)
		
		ozbperson = FactoryGirl.create(:ozbperson_with_person)
		ozbkonto.mnr = ozbperson.mnr
		
		expect(ozbkonto.ozbperson_exists).to eq true
	end

	it "returns false if an invalid person exists" do
		ozbkonto = FactoryGirl.create(:ozbkonto_with_ozbperson)
		ozbkonto.mnr = 45
		
		expect(ozbkonto.ozbperson_exists).to eq false
	end

	# sachPnr_exists
	it "returns true if a valid sachPnr exists" do
		ozbkonto = FactoryGirl.create(:ozbkonto_with_ozbperson)
		
		ozbperson = FactoryGirl.create(:ozbperson_with_person)
		ozbkonto.sachPnr = ozbperson.mnr
		
		expect(ozbkonto.sachPnr_exists).to eq true
	end

	it "returns false if an invalid sachPnr exists" do
		ozbkonto = FactoryGirl.create(:ozbkonto_with_ozbperson)
		ozbkonto.sachPnr = 45
		
		expect(ozbkonto.sachPnr_exists).to eq false
	end

	# self.get_all_ee_for(mnr)
	it "returns all EE-Konten for a given Mitgliedsnummer"
	it "returns nil for an invalid Mitgliedsnummer"

	# self.get_all_ze_for(mnr)
	it "returns all ZE-Konten for a given Mitgliedsnummer"
	it "returns nil for an invalid Mitgliedsnummer"

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
		expect(OzbKonto.where("KtoNr = ?", ozbKontoOrigin.ktoNr).size).to eq 3

		latestOzbKonto = ozbKontoOrigin.get(ozbKontoOrigin.ktoNr, Time.now)

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
		expect(OzbKonto.where("KtoNr = ?", ozbKontoOrigin.ktoNr).size).to eq 3

		latestOzbKonto = ozbKontoOrigin.get(ozbKontoOrigin.ktoNr, createdAtOrigin)

		expect(latestOzbKonto.nil?).to eq false
		expect(latestOzbKonto.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to_not eq createdAt.strftime("%Y-%m-%d %H:%M:%S")
		expect(latestOzbKonto.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq createdAtOrigin.strftime("%Y-%m-%d %H:%M:%S")
	end	

	it "returns nil, if there is no OZBKonto for a invalid Kontonummer" do
		# Test for an invalid Kontonummer
		ozbKontoOrigin = FactoryGirl.create(:ozbkonto_with_ozbperson)
		expect(ozbKontoOrigin.get(ozbKontoOrigin.ktoNr + 10, Time.now)).to eq nil

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
		expect(OzbKonto.where("KtoNr = ?", ozbKontoOrigin.ktoNr).size).to eq 3

		latestOzbKonto = ozbKontoOrigin.get(ozbKontoOrigin.ktoNr, originTime)
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
		expect(OzbKonto.where("KtoNr = ?", ozbKontoOrigin.ktoNr).size).to eq 3

		latestOzbKonto = OzbKonto.latest(ozbKontoOrigin.ktoNr)

		expect(latestOzbKonto.nil?).to eq false
		expect(latestOzbKonto.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq createdAt.strftime("%Y-%m-%d %H:%M:%S")
		expect(latestOzbKonto.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to_not eq createdAtOrigin.strftime("%Y-%m-%d %H:%M:%S")
	end

	it "returns nil, if there is no OZBKonto for a invalid Kontonummer" do
		expect(OzbKonto.latest(45)).to eq nil
	end


	# self.destroy_yourself_if_you_are_alone(ktoNr)
	it "destroys himself if there is only one record related to a given Kontonummer in the database." do
		aloneOzbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson)
		expect(OzbKonto.where("ktoNr = ?", aloneOzbKonto.ktoNr).size).to eq 1

		OzbKonto.destroy_yourself_if_you_are_alone(aloneOzbKonto.ktoNr)
		expect(OzbKonto.where("ktoNr = ?", aloneOzbKonto.ktoNr).size).to eq 0		
	end

	it "does not break if the given Kontonummer is not valid" do 
		errorCount = 0

		begin 
			OzbKonto.destroy_yourself_if_you_are_alone(45)
		rescue Exception => e
			errorCount += 1
		end

		expect(errorCount).to eq 0
	end

	it "does not destroy himself if there are more than 1 record for the given Kontonummer in the database" 


	# set_wsaldo_psaldo_to_zero
	it "sets WSaldo and PSaldo to 0, even if they are nil" do 
		ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson)

		ozbKonto.wSaldo = nil
		ozbKonto.pSaldo = nil

		expect(ozbKonto.wSaldo).to eq nil
		expect(ozbKonto.pSaldo).to eq nil

		# Private method, therfore using send methode
		ozbKonto.send(:set_wsaldo_psaldo_to_zero)

		expect(ozbKonto.wSaldo.nil?).to eq false
		expect(ozbKonto.wSaldo).to eq 0

		expect(ozbKonto.pSaldo.nil?).to eq false
		expect(ozbKonto.pSaldo).to eq 0
	end

	# set_wsaldo_psaldo_to_zero
	it "does not set WSaldo and PSaldo to 0, if they != nil" do 
		ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson, :wSaldo => 42, :pSaldo => 42)

		expect(ozbKonto.wSaldo).to eq 42
		expect(ozbKonto.pSaldo).to eq 42

		# Private method, therfore using send methode
		ozbKonto.send(:set_wsaldo_psaldo_to_zero)

		expect(ozbKonto.wSaldo).to_not eq 0
		expect(ozbKonto.pSaldo).to_not eq 0
	end

	# set_saldo_datum
	it "sets Saldo Datum to Kontoeinrichtungsdatum, if SaldoDatum is nil" do
		originDate = Time.now
		ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson, :ktoEinrDatum => originDate)
		ozbKonto.saldoDatum = nil

		expect(ozbKonto.saldoDatum).to eq nil
		expect(ozbKonto.ktoEinrDatum).to eq originDate

		# Private method, therfore using send methode
		ozbKonto.send(:set_saldo_datum)

		expect(ozbKonto.saldoDatum).to eq ozbKonto.ktoEinrDatum
	end

	it "does not set Saldo Datum to Kontoeinrichtungsdatum, if SaldoDatum != nil" do
		originDate = Time.now
		sleep(1.0)
		saldoDate = Time.now
		ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson, :ktoEinrDatum => originDate, :saldoDatum => saldoDate)

		expect(originDate).to_not eq saldoDate
		
		expect(ozbKonto.saldoDatum.nil?).to eq false
		expect(ozbKonto.saldoDatum).to eq saldoDate

		# Private method, therfore using send methode
		ozbKonto.send(:set_saldo_datum)

		expect(ozbKonto.saldoDatum).to eq saldoDate
	end

	# destroy_historic_records

	# set_assoc_attributes

	# set_valid_time

	# set_new_valid_time

	# after_update

end