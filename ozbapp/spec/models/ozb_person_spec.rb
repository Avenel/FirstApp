require 'spec_helper'

describe OZBPerson  do	
	it "has a valid factory" do
		ozbPerson = FactoryGirl.build(:OZBPerson)

		expect(ozbPerson).to be_valid
		expect(ozbPerson.save).to eq true
	end

	# Valid/invalid attributes
	it "is valid with a valid Mnr" do
		person = FactoryGirl.create(:person)
		expect(person).to be_valid

		findPerson = Person.where("pnr = ?", person.Pnr)
		expect(findPerson.empty?).to eq false

		expect(FactoryGirl.create(	:OZBPerson, :Mnr => person.Pnr, 
									:UeberPnr => person.Pnr)).to be_valid
	end

	it "is invalid without a Mnr" do
		expect(FactoryGirl.build(:OZBPerson, :Mnr => nil)).to be_invalid
	end

	it "is valid with a valid UeberPnr" do
		person = FactoryGirl.create(:person)
		expect(FactoryGirl.create(	:OZBPerson, :Mnr => person.Pnr, 
									:UeberPnr => person.Pnr)).to be_valid
	end

	it "is invalid without a UeberPnr" do
		expect(FactoryGirl.build(:OZBPerson, :UeberPnr => nil)).to be_invalid
	end

	it "is invalid with an invalid UeberPnr" do
		expect(FactoryGirl.build(:OZBPerson, :Mnr => 2, :UeberPnr => 4)).to be_invalid
	end

	it "is valid with a Antragsdatum"

	it "is invalid without a Antragsdatum"

	it "is invalid with a invalid Antragsdatum"

	it "is valid with an email adress"

	it "is invalid without an email adress"

	it "is invalid with an invalid email adress"

end