require 'spec_helper'

describe Person do

	# Valid factory
	it "has a valid factory" do
		expect(FactoryGirl.build(:person)).to be_valid
	end

	# Valid/invalid attributes

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
		expect(FactoryGirl.build(:person, :Rolle => "G")).to be_valid 
	end

	it "is invalid without role" do
		expect(FactoryGirl.build(:person, :Rolle => nil)).to be_invalid
	end

	it "is invalid with an invalid role" do
		expect(FactoryGirl.build(:person, :Rolle => "Z")).to be_invalid
	end

end	