require 'spec_helper'

describe :Projektgruppe do

	# Factory
	it "has a valid factory" do
		projektgruppe = FactoryGirl.build(:Projektgruppe)
		expect(projektgruppe).to be_valid
		expect(projektgruppe.save).to eq true
	end

	# Valid/invalid attributes
	# pgNr = Projektgruppennummer
	it "is valid with a valid Projektgruppennummer" do
		projektgruppe = FactoryGirl.build(:Projektgruppe, :Pgnr => 42)
		expect(projektgruppe).to be_valid
		expect(projektgruppe.save).to eq true
	end

	it "is invalid without a Projektgruppennummer" do
		expect(FactoryGirl.build(:Projektgruppe, :Pgnr => nil)).to be_invalid
	end

	it "is invalid with an invalid Projektgruppennummer" do
		expect(FactoryGirl.build(:Projektgruppe, :Pgnr => "a1234")).to be_invalid
	end

	# ProjGruppenBez
	it "is valid with a valid GruppenBezeichnung" do
		projektgruppe = FactoryGirl.build(:Projektgruppe, :ProjGruppenBez => "Mustergruppe")
		expect(projektgruppe).to be_valid
		expect(projektgruppe.save).to eq true
	end

	it "is invalid without a GruppenBezeichnung" do
		projektgruppe = FactoryGirl.build(:Projektgruppe, :ProjGruppenBez => nil)
		expect(projektgruppe).to be_invalid
	end

	# Class and instance methods
	

end