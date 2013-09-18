require 'spec_helper'

describe OZBPerson  do	
	# Factory
	it "has a valid factory" do
		expect(FactoryGirl.create(:ozbperson_with_person)).to be_valid
	end

	# Valid/invalid attributes

	# Mnr
	it "is valid with a valid Mnr" do
		person = FactoryGirl.create(:Person)
		expect(person).to be_valid

		findPerson = Person.where("pnr = ?", person.Pnr)
		expect(findPerson.size).to eq 1

		expect(FactoryGirl.create(	:OZBPerson, :Mnr => person.Pnr, 
									:UeberPnr => person.Pnr)).to be_valid
	end

	it "is invalid without a Mnr" do
		expect(FactoryGirl.build(:OZBPerson, :Mnr => nil)).to be_invalid
	end

	# UeberPnr
	it "is valid with a valid UeberPnr" do
		person = FactoryGirl.create(:Person)
		expect(FactoryGirl.create(	:OZBPerson, :Mnr => person.Pnr, 
									:UeberPnr => person.Pnr)).to be_valid
	end

	it "is valid without a UeberPnr" do
		expect(FactoryGirl.build(:OZBPerson, :UeberPnr => nil)).to be_invalid
	end

	it "is invalid with an invalid UeberPnr" do
		expect(FactoryGirl.build(:OZBPerson, :Mnr => 2, :UeberPnr => 4)).to be_invalid
	end

	# Antragsdatum
	it "is valid with a Antragsdatum" do
		expect(FactoryGirl.create(:ozbperson_with_person, :Antragsdatum => Time.now)).to be_valid
	end

	it "is invalid without a Antragsdatum" do
		expect(FactoryGirl.build(:ozbperson_with_person, :Antragsdatum => nil)).to be_invalid
	end

	it "is invalid with a invalid Antragsdatum" do
		expect(FactoryGirl.build(:ozbperson_with_person, :Antragsdatum => "1232.32.15")).to be_invalid
	end

	# Class and instance methods
	
	# person_exists
	it "returns true if a valid person exists" do
		ozbperson = FactoryGirl.create(:ozbperson_with_person)
		person = FactoryGirl.create(:Person)
		ozbperson.Mnr = person.Pnr
		expect(ozbperson.person_exists).to eq true
	end

	it "returns false if an invalid person exists" do
		ozbperson = FactoryGirl.create(:ozbperson_with_person)
		ozbperson.Mnr = 42
		expect(ozbperson.person_exists).to eq false
	end

	# ueberPerson_exists
	it "returns true if a valid (ueber) person exists." do
		ozbperson = FactoryGirl.create(:ozbperson_with_person)
		person = FactoryGirl.create(:Person)
		ozbperson.UeberPnr = person.Pnr
		expect(ozbperson.ueberPerson_exists).to eq true
	end

	it "returns false if an invalid (ueber) person exists" do
		ozbperson = FactoryGirl.create(:ozbperson_with_person)
		ozbperson.UeberPnr = 42
		expect(ozbperson.ueberPerson_exists).to eq false
	end
end