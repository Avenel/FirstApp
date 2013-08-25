require 'spec_helper'

describe ZeKonto do
	# Factory
	it "has a valid factory" do
		expect(FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe)).to be_valid
	end

	# Valid/invalid attributes
	# KtoNr
	it "is valid with a valid Kontonummer" do
		ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson, :KtoNr => 12345)
		zeKonto = FactoryGirl.create(:zeKonto_with_EEKonto_Projektgruppe, :KtoNr => 12345)
		expect(zeKonto).to be_valid
		expect(zeKonto.KtoNr).to eq 12345
	end

	it "is invalid without a Kontonummer" do 
		zeKonto = FactoryGirl.build(:zeKonto_with_EEKonto_Projektgruppe, :KtoNr => nil)
		expect(zeKonto).to be_invalid
		expect(zeKonto.save).to eq false
	end

	it "is invalid with an invalid Kontonummer" do
		zeKonto = FactoryGirl.build(:zeKonto_with_EEKonto_Projektgruppe, :KtoNr => 45)
		expect(zeKonto).to be_invalid
		expect(zeKonto.save).to eq false
	end

	# Pgnr
	it "is valid with a valid Projektgruppennummer" do
		projektgruppe = FactoryGirl.create(:Projektgruppe, :Pgnr => 42)
		expect(Projektgruppe.where("Pgnr = ?", 42).size).to eq 1

		zeKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto, :Pgnr => 42)
		expect(zeKonto.Pgnr).to eq 42
		expect(zeKonto).to be_valid
	end


	it "is invalid without a Projektgruppennummer" do
		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto, :Pgnr => nil)
		expect(zeKonto).to be_invalid
		expect(zeKonto.save).to eq false
	end

	it "is invalid with an invalid Projektgruppennummer" do
		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto, :Pgnr => 42)
		expect(zeKonto).to be_invalid
		expect(zeKonto.save).to eq false
	end

	# EEKtoNor
	it "is valid with a valid EEKontonummer" do
		ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson, :KtoNr => 12345)
		bankverbindung = FactoryGirl.create(:bankverbindung_with_bank, :Pnr => ozbKonto.Mnr)
		eeKonto = FactoryGirl.create(:eekonto_with_sachPerson, :KtoNr => 12345, :BankID => bankverbindung.ID)
		zeKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_Projektgruppe, :EEKtoNr => 12345)

		expect(zeKonto).to be_valid
		expect(zeKonto.EEKtoNr).to eq 12345
	end

	it "is invalid without a EEKontonummer" do
		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_Projektgruppe, :EEKtoNr => nil)
		expect(zeKonto).to be_invalid
	end

	it "is invalid with an invalid EEKontonummer" do
		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_Projektgruppe, :EEKtoNr => 45)
		expect(zeKonto).to be_invalid
	end

	# ZENr
	it "is valid with a valid ZENr" do
		zeKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :ZENr => "D1234")
		expect(zeKonto).to be_valid
		expect(zeKonto.ZENr).to eq "D1234"
	end

	it "is invalid without a ZENr" do
		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :ZENr => nil)
		expect(zeKonto).to be_invalid
	end

	it "is invalid with an invalid ZENr" do
		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :ZENr => "D123")
		expect(zeKonto.ZENr).to eq "D123"
		expect(zeKonto).to be_invalid

		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :ZENr => "D12345")
		expect(zeKonto.ZENr).to eq "D12345"
		expect(zeKonto).to be_invalid

		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :ZENr => "12345")
		expect(zeKonto.ZENr).to eq "12345"
		expect(zeKonto).to be_invalid

		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :ZENr => "DDDDD")
		expect(zeKonto.ZENr).to eq "DDDDD"
		expect(zeKonto).to be_invalid
	end

	# Laufzeit
	it "is valid with a valid Laufzeit" do
		zeKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :Laufzeit => 42)
		expect(zeKonto).to be_valid
		expect(zeKonto.Laufzeit).to eq 42
	end

	it "is invalid without a Laufzeit" do
		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :Laufzeit => nil)
		expect(zeKonto).to be_invalid
	end

	it "is invalid with an invalid Laufzeit" do
		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :Laufzeit => "A12")
		expect(zeKonto).to be_invalid
	end

	# ZahlModus
	# possible zahlmodi: "M", ???
	it "is valid with a valid ZahlModus" do
		zeKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :ZahlModus => "m")
		expect(zeKonto).to be_valid
		expect(zeKonto.ZahlModus).to eq "m"
	end

	it "is invalid without a ZahlModus" do
		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :ZahlModus => nil)
		expect(zeKonto).to be_invalid
	end

	it "is invalid with an invalid ZahlModus" do
		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :ZahlModus => "Z")
		expect(zeKonto).to be_invalid

		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :ZahlModus => 12)
		expect(zeKonto).to be_invalid
	end

	# TilgRate
	it "is valid with a valid TilgRate" do
		zeKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :TilgRate => 100.00)
		expect(zeKonto).to be_valid
		expect(zeKonto.TilgRate).to eq 100.00
	end

	it "is invalid without a TilgRate" do
		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :TilgRate => nil)
		expect(zeKonto).to be_invalid
	end

	it "is invalid with an invalid TilgRate" do
		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :TilgRate => 0.00)
		expect(zeKonto).to be_invalid

		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :TilgRate => "AB12")
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
		zeKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :KDURate => 10.00)
		expect(zeKonto).to be_valid
		expect(zeKonto.KDURate).to eq 10.00
	end

	it "is invalid without a KDURate" do
		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :KDURate => nil)
		expect(zeKonto).to be_invalid
	end

	it "is invalid with an invalid KDURate" do
		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :KDURate => 0.00)
		expect(zeKonto).to be_invalid

		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :KDURate => "AB12")
		expect(zeKonto).to be_invalid
	end

	# RDURate
	it "is valid with a valid RDURate" do
		zeKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :RDURate => 10.00)
		expect(zeKonto).to be_valid
		expect(zeKonto.RDURate).to eq 10.00
	end

	it "is invalid without a RDURate" do
		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :RDURate => nil)
		expect(zeKonto).to be_invalid
	end

	it "is invalid with an invalid RDURate" do
		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :RDURate => 0.00)
		expect(zeKonto).to be_invalid

		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :RDURate => "AB12")
		expect(zeKonto).to be_invalid
	end

	# ZEStatus
	# possible values = {a, e, u}
	it "is valid with a valid ZEStatus" do
		zeKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :ZEStatus => "a")
		expect(zeKonto).to be_valid
		expect(zeKonto.ZEStatus).to eq "a"

		zeKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :ZEStatus => "e")
		expect(zeKonto).to be_valid
		expect(zeKonto.ZEStatus).to eq "e"

		zeKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :ZEStatus => "u")
		expect(zeKonto).to be_valid
		expect(zeKonto.ZEStatus).to eq "u"
	end

	it "is invalid without a ZEStatus" do
		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :ZEStatus => nil)
		expect(zeKonto).to be_invalid
	end

	it "is invalid with an invalid ZEStatus" do
		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :ZEStatus => "X")
		expect(zeKonto).to be_invalid

		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :ZEStatus => "AA")
		expect(zeKonto).to be_invalid

		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :ZEStatus => "NN")
		expect(zeKonto).to be_invalid

		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :ZEStatus => "DD")
		expect(zeKonto).to be_invalid

		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :ZEStatus => "n")
		expect(zeKonto).to be_invalid

		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :ZEStatus => "d")
		expect(zeKonto).to be_invalid

		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :ZEStatus => "a")
		expect(zeKonto).to be_invalid
	end

	# SachPnr
	it "is valid with a valid SachPnr" do
		sachPerson = FactoryGirl.create(:ozbperson_with_person)
		expect(sachPerson).to be_valid

		expect(FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :SachPnr => sachPerson.Mnr)).to be_valid
	end

	it "is valid without a SachPnr" do
		expect(FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :SachPnr => nil)).to be_valid
	end

	it "is invalid with an invalid SachPnr" do
		expect(FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :SachPnr => 45)).to be_invalid
	end

	# Class and instance methods
	# kto_exists
	it "returns true, if the OZBKonto for a given Kontonummer exists" do
		ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson, :KtoNr => 12345)
		zeKonto = FactoryGirl.create(:zeKonto_with_EEKonto_Projektgruppe, :KtoNr => 12345)
		expect(zeKonto).to be_valid
		expect(zeKonto.KtoNr).to eq 12345

		expect(zeKonto.kto_exists).to eq true
	end

	it "returns false, if the OZBKonto for a given Kontonummer does not exist" do
		ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson, :KtoNr => 12345)
		zeKonto = FactoryGirl.create(:zeKonto_with_EEKonto_Projektgruppe, :KtoNr => 12345)
		expect(zeKonto).to be_valid
		expect(zeKonto.KtoNr).to eq 12345

		# nil 
		zeKonto.KtoNr = nil
		expect(zeKonto.kto_exists).to eq false

		# not existing kto
		zeKonto.KtoNr = 45
		expect(zeKonto.kto_exists).to eq false

		zeKonto.KtoNr = 54321
		expect(zeKonto.kto_exists).to eq false
	end

	# eeKonto_exists
	it "returns true, if the EEKonto for a given EEKontonummer exists" do
		ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson, :KtoNr => 12345)
		bankverbindung = FactoryGirl.create(:bankverbindung_with_bank, :Pnr => ozbKonto.Mnr)
		eeKonto = FactoryGirl.create(:eekonto_with_sachPerson, :KtoNr => 12345, :BankID => bankverbindung.ID)
		zeKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_Projektgruppe, :EEKtoNr => 12345)

		expect(zeKonto).to be_valid
		expect(zeKonto.EEKtoNr).to eq 12345

		expect(zeKonto.eeKonto_exists).to eq true
	end


	it "returns false, if the EEKonto for a given EEKontonummer does not exist" do
		ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson, :KtoNr => 12345)
		bankverbindung = FactoryGirl.create(:bankverbindung_with_bank, :Pnr => ozbKonto.Mnr)
		eeKonto = FactoryGirl.create(:eekonto_with_sachPerson, :KtoNr => 12345, :BankID => bankverbindung.ID)
		zeKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_Projektgruppe, :EEKtoNr => 12345)

		expect(zeKonto).to be_valid
		expect(zeKonto.EEKtoNr).to eq 12345

		# nil 
		zeKonto.EEKtoNr = nil
		expect(zeKonto.eeKonto_exists).to eq false

		# not existing kto
		zeKonto.EEKtoNr = 45
		expect(zeKonto.eeKonto_exists).to eq false

		zeKonto.EEKtoNr = 54321
		expect(zeKonto.eeKonto_exists).to eq false
	end

	# sachPnr_exists
	it "returns true, if a valid sachPnr exists" do
		sachPerson = FactoryGirl.create(:ozbperson_with_person)
		expect(sachPerson).to be_valid

		zeKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :SachPnr => sachPerson.Mnr)

		expect(zeKonto.sachPnr_exists).to eq true
	end

	it "returns true, if none sachPnr is given" do
		zeKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :SachPnr => nil)

		expect(zeKonto.sachPnr_exists).to eq true
	end

	it "returns false, if an invalid sachPnr is given" do
		zeKonto = FactoryGirl.build(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe, :SachPnr => 45)

		expect(zeKonto.sachPnr_exists).to eq false
	end

	# set_valid_time (callback methode: before_create)
	it "sets the valid time to GueltigVon = now and GueltigBis = 9999-12-31 23:59:59" do
		ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson, :KtoNr => 12345)
		bankverbindung = FactoryGirl.create(:bankverbindung_with_bank, :Pnr => ozbKonto.Mnr)
		eeKonto = FactoryGirl.create(:eekonto_with_sachPerson, :KtoNr => 12345, :BankID => bankverbindung.ID)

		ozbKontoZE = FactoryGirl.create(:ozbkonto_with_ozbperson, :KtoNr => 54321)

		projektgruppe = FactoryGirl.create(:Projektgruppe, :Pgnr => 42)

		zeKonto = FactoryGirl.build(:ZeKonto, :KtoNr => 54321, :EEKtoNr => 12345, :Pgnr => 42)
		expect(zeKonto).to be_valid

		expect(zeKonto.GueltigVon).to eq nil		
		expect(zeKonto.GueltigBis).to eq nil

		expect(zeKonto.save!).to eq true
		expect(zeKonto.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq Time.now.strftime("%Y-%m-%d %H:%M:%S")
		expect(zeKonto.GueltigBis.strftime("%Y-%m-%d %H:%M:%S")).to eq "9999-12-31 23:59:59"
	end

	it "does not set the valid time, if it is already set" do
		ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson, :KtoNr => 12345)
		bankverbindung = FactoryGirl.create(:bankverbindung_with_bank, :Pnr => ozbKonto.Mnr)
		eeKonto = FactoryGirl.create(:eekonto_with_sachPerson, :KtoNr => 12345, :BankID => bankverbindung.ID)

		ozbKontoZE = FactoryGirl.create(:ozbkonto_with_ozbperson, :KtoNr => 54321)

		projektgruppe = FactoryGirl.create(:Projektgruppe, :Pgnr => 42)

		zeKonto = FactoryGirl.build(	:ZeKonto, :KtoNr => 54321, :EEKtoNr => 12345, :Pgnr => 42, 
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

		expect(ZeKonto.where("KtoNr = ?", originZEKonto.KtoNr).size).to eq 1

		sleep(1.0)

		originZEKonto.Laufzeit += 1

		gueltigBis = Time.now
		expect(originZEKonto.save!).to eq true
		expect(ZeKonto.where("KtoNr = ?", originZEKonto.KtoNr).size).to eq 2

		oldZEKonto = ZeKonto.where("KtoNr = ? AND GueltigBis < ?", originZEKonto.KtoNr, Time.zone.parse("9999-12-31 23:59:59")).first
		expect(oldZEKonto.nil?).to eq false
		expect(oldZEKonto.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq gueltigVon.strftime("%Y-%m-%d %H:%M:%S")
		expect(oldZEKonto.GueltigBis.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq gueltigBis.strftime("%Y-%m-%d %H:%M:%S")
	end

	it "does not set the valid time of the new copy, if GuelityBis < 9999-01-01 00:00:00" do
		originZEKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe)
		gueltigVon = Time.now

		expect(ZeKonto.where("KtoNr = ?", originZEKonto.KtoNr).size).to eq 1

		expect(originZEKonto.GueltigBis).to eq Time.zone.parse("9999-12-31 23:59:59")

		sleep(1.0)

		originZEKonto.GueltigBis = Time.zone.parse("9998-12-31 23:59:59")
		expect(originZEKonto.save).to eq true

		# change nothing, because one can only modify the latest version
		expect(ZeKonto.where("KtoNr = ?", originZEKonto.KtoNr).size).to eq 1
		expect(originZEKonto.GueltigBis).to eq Time.zone.parse("9998-12-31 23:59:59")
	end

	it "does not set the valid time of the new copy, if the Kontonummer not exists" do
		originZEKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe)
		gueltigVon = Time.now

		expect(ZeKonto.where("KtoNr = ?", originZEKonto.KtoNr).size).to eq 1

		sleep(1.0)

		originZEKonto.KtoNr = nil
		originZEKonto.Laufzeit += 1

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
			originZEKonto.Laufzeit +=  1
			originZEKonto.save!
			createdAt = Time.now
		end
		expect(ZeKonto.where("KtoNr = ?", originZEKonto.KtoNr).size).to eq 3

		latestZEKonto = ZeKonto.get(originZEKonto.KtoNr, Time.now)

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
			originZEKonto.Laufzeit +=  1
			originZEKonto.save!
			createdAt = Time.now
		end
		expect(ZeKonto.where("KtoNr = ?", originZEKonto.KtoNr).size).to eq 3

		latestZEKonto = ZeKonto.get(originZEKonto.KtoNr, createdAtOrigin)
		expect(latestZEKonto.nil?).to eq false
		expect(latestZEKonto.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to_not eq createdAt.strftime("%Y-%m-%d %H:%M:%S")
		expect(latestZEKonto.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq createdAtOrigin.strftime("%Y-%m-%d %H:%M:%S")
	end

	it "returns nil, if there is no ZEKonto for an invalid Kontonummer or date" do
		# Test for an invalid Kontonummer
		originZEKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe)
		expect(ZeKonto.get(originZEKonto.KtoNr + 10, Time.now)).to eq nil

		# create valid eekonto, in different versions
		originTime = Time.now
		sleep(1.0)

		originZEKonto = FactoryGirl.create(:zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe)
		createdAtOrigin = Time.now
		createdAt = Time.now
		for i in 0..1
			sleep(1.0)
			originZEKonto.Laufzeit +=  1
			originZEKonto.save!
			createdAt = Time.now
		end
		expect(ZeKonto.where("KtoNr = ?", originZEKonto.KtoNr).size).to eq 3

		latestZEKonto = ZeKonto.get(originZEKonto.KtoNr, originTime)
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
			originZEKonto.Laufzeit +=  1
			originZEKonto.save!
			createdAt = Time.now
		end
		expect(ZeKonto.where("KtoNr = ?", originZEKonto.KtoNr).size).to eq 3

		latestZEKonto = ZeKonto.latest(originZEKonto.KtoNr)

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
		pnr = ozbPerson.UeberPnr

		sachPerson = FactoryGirl.create(:ozbperson_with_person)
		sachPnr = sachPerson.UeberPnr
		
		expect(OZBPerson.where("Mnr = ?", pnr).size).to eq 1
		expect(OZBPerson.where("Mnr = ?", sachPnr).size).to eq 1

		ozbKonto1 = FactoryGirl.create(:ozbkonto_with_waehrung, :KtoNr => 12345, :Mnr => pnr, :SachPnr => sachPnr)
		zeKonto1 = FactoryGirl.create(:zeKonto_with_EEKonto_Projektgruppe, :KtoNr => 12345)
		expect(zeKonto1).to be_valid

		ozbKonto2 = FactoryGirl.create(:ozbkonto_with_waehrung, :KtoNr => 54321, :Mnr => pnr, :SachPnr => sachPnr)
		zeKonto2 = FactoryGirl.create(:zeKonto_with_EEKonto_Projektgruppe, :KtoNr => 54321)
		expect(zeKonto2).to be_valid

		ozbKonto3 = FactoryGirl.create(:ozbkonto_with_waehrung, :KtoNr => 13254, :Mnr => pnr, :SachPnr => sachPnr)
		zeKonto3 = FactoryGirl.create(:zeKonto_with_EEKonto_Projektgruppe, :KtoNr => 13254)		
		expect(zeKonto3).to be_valid

		sleep(1.0)
		zeKonto3.Laufzeit += 1
		expect(zeKonto3.save).to eq true

		expect(ZeKonto.find(:all).size).to eq 4

		expect(ZeKonto.latest_all_for(pnr).size).to eq 3
	end

	it "returns none ZEKonten for a given valid OZBPerson, if there are not any" do
		ozbPerson = FactoryGirl.create(:ozbperson_with_person)
		pnr = ozbPerson.UeberPnr

		expect(OZBPerson.where("Mnr = ?", pnr).size).to eq 1

		expect(ZeKonto.latest_all_for(pnr).size).to eq 0
	end

	it "returns nil for a given invalid OZBPerson" do
		expect(ZeKonto.latest_all_for(45).size).to eq 0
	end

end