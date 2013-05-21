require 'spec_helper'

describe Person do

	# Valid factory
	it "has a valid factory" do
		expect(FactoryGirl.create(:person)).to be_valid
	end

	# Valid/invalid attributes

	# Pnr
	it "is vaild with pnr" do
		expect(FactoryGirl.create(:person, :Pnr => 99)).to be_valid
	end

	it "is invalid without a pnr" do
		expect(FactoryGirl.build(:person, :Pnr => nil)).to be_invalid
	end
	
	# Nachname
	it "is valid with name" do
		expect(FactoryGirl.build(:person, :Name => "Mustermann")).to be_valid
	end

	it "is invalid without name" do
		expect(FactoryGirl.build(:person, :Name => nil)).to be_invalid
	end

	# Vorname
	it "is valid with firstname" do
		expect(FactoryGirl.build(:person, :Vorname => "Max")).to be_valid
	end

	it "is invalid without firstname" do
		expect(FactoryGirl.build(:person, :Vorname => nil)).to be_invalid
	end

	# Rolle
	it "is valid with role" do
		expect(FactoryGirl.build(:person, :Rolle => "M")).to be_valid 
	end

	it "is invalid without role" do
		expect(FactoryGirl.build(:person, :Rolle => nil)).to be_invalid
	end

	it "is invalid with an invalid role" do
		expect(FactoryGirl.build(:person, :Rolle => "Z")).to be_invalid
	end

	# E-Mail
	it "is valid with a valid email adress" do
		expect(FactoryGirl.build(:person, :Email => "hello@example.com")).to be_valid
	end

	it "is invalid without a email adress" do
		expect(FactoryGirl.build(:person, :Email => nil)).to be_invalid
	end

	it "is invalid with an invalid email adress" do
		expect(FactoryGirl.build(:person, :Email => "foo")).to be_invalid
	end

	it "is invalid because it has not an unique email adress" do
		expect(FactoryGirl.create(:person, :Email => "hello@example.com")).to be_valid
		expect(FactoryGirl.build(:person, :Email => "hello@example.com")).to have(1).errors_on(:Email)
	end

end	