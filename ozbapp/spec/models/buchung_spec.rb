require 'spec_helper'

describe Buchung do 

	#Factory
	it "has a valid factory" do
		expect(FactoryGirl.create(:buchung_with_ozbkonten)).to be_valid 
	end

	# Valid/invalid attributes
	# BuchJahr
	it "is valid with a valid BuchJahr" do
		expect(FactoryGirl.create(:buchung_with_ozbkonten, :BuchJahr => 2000)).to be_valid 
	end

	it "is invalid without a BuchJahr" do
		expect(FactoryGirl.build(:buchung_with_ozbkonten, :BuchJahr => nil)).to be_invalid 
	end

	it "is invalid with a invalid BuchJahr" do
		expect(FactoryGirl.build(:buchung_with_ozbkonten, :BuchJahr => "ABCD")).to be_invalid 
		expect(FactoryGirl.build(:buchung_with_ozbkonten, :BuchJahr => 200)).to be_invalid 
		expect(FactoryGirl.build(:buchung_with_ozbkonten, :BuchJahr => 0)).to be_invalid 
		expect(FactoryGirl.build(:buchung_with_ozbkonten, :BuchJahr => 10)).to be_invalid 
	end

	#KtoNr
	it "is valid with a valid and existing OZBKonto KtoNr" do
		FactoryGirl.create(:ozbkonto_with_ozbperson, :KtoNr => 51234)
		expect(FactoryGirl.create(:buchung_without_ozbkonto, :KtoNr => 51234)).to be_valid 
	end

	it "is invalid with a valid, but not existing OZBKonto KtoNr" do
		ozbkonto_soll = FactoryGirl.create(:ozbkonto_with_ozbperson)
		ozbkonto_haben = FactoryGirl.create(:ozbkonto_with_ozbperson)
		buchung = FactoryGirl.build(:Buchung, :KtoNr => 51235, :SollKtoNr => ozbkonto_soll.KtoNr,
			:HabenKtoNr => ozbkonto_haben.KtoNr)
		expect(buchung).to be_invalid
		expect(buchung.save).to eq false
	end

	it "is invalid without a KtoNr" do
		ozbkonto_soll = FactoryGirl.create(:ozbkonto_with_ozbperson)
		ozbkonto_haben = FactoryGirl.create(:ozbkonto_with_ozbperson)
		buchung = FactoryGirl.build(:Buchung, :KtoNr => nil, :SollKtoNr => ozbkonto_soll.KtoNr,
			:HabenKtoNr => ozbkonto_haben.KtoNr)
		expect(buchung).to be_invalid
		expect(buchung.save).to eq false
	end

	it "is invalid with a invalid KtoNr" do
		ozbkonto_soll = FactoryGirl.create(:ozbkonto_with_ozbperson)
		ozbkonto_haben = FactoryGirl.create(:ozbkonto_with_ozbperson)

		buchung1 = FactoryGirl.build(:Buchung, :KtoNr => "ABCD", :SollKtoNr => ozbkonto_soll.KtoNr,
			:HabenKtoNr => ozbkonto_haben.KtoNr)
		expect(buchung1).to be_invalid
		expect(buchung1.save).to eq false
		
		buchung2 = FactoryGirl.build(:Buchung, :KtoNr => "1234X", :SollKtoNr => ozbkonto_soll.KtoNr,
			:HabenKtoNr => ozbkonto_haben.KtoNr)
		expect(buchung2).to be_invalid
		expect(buchung2.save).to eq false
		

		buchung3 = FactoryGirl.build(:Buchung, :KtoNr => 0, :SollKtoNr => ozbkonto_soll.KtoNr,
			:HabenKtoNr => ozbkonto_haben.KtoNr)
		expect(buchung3).to be_invalid
		expect(buchung3.save).to eq false
		

		buchung4 = FactoryGirl.build(:Buchung, :KtoNr => 100000, :SollKtoNr => ozbkonto_soll.KtoNr,
			:HabenKtoNr => ozbkonto_haben.KtoNr)
		expect(buchung4).to be_invalid
		expect(buchung4.save).to eq false
	end

	# BnKreis
	it "is valid with a valid BnKreis" 	do
		expect(FactoryGirl.create(:buchung_with_ozbkonten, :BnKreis => "AB")).to be_valid 
		expect(FactoryGirl.create(:buchung_with_ozbkonten, :BnKreis => 20)).to be_valid 
		expect(FactoryGirl.create(:buchung_with_ozbkonten, :BnKreis => 1)).to be_valid 
	end

	it "is invalid without a BnKreis" 	

	it "is invalid with a invalid BnKreis" 
	

	# BelegNr
	it "is valid with a valid BelegNr" 
	
	it "is invalid without a BelegNr" 
	
	it "is invalid with a invalid BelegNr" 


	# Typ
	it "is valid with a valid Typ" 
	
	it "is invalid without a Typ" 
	
	it "is invalid with a invalid Typ" 


	# Belegdatum
	it "is valid with a valid Belegdatum" 
	
	it "is invalid without a Belegdatum" 
	
	it "is invalid with a invalid Belegdatum" 


	# BuchDatum
	it "is valid with a valid BuchDatum" 
	
	it "is invalid without a BuchDatum" 
	
	it "is invalid with a invalid BuchDatum" 


	# Buchungstext
	it "is valid with a valid Buchungstext" 
	
	it "is invalid without a Buchungstext" 
	
	it "is invalid with a invalid Buchungstext" 


	# Sollbetrag
	it "is valid with a valid Sollbetrag" 
	
	it "is invalid without a Sollbetrag" 
	
	it "is invalid with a invalid Sollbetrag" 


	# Habenbetrag
	it "is valid with a valid Habenbetrag" 
	
	it "is invalid without a Habenbetrag" 
	
	it "is invalid with a invalid Habenbetrag" 

	#SollKtoNr
	it "is valid with a valid and existing OZBKonto SollKtoNr" do
		FactoryGirl.create(:ozbkonto_with_ozbperson, :KtoNr => 51234)
		expect(FactoryGirl.create(:buchung_without_ozbkonto_soll, :SollKtoNr => 51234)).to be_valid 
	end

	it "is invalid with a valid, but not existing OZBKonto SollKtoNr" do
		ozbkonto = FactoryGirl.create(:ozbkonto_with_ozbperson)
		ozbkonto_haben = FactoryGirl.create(:ozbkonto_with_ozbperson)
		buchung = FactoryGirl.build(:Buchung, :KtoNr => ozbkonto.KtoNr, :SollKtoNr => 51235,
			:HabenKtoNr => ozbkonto_haben.KtoNr)
		expect(buchung).to be_invalid
		expect(buchung.save).to eq false
	end

	it "is invalid without a SollKtoNr" do
		ozbkonto = FactoryGirl.create(:ozbkonto_with_ozbperson)
		ozbkonto_haben = FactoryGirl.create(:ozbkonto_with_ozbperson)
		buchung = FactoryGirl.build(:Buchung, :KtoNr => ozbkonto.KtoNr, :SollKtoNr => nil,
			:HabenKtoNr => ozbkonto_haben.KtoNr)
		expect(buchung).to be_invalid
		expect(buchung.save).to eq false
	end

	it "is invalid with a invalid SollKtoNr" do
		ozbkonto = FactoryGirl.create(:ozbkonto_with_ozbperson)
		ozbkonto_haben = FactoryGirl.create(:ozbkonto_with_ozbperson)

		buchung1 = FactoryGirl.build(:Buchung, :KtoNr => ozbkonto.KtoNr, :SollKtoNr => "ABCD",
			:HabenKtoNr => ozbkonto_haben.KtoNr)
		expect(buchung1).to be_invalid
		expect(buchung1.save).to eq false
		
		buchung2 = FactoryGirl.build(:Buchung, :KtoNr => ozbkonto.KtoNr, :SollKtoNr => "1234X",
			:HabenKtoNr => ozbkonto_haben.KtoNr)
		expect(buchung2).to be_invalid
		expect(buchung2.save).to eq false
		

		buchung3 = FactoryGirl.build(:Buchung, :KtoNr => ozbkonto.KtoNr, :SollKtoNr => 0,
			:HabenKtoNr => ozbkonto_haben.KtoNr)
		expect(buchung3).to be_invalid
		expect(buchung3.save).to eq false
		

		buchung4 = FactoryGirl.build(:Buchung, :KtoNr => ozbkonto.KtoNr, :SollKtoNr => 100000,
			:HabenKtoNr => ozbkonto_haben.KtoNr)
		expect(buchung4).to be_invalid
		expect(buchung4.save).to eq false
	end


	#HabenKtoNr
	it "is valid with a valid and existing OZBKonto HabenKtoNr" do
		FactoryGirl.create(:ozbkonto_with_ozbperson, :KtoNr => 51234)
		expect(FactoryGirl.create(:buchung_without_ozbkonto_haben, :HabenKtoNr => 51234)).to be_valid 
	end

	it "is invalid with a valid, but not existing OZBKonto HabenKtoNr" do
		ozbkonto = FactoryGirl.create(:ozbkonto_with_ozbperson)
		ozbkonto_soll = FactoryGirl.create(:ozbkonto_with_ozbperson)
		buchung = FactoryGirl.build(:Buchung, :KtoNr => ozbkonto.KtoNr, :SollKtoNr => ozbkonto_soll.KtoNr,
			:HabenKtoNr => 51235)
		expect(buchung).to be_invalid
		expect(buchung.save).to eq false
	end

	it "is invalid without a HabenKtoNr" do
		ozbkonto = FactoryGirl.create(:ozbkonto_with_ozbperson)
		ozbkonto_soll = FactoryGirl.create(:ozbkonto_with_ozbperson)
		
		buchung = FactoryGirl.build(:Buchung, :KtoNr => ozbkonto.KtoNr, :SollKtoNr => ozbkonto_soll.KtoNr,
			:HabenKtoNr => nil)
		expect(buchung).to be_invalid
		expect(buchung.save).to eq false

	end

	it "is invalid with a invalid HabenKtoNr" do
		ozbkonto = FactoryGirl.create(:ozbkonto_with_ozbperson)
		ozbkonto_soll = FactoryGirl.create(:ozbkonto_with_ozbperson)
		
		buchung1 = FactoryGirl.build(:Buchung, :KtoNr => ozbkonto.KtoNr, :SollKtoNr => ozbkonto_soll.KtoNr,
			:HabenKtoNr => "ABCD")
		expect(buchung1).to be_invalid
		expect(buchung1.save).to eq false

		buchung2 = FactoryGirl.build(:Buchung, :KtoNr => ozbkonto.KtoNr, :SollKtoNr => ozbkonto_soll.KtoNr,
			:HabenKtoNr => "1234X")
		expect(buchung2).to be_invalid
		expect(buchung2.save).to eq false

		buchung3 = FactoryGirl.build(:Buchung, :KtoNr => ozbkonto.KtoNr, :SollKtoNr => ozbkonto_soll.KtoNr,
			:HabenKtoNr => 0)
		expect(buchung3).to be_invalid
		expect(buchung3.save).to eq false

		buchung4 = FactoryGirl.build(:Buchung, :KtoNr => ozbkonto.KtoNr, :SollKtoNr => ozbkonto_soll.KtoNr,
			:HabenKtoNr => 100000)
		expect(buchung4).to be_invalid
		expect(buchung4.save).to eq false
	end

	# WSaldoAcc
	it "is valid with a valid WSaldoAcc" 
	
	it "is invalid without a WSaldoAcc" 
	
	it "is invalid with a invalid WSaldoAcc" 

	# Punkte
	it "is valid with a valid Punkte" 
	
	it "is invalid without a Punkte" 
	
	it "is invalid with a invalid Punkte" 

	# PSaldoAcc
	it "is valid with a valid PSaldoAcc" 
	
	it "is invalid without a PSaldoAcc" 
	
	it "is invalid with a invalid PSaldoAcc" 
	
end