require 'spec_helper'

describe ZeKonto do
	# Factory
	it "has a valid factory" do
		expect(FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe)).to be_valid
	end

	# Valid/invalid attributes
	# KtoNr
	it "is valid with a valid Kontonummer" do
		ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson, :ktoNr => 12345)
		zeKonto = FactoryGirl.create(:zeKonto_with_EEKonto_Projektgruppe, :ktoNr => 12345)
		expect(zeKonto).to be_valid
		expect(zeKonto.ktoNr).to eq 12345
	end

	it "is invalid without a Kontonummer" do 
		zeKonto = FactoryGirl.build(:zeKonto_with_EEKonto_Projektgruppe, :ktoNr => nil)
		expect(zeKonto).to be_invalid
		expect(zeKonto.save).to eq false
	end

	it "is invalid with an invalid Kontonummer" do
		zeKonto = FactoryGirl.build(:zeKonto_with_EEKonto_Projektgruppe, :ktoNr => 45)
		expect(zeKonto).to be_invalid
		expect(zeKonto.save).to eq false
	end

	# Pgnr
	it "is valid with a valid Projektgruppennummer" do
		projektgruppe = FactoryGirl.create(:Projektgruppe, :pgNr => 42)
		expect(Projektgruppe.where("Pgnr = ?", 42).size).to eq 1

		zeKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto, :pgNr => 42)
		expect(zeKonto.pgNr).to eq 42
		expect(zeKonto).to be_valid
	end


	it "is invalid without a Projektgruppennummer" do
		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto, :pgNr => nil)
		expect(zeKonto).to be_invalid
		expect(zeKonto.save).to eq false
	end

	it "is invalid with an invalid Projektgruppennummer" do
		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto, :pgNr => 42)
		expect(zeKonto).to be_invalid
		expect(zeKonto.save).to eq false
	end

	# EEKtoNor
	it "is valid with a valid EEKontonummer" do
		ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson, :ktoNr => 12345)
		bankverbindung = FactoryGirl.create(:bankverbindung_with_bank, :pnr => ozbKonto.mnr)
		eeKonto = FactoryGirl.create(:eekonto_with_sachPerson, :ktoNr => 12345, :bankId => bankverbindung.id)
		zeKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_Projektgruppe, :eeKtoNr => 12345)

		expect(zeKonto).to be_valid
		expect(zeKonto.eeKtoNr).to eq 12345
	end

	it "is invalid without a EEKontonummer" do
		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_Projektgruppe, :eeKtoNr => nil)
		expect(zeKonto).to be_invalid
	end

	it "is invalid with an invalid EEKontonummer" do
		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_Projektgruppe, :eeKtoNr => 45)
		expect(zeKonto).to be_invalid
	end

	# ZENr
	it "is valid with a valid ZENr" do
		zeKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :zeNr => "D1234")
		expect(zeKonto).to be_valid
		expect(zeKonto.zeNr).to eq "D1234"
	end

	it "is invalid without a ZENr" do
		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :zeNr => nil)
		expect(zeKonto).to be_invalid
	end

	it "is invalid with an invalid ZENr" do
		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :zeNr => "D123")
		expect(zeKonto.zeNr).to eq "D123"
		expect(zeKonto).to be_invalid

		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :zeNr => "D12345")
		expect(zeKonto.zeNr).to eq "D12345"
		expect(zeKonto).to be_invalid

		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :zeNr => "12345")
		expect(zeKonto.zeNr).to eq "12345"
		expect(zeKonto).to be_invalid

		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :zeNr => "DDDDD")
		expect(zeKonto.zeNr).to eq "DDDDD"
		expect(zeKonto).to be_invalid
	end

	# Laufzeit
	it "is valid with a valid Laufzeit" do
		zeKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :laufzeit => 42)
		expect(zeKonto).to be_valid
		expect(zeKonto.laufzeit).to eq 42
	end

	it "is invalid without a Laufzeit" do
		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :laufzeit => nil)
		expect(zeKonto).to be_invalid
	end

	it "is invalid with an invalid Laufzeit" do
		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :laufzeit => "A12")
		expect(zeKonto).to be_invalid
	end

	# ZahlModus
	# possible zahlmodi: "M", ???
	it "is valid with a valid ZahlModus" do
		zeKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :zahlModus => "M")
		expect(zeKonto).to be_valid
		expect(zeKonto.zahlModus).to eq "M"
	end

	it "is invalid without a ZahlModus" do
		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :zahlModus => nil)
		expect(zeKonto).to be_invalid
	end

	it "is invalid with an invalid ZahlModus" do
		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :zahlModus => "Z")
		expect(zeKonto).to be_invalid

		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :zahlModus => 12)
		expect(zeKonto).to be_invalid
	end

	# TilgRate
	it "is valid with a valid TilgRate" do
		zeKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :tilgRate => 100.00)
		expect(zeKonto).to be_valid
		expect(zeKonto.tilgRate).to eq 100.00
	end

	it "is invalid without a TilgRate" do
		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :tilgRate => nil)
		expect(zeKonto).to be_invalid
	end

	it "is invalid with an invalid TilgRate" do
		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :tilgRate => 0.00)
		expect(zeKonto).to be_invalid

		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :tilgRate => "AB12")
		expect(zeKonto).to be_invalid
	end

	# NachsparRate
	it "is valid with a valid NachsparRate" do
		zeKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :NachsparRate => 100.00)
		expect(zeKonto).to be_valid
		expect(zeKonto.NachsparRate).to eq 100.00
	end

	it "is invalid without a NachsparRate" do
		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :NachsparRate => nil)
		expect(zeKonto).to be_invalid
	end

	it "is invalid with an invalid NachsparRate" do
		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :NachsparRate => 0.00)
		expect(zeKonto).to be_invalid

		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :NachsparRate => "AB12")
		expect(zeKonto).to be_invalid
	end

	# KDURate
	it "is valid with a valid KDURate" do
		zeKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :kduRate => 10.00)
		expect(zeKonto).to be_valid
		expect(zeKonto.kduRate).to eq 10.00
	end

	it "is invalid without a KDURate" do
		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :kduRate => nil)
		expect(zeKonto).to be_invalid
	end

	it "is invalid with an invalid KDURate" do
		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :kduRate => 0.00)
		expect(zeKonto).to be_invalid

		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :kduRate => "AB12")
		expect(zeKonto).to be_invalid
	end

	# RDURate
	it "is valid with a valid RDURate" do
		zeKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :rduRate => 10.00)
		expect(zeKonto).to be_valid
		expect(zeKonto.rduRate).to eq 10.00
	end

	it "is invalid without a RDURate" do
		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :rduRate => nil)
		expect(zeKonto).to be_invalid
	end

	it "is invalid with an invalid RDURate" do
		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :rduRate => 0.00)
		expect(zeKonto).to be_invalid

		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :rduRate => "AB12")
		expect(zeKonto).to be_invalid
	end

	# ZEStatus
	# possible values = {N, D, A}
	it "is valid with a valid ZEStatus" do
		zeKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :zeStatus => "N")
		expect(zeKonto).to be_valid
		expect(zeKonto.zeStatus).to eq "N"

		zeKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :zeStatus => "D")
		expect(zeKonto).to be_valid
		expect(zeKonto.zeStatus).to eq "D"

		zeKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :zeStatus => "A")
		expect(zeKonto).to be_valid
		expect(zeKonto.zeStatus).to eq "A"
	end

	it "is invalid without a ZEStatus" do
		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :zeStatus => nil)
		expect(zeKonto).to be_invalid
	end

	it "is invalid with an invalid ZEStatus" do
		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :zeStatus => "X")
		expect(zeKonto).to be_invalid

		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :zeStatus => "AA")
		expect(zeKonto).to be_invalid

		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :zeStatus => "NN")
		expect(zeKonto).to be_invalid

		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :zeStatus => "DD")
		expect(zeKonto).to be_invalid

		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :zeStatus => "n")
		expect(zeKonto).to be_invalid

		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :zeStatus => "d")
		expect(zeKonto).to be_invalid

		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :zeStatus => "a")
		expect(zeKonto).to be_invalid
	end

	# SachPnr
	it "is valid with a valid SachPnr" do
		sachPerson = FactoryGirl.create(:ozbperson_with_person)
		expect(sachPerson).to be_valid

		expect(FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :sachPnr => sachPerson.mnr)).to be_valid
	end

	it "is valid without a SachPnr" do
		expect(FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :sachPnr => nil)).to be_valid
	end

	it "is invalid with an invalid SachPnr" do
		expect(FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :sachPnr => 45)).to be_invalid
	end

	# Class and instance methods
	# kto_exists
	it "returns true, if the OZBKonto for a given Kontonummer exists" do
		ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson, :ktoNr => 12345)
		zeKonto = FactoryGirl.create(:zeKonto_with_EEKonto_Projektgruppe, :ktoNr => 12345)
		expect(zeKonto).to be_valid
		expect(zeKonto.ktoNr).to eq 12345

		expect(zeKonto.kto_exists).to eq true
	end

	it "returns false, if the OZBKonto for a given Kontonummer does not exist" do
		ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson, :ktoNr => 12345)
		zeKonto = FactoryGirl.create(:zeKonto_with_EEKonto_Projektgruppe, :ktoNr => 12345)
		expect(zeKonto).to be_valid
		expect(zeKonto.ktoNr).to eq 12345

		# nil 
		zeKonto.ktoNr = nil
		expect(zeKonto.kto_exists).to eq false

		# not existing kto
		zeKonto.ktoNr = 45
		expect(zeKonto.kto_exists).to eq false

		zeKonto.ktoNr = 54321
		expect(zeKonto.kto_exists).to eq false
	end

	# eeKonto_exists
	it "returns true, if the EEKonto for a given EEKontonummer exists" do
		ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson, :ktoNr => 12345)
		bankverbindung = FactoryGirl.create(:bankverbindung_with_bank, :pnr => ozbKonto.mnr)
		eeKonto = FactoryGirl.create(:eekonto_with_sachPerson, :ktoNr => 12345, :bankId => bankverbindung.id)
		zeKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_Projektgruppe, :eeKtoNr => 12345)

		expect(zeKonto).to be_valid
		expect(zeKonto.eeKtoNr).to eq 12345

		expect(zeKonto.eeKonto_exists).to eq true
	end


	it "returns false, if the EEKonto for a given EEKontonummer does not exist" do
		ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson, :ktoNr => 12345)
		bankverbindung = FactoryGirl.create(:bankverbindung_with_bank, :pnr => ozbKonto.mnr)
		eeKonto = FactoryGirl.create(:eekonto_with_sachPerson, :ktoNr => 12345, :bankId => bankverbindung.id)
		zeKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_Projektgruppe, :eeKtoNr => 12345)

		expect(zeKonto).to be_valid
		expect(zeKonto.eeKtoNr).to eq 12345

		# nil 
		zeKonto.eeKtoNr = nil
		expect(zeKonto.eeKonto_exists).to eq false

		# not existing kto
		zeKonto.eeKtoNr = 45
		expect(zeKonto.eeKonto_exists).to eq false

		zeKonto.eeKtoNr = 54321
		expect(zeKonto.eeKonto_exists).to eq false
	end

	# sachPnr_exists
	it "returns true, if a valid sachPnr exists" do
		sachPerson = FactoryGirl.create(:ozbperson_with_person)
		expect(sachPerson).to be_valid

		zeKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :sachPnr => sachPerson.mnr)

		expect(zeKonto.sachPnr_exists).to eq true
	end

	it "returns true, if none sachPnr is given" do
		zeKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :sachPnr => nil)

		expect(zeKonto.sachPnr_exists).to eq true
	end

	it "returns false, if an invalid sachPnr is given" do
		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :sachPnr => 45)

		expect(zeKonto.sachPnr_exists).to eq false
	end

	# set_valid_time (callback methode: before_create)
	it "sets the valid time to GueltigVon = now and GueltigBis = 9999-12-31 23:59:59" do
		ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson, :ktoNr => 12345)
		bankverbindung = FactoryGirl.create(:bankverbindung_with_bank, :pnr => ozbKonto.mnr)
		eeKonto = FactoryGirl.create(:eekonto_with_sachPerson, :ktoNr => 12345, :bankId => bankverbindung.id)

		ozbKontoZE = FactoryGirl.create(:ozbkonto_with_ozbperson, :ktoNr => 54321)

		projektgruppe = FactoryGirl.create(:Projektgruppe, :pgNr => 42)

		zeKonto = FactoryGirl.build(:ZeKonto, :ktoNr => 54321, :eeKtoNr => 12345, :pgNr => 42)
		expect(zeKonto).to be_valid

		expect(zeKonto.GueltigVon).to eq nil		
		expect(zeKonto.GueltigBis).to eq nil

		expect(zeKonto.save!).to eq true
		expect(zeKonto.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq Time.now.strftime("%Y-%m-%d %H:%M:%S")
		expect(zeKonto.GueltigBis.strftime("%Y-%m-%d %H:%M:%S")).to eq "9999-12-31 23:59:59"
	end

	it "does not set the valid time, if it is already set" do
		ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson, :ktoNr => 12345)
		bankverbindung = FactoryGirl.create(:bankverbindung_with_bank, :pnr => ozbKonto.mnr)
		eeKonto = FactoryGirl.create(:eekonto_with_sachPerson, :ktoNr => 12345, :bankId => bankverbindung.id)

		ozbKontoZE = FactoryGirl.create(:ozbkonto_with_ozbperson, :ktoNr => 54321)

		projektgruppe = FactoryGirl.create(:Projektgruppe, :pgNr => 42)

		zeKonto = FactoryGirl.build(	:ZeKonto, :ktoNr => 54321, :eeKtoNr => 12345, :pgNr => 42, 
										:GueltigVon => Time.zone.parse("2013-01-01 23:59:59"), 
										:GueltigBis => Time.zone.parse("2013-12-31 23:59:59"))
		expect(zeKonto).to be_valid

		expect(zeKonto.GueltigVon).to eq Time.zone.parse("2013-01-01 23:59:59")
		expect(zeKonto.GueltigBis).to eq Time.zone.parse("2013-12-31 23:59:59")

		expect(zeKonto.save!).to eq true

		expect(zeKonto.GueltigVon).to eq Time.zone.parse("2013-01-01 23:59:59")
		expect(zeKonto.GueltigBis).to eq Time.zone.parse("2013-12-31 23:59:59")
	end

	# set_new_valid_time (callback methode: before_update)
	it "sets the valid time of the new copy to GueltigVon = self.GueltigVon and GueltigBis = Time.now and updates himself to the latest record" do
		originZEKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe)
		gueltigVon = Time.now

		expect(ZeKonto.where("KtoNr = ?", originZEKonto.ktoNr).size).to eq 1

		sleep(1.0)

		originZEKonto.laufzeit += 1

		gueltigBis = Time.now
		expect(originZEKonto.save!).to eq true
		expect(ZeKonto.where("KtoNr = ?", originZEKonto.ktoNr).size).to eq 2

		oldZEKonto = ZeKonto.where("KtoNr = ? AND GueltigBis < ?", originZEKonto.ktoNr, Time.zone.parse("9999-12-31 23:59:59")).first
		expect(oldZEKonto.nil?).to eq false
		expect(oldZEKonto.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq gueltigVon.strftime("%Y-%m-%d %H:%M:%S")
		expect(oldZEKonto.GueltigBis.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq gueltigBis.strftime("%Y-%m-%d %H:%M:%S")
	end

	it "does not set the valid time of the new copy, if GuelityBis < 9999-01-01 00:00:00" do
		originZEKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe)
		gueltigVon = Time.now

		expect(ZeKonto.where("KtoNr = ?", originZEKonto.ktoNr).size).to eq 1

		expect(originZEKonto.GueltigBis).to eq Time.zone.parse("9999-12-31 23:59:59")

		sleep(1.0)

		originZEKonto.GueltigBis = Time.zone.parse("9998-12-31 23:59:59")
		expect(originZEKonto.save).to eq true

		# change nothing, because one can only modify the latest version
		expect(ZeKonto.where("KtoNr = ?", originZEKonto.ktoNr).size).to eq 1
		expect(originZEKonto.GueltigBis).to eq Time.zone.parse("9998-12-31 23:59:59")
	end

	it "does not set the valid time of the new copy, if the Kontonummer not exists" do
		originZEKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe)
		gueltigVon = Time.now

		expect(ZeKonto.where("KtoNr = ?", originZEKonto.ktoNr).size).to eq 1

		sleep(1.0)

		originZEKonto.ktoNr = nil
		originZEKonto.laufzeit += 1

		# one cannot save an zekonto without a valid kontonummer
		expect(originZEKonto.save).to eq false
	end


	# get(ktoNr, date = Time.now)
	it "returns the ZEKonto for a valid Kontonummer and date (=now)" do
		# create valid eeKonto, in different versions
		originZEKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe)
		createdAtOrigin = Time.now
		createdAt = Time.now
		for i in 0..1
			sleep(1.0)
			originZEKonto.laufzeit +=  1
			originZEKonto.save!
			createdAt = Time.now
		end
		expect(ZeKonto.where("KtoNr = ?", originZEKonto.ktoNr).size).to eq 3

		latestZEKonto = originZEKonto.get(originZEKonto.ktoNr, Time.now)

		expect(latestZEKonto.nil?).to eq false
		expect(latestZEKonto.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq createdAt.strftime("%Y-%m-%d %H:%M:%S")
		expect(latestZEKonto.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to_not eq createdAtOrigin.strftime("%Y-%m-%d %H:%M:%S")
	end

	it "returns the ZEKonto for a valid Kontonummer and date (=now - 2 seconds)" do
		# create valid eeKonto, in different versions
		originZEKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe)
		createdAtOrigin = Time.now
		createdAt = Time.now
		for i in 0..1
			sleep(1.0)
			originZEKonto.laufzeit +=  1
			originZEKonto.save!
			createdAt = Time.now
		end
		expect(ZeKonto.where("KtoNr = ?", originZEKonto.ktoNr).size).to eq 3

		latestZEKonto = originZEKonto.get(originZEKonto.ktoNr, createdAtOrigin)
		expect(latestZEKonto.nil?).to eq false
		expect(latestZEKonto.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to_not eq createdAt.strftime("%Y-%m-%d %H:%M:%S")
		expect(latestZEKonto.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq createdAtOrigin.strftime("%Y-%m-%d %H:%M:%S")
	end

	it "returns nil, if there is no ZEKonto for an invalid Kontonummer or date" do
		# Test for an invalid Kontonummer
		originZEKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe)
		expect(originZEKonto.get(originZEKonto.ktoNr + 10, Time.now)).to eq nil

		# create valid eekonto, in different versions
		originTime = Time.now
		sleep(1.0)

		originZEKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe)
		createdAtOrigin = Time.now
		createdAt = Time.now
		for i in 0..1
			sleep(1.0)
			originZEKonto.laufzeit +=  1
			originZEKonto.save!
			createdAt = Time.now
		end
		expect(ZeKonto.where("KtoNr = ?", originZEKonto.ktoNr).size).to eq 3

		latestZEKonto = originZEKonto.get(originZEKonto.ktoNr, originTime)
		expect(latestZEKonto.nil?).to eq true
	end

	# self.latest(ktoNr)
	it "returns the latest version of a given ZEKonto, for a valid Kontonummer" do
		# create valid eeKonto, in different versions
		originZEKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe)
		createdAtOrigin = Time.now
		createdAt = Time.now
		for i in 0..1
			sleep(1.0)
			originZEKonto.laufzeit +=  1
			originZEKonto.save!
			createdAt = Time.now
		end
		expect(ZeKonto.where("KtoNr = ?", originZEKonto.ktoNr).size).to eq 3

		latestZEKonto = ZeKonto.latest(originZEKonto.ktoNr)

		expect(latestZEKonto.nil?).to eq false
		expect(latestZEKonto.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq createdAt.strftime("%Y-%m-%d %H:%M:%S")
		expect(latestZEKonto.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to_not eq createdAtOrigin.strftime("%Y-%m-%d %H:%M:%S")
	end

	it "returns nil, if there is no ZEKonto for an invalid Kontonummer" do
		expect(ZeKonto.latest(45)).to eq nil
	end

	# self.latest_all_for(mnr)
	it "returns all ZEKonten for a given valid OZBPerson" do
		ozbPerson = FactoryGirl.create(:ozbperson_with_person)
		pnr = ozbPerson.ueberPnr

		sachPerson = FactoryGirl.create(:ozbperson_with_person)
		sachPnr = sachPerson.ueberPnr
		
		expect(OZBPerson.where("Mnr = ?", pnr).size).to eq 1
		expect(OZBPerson.where("Mnr = ?", sachPnr).size).to eq 1

		ozbKonto1 = FactoryGirl.create(:OzbKonto, :ktoNr => 12345, :mnr => pnr, :sachPnr => sachPnr)
		zeKonto1 = FactoryGirl.create(:zeKonto_with_EEKonto_Projektgruppe, :ktoNr => 12345)
		expect(zeKonto1).to be_valid

		ozbKonto2 = FactoryGirl.create(:OzbKonto, :ktoNr => 54321, :mnr => pnr, :sachPnr => sachPnr)
		zeKonto2 = FactoryGirl.create(:zeKonto_with_EEKonto_Projektgruppe, :ktoNr => 54321)
		expect(zeKonto2).to be_valid

		ozbKonto3 = FactoryGirl.create(:OzbKonto, :ktoNr => 13254, :mnr => pnr, :sachPnr => sachPnr)
		zeKonto3 = FactoryGirl.create(:zeKonto_with_EEKonto_Projektgruppe, :ktoNr => 13254)		
		expect(zeKonto3).to be_valid

		sleep(1.0)
		zeKonto3.laufzeit += 1
		expect(zeKonto3.save).to eq true

		expect(ZeKonto.find(:all).size).to eq 4

		expect(ZeKonto.latest_all_for(pnr).size).to eq 3
	end

	it "returns none ZEKonten for a given valid OZBPerson, if there are not any" do
		ozbPerson = FactoryGirl.create(:ozbperson_with_person)
		pnr = ozbPerson.ueberPnr

		expect(OZBPerson.where("Mnr = ?", pnr).size).to eq 1

		expect(ZeKonto.latest_all_for(pnr).size).to eq 0
	end

	it "returns nil for a given invalid OZBPerson" do
		expect(ZeKonto.latest_all_for(45).size).to eq 0
	end


	# destroy_historic_records
	it "destroys all historic records except himself" do
		originZEKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe)
		createdAtOrigin = Time.now
		createdAt = Time.now
		for i in 0..1
			sleep(1.0)
			originZEKonto.laufzeit +=  1
			originZEKonto.save!
			createdAt = Time.now
		end
		expect(ZeKonto.where("KtoNr = ?", originZEKonto.ktoNr).size).to eq 3

		# Private method, therfore using send methode
		originZEKonto.send(:destroy_historic_records)

		expect(ZeKonto.where("KtoNr = ?", originZEKonto.ktoNr).size).to eq 1
	end
		
	it "destroys zero records, because there are no historic records" do
		# non-existing eekonto
  		expect(ZeKonto.where("KtoNr = ?", 42).size).to eq 0

  		# create one zekonto
		ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson, :ktoNr => 12345)
		bankverbindung = FactoryGirl.create(:bankverbindung_with_bank, :pnr => ozbKonto.mnr)
		eeKonto = FactoryGirl.create(:eekonto_with_sachPerson, :ktoNr => 12345, :bankId => bankverbindung.id)

		ozbKontoZE = FactoryGirl.create(:ozbkonto_with_ozbperson, :ktoNr => 54321)

		projektgruppe = FactoryGirl.create(:Projektgruppe, :pgNr => 42)

		zeKontoOrigin = FactoryGirl.create(:ZeKonto, :ktoNr => 54321, :eeKtoNr => 12345, :pgNr => 42)
		expect(zeKontoOrigin).to be_valid

		expect(zeKontoOrigin.ktoNr).to eq 54321
		expect(ZeKonto.where("KtoNr = ?", zeKontoOrigin.ktoNr).size).to eq 1

		# Private method, therfore using send methode
		zeKontoOrigin.send(:destroy_historic_records)

		expect(ZeKonto.where("KtoNr = ?", zeKontoOrigin.ktoNr).size).to eq 1
	end

	# destroy_ozb_konto_if_this_is_last_konto
	it "destroys the related ozbKonto, if there are no other historic versions of this record exists" do
		originZEKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe)
  		expect(originZEKonto).to be_valid
  		expect(ZeKonto.where("KtoNr = ?", originZEKonto.ktoNr).size).to eq 1

  		ozbKonto = OzbKonto.where("KtoNr = ?", originZEKonto.ktoNr).first
  		expect(ozbKonto.nil?).to eq false

  		ktoNr = originZEKonto.ktoNr

  		originZEKonto.destroy
		expect(ZeKonto.where("KtoNr = ?", ktoNr).size).to eq 0
		expect(OzbKonto.where("KtoNr = ?", ktoNr).size).to eq 0
	end

	it "does not destroy the related ozbKonto, if there are other historic versions of this record" do
		originZEKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe)
		createdAtOrigin = Time.now
  		expect(originZEKonto).to be_valid

  		expect(ZeKonto.where("KtoNr = ?", originZEKonto.ktoNr).size).to eq 1

  		ozbKonto = OzbKonto.where("KtoNr = ?", originZEKonto.ktoNr).first
  		expect(ozbKonto.nil?).to eq false

  		ktoNr = originZEKonto.ktoNr

  		# create more than one version of this record
  		for i in 0..1
			sleep(1.0)
			originZEKonto.laufzeit +=  1
			originZEKonto.save!
			createdAt = Time.now
		end
		expect(ZeKonto.where("KtoNr = ?", originZEKonto.ktoNr).size).to eq 3

		# delete the first record
		zeKontoToDelete = originZEKonto.get(ktoNr, createdAtOrigin)
		expect(zeKontoToDelete.nil?).to eq false

		zeKontoToDelete.destroy
		expect(ZeKonto.where("KtoNr = ?", ktoNr).size).to eq 2
		expect(OzbKonto.where("KtoNr = ?", ktoNr).size).to eq 1
	end

end