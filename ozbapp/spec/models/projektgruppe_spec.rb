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
		projektgruppe = FactoryGirl.build(:Projektgruppe, :pgNr => 42)
		expect(projektgruppe).to be_valid
		expect(projektgruppe.save).to eq true
	end

	it "is invalid without a Projektgruppennummer" do
		expect(FactoryGirl.build(:Projektgruppe, :pgNr => nil)).to be_invalid
	end

	it "is invalid with an invalid Projektgruppennummer" do
		expect(FactoryGirl.build(:Projektgruppe, :pgNr => "a1234")).to be_invalid
	end

	# ProjGruppenBez
	it "is valid with a valid GruppenBezeichnung" do
		projektgruppe = FactoryGirl.build(:Projektgruppe, :projGruppenBez => "Mustergruppe")
		expect(projektgruppe).to be_valid
		expect(projektgruppe.save).to eq true
	end

	it "is valid without a GruppenBezeichnung" do
		projektgruppe = FactoryGirl.build(:Projektgruppe, :projGruppenBez => nil)
		expect(projektgruppe).to be_valid
		expect(projektgruppe.save).to eq true
	end

	# Class and instance methods
	# valid_pgNr
	it "returns true, if pgNr is greater 0, not a string and there is no record with the same pgNr" do
		projektgruppe = FactoryGirl.build(:Projektgruppe)
		projektgruppe.pgNr = 42

		expect(projektgruppe.valid_pgNr).to eq true
		expect(projektgruppe.save).to eq true
	end	

	it "returns false, if pgNr is a string" do
		projektgruppe = FactoryGirl.build(:Projektgruppe)
		projektgruppe.pgNr = "helloWorld"

		expect(projektgruppe.valid_pgNr).to eq false
		expect(projektgruppe.save).to eq false
	end

	it "returns false, if pgNr equals 0" do
		projektgruppe = FactoryGirl.build(:Projektgruppe)
		projektgruppe.pgNr = 0

		expect(projektgruppe.valid_pgNr).to eq false
		expect(projektgruppe.save).to eq false
	end

	it "returns false, if pgNr already exists in the database" do
		projektgruppe = FactoryGirl.build(:Projektgruppe)
		projektgruppe.pgNr = 45

		expect(projektgruppe.valid_pgNr).to eq true
		expect(projektgruppe.save).to eq true

		projektgruppe = FactoryGirl.build(:Projektgruppe)
		projektgruppe.pgNr = 45

		expect(projektgruppe.valid_pgNr).to eq false
		expect(projektgruppe.save).to eq false
	end

end