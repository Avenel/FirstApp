require 'spec_helper'

describe OZBPerson  do	
	# Factory
	it "has a valid factory" do
		person = FactoryGirl.create(:person_with_ozbperson)
		ozbperson = getOZBPerson(person.pnr)
		expect(ozbperson.nil?).to eq false
	end

	# Valid/invalid attributes
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

	it "is valid with a valid UeberPnr" do
		person = FactoryGirl.create(:Person)
		expect(FactoryGirl.create(	:OZBPerson, :Mnr => person.Pnr, 
									:UeberPnr => person.Pnr)).to be_valid
	end

	it "is invalid without a UeberPnr" do
		expect(FactoryGirl.build(:OZBPerson, :UeberPnr => nil)).to be_invalid
	end

	it "is invalid with an invalid UeberPnr" do
		expect(FactoryGirl.build(:OZBPerson, :Mnr => 2, :UeberPnr => 4)).to be_invalid
	end

	it "is valid with a Antragsdatum" do
		person = FactoryGirl.create(:Person)
		expect(FactoryGirl.create(	:OZBPerson, :mnr => person.pnr, :ueberPnr => person.pnr,
									:Antragsdatum => Time.now)).to be_valid
	end

	it "is invalid without a Antragsdatum" do
		person = FactoryGirl.create(:Person)
		expect(FactoryGirl.build(	:OZBPerson, :mnr => person.pnr, :ueberPnr => person.pnr,
									:Antragsdatum => nil)).to be_invalid
	end

	it "is invalid with a invalid Antragsdatum" do
		person = FactoryGirl.create(:Person)
		expect(FactoryGirl.build(	:OZBPerson, :mnr => person.pnr, :ueberPnr => person.pnr,
									:Antragsdatum => "1232.32.15")).to be_invalid
	end

	it "is valid with a valid email adress" do
		person = FactoryGirl.create(:Person)
		expect(FactoryGirl.build(	:OZBPerson, :mnr => person.pnr, :ueberPnr => person.pnr,
									:email => "hello@example.com")).to be_valid	
	end

	it "is invalid without an email adress" do
		person = FactoryGirl.create(:Person)
		expect(FactoryGirl.build(	:OZBPerson, :mnr => person.pnr, :ueberPnr => person.pnr,
									:email => nil)).to be_invalid	
	end

	it "is invalid with an invalid email adress" do
		person = FactoryGirl.create(:Person)
		expect(FactoryGirl.build(	:OZBPerson, :mnr => person.pnr, :ueberPnr => person.pnr,
									:email => "asd2ad.com")).to be_invalid	
	end

	# Unit functions
	it "validates the password complexity as true, with a valid password" do
		person = FactoryGirl.create(:person_with_ozbperson)
		ozbperson = getOZBPerson(person.pnr)
		
		ozbperson.password = "Musterpasswort123"
		expect(ozbperson.password_complexity).to eq true
	end

	it "validates the password complexity as false, with an invalid password" do
		person = FactoryGirl.create(:person_with_ozbperson)
		ozbperson = getOZBPerson(person.pnr)
		
		ozbperson.password = "masd"
		expect(ozbperson.password_complexity).to eq false
	end

	it "returns true if a valid person exists" do
		person = FactoryGirl.create(:person_with_ozbperson)
		ozbperson = getOZBPerson(person.pnr)
		
		ozbperson.mnr = person.pnr
		expect(ozbperson.person_exists).to eq true
	end

	it "returns false if an invalid person exists" do
		person = FactoryGirl.create(:person_with_ozbperson, :pnr => 1)
		ozbperson = getOZBPerson(person.pnr)
		
		ozbperson.mnr = 42
		expect(ozbperson.person_exists).to eq false
	end

	it "returns true if a valid (ueber) person exists." do
		person = FactoryGirl.create(:person_with_ozbperson)
		ozbperson = getOZBPerson(person.pnr)
		
		ozbperson.ueberPnr = person.pnr
		expect(ozbperson.ueber_person_exists).to eq true
	end

	it "returns false if an invalid (ueber) person exists" do
		person = FactoryGirl.create(:person_with_ozbperson, :pnr => 1)
		ozbperson = getOZBPerson(person.pnr)
		
		ozbperson.ueberPnr = 42
		expect(ozbperson.ueber_person_exists).to eq false
	end
end