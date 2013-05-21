require 'spec_helper'

describe Person do

	# Valid factory
	it "has a valid factory" do
		expect(FactoryGirl.build(:person)).to be_valid
	end

	# Valid/invalid attributes

	# Nachname
	it "is valid with name" do
		expect(FactoryGirl.build(:person, :name => "Mustermann")).to be_valid
	end

	it "is invalid without name" do
		expect(FactoryGirl.build(:person, :name => nil)).to be_invalid
	end

	# Vorname
	it "is valid with firstname" do
		expect(FactoryGirl.build(:person, :vorname => "Max")).to be_valid
	end

	it "is invalid without firstname" do
		expect(FactoryGirl.build(:person, :vorname => nil)).to be_invalid
	end

	# Rolle
	it "is valid with role" do
		expect(FactoryGirl.build(:person, :rolle => "A")).to be_valid 
	end

	it "is invalid without role" do
		expect(FactoryGirl.build(:person, :rolle => nil)).to be_invalid
	end

	it "is invalid with an invalid role" do
		expect(FactoryGirl.build(:person, :rolle => "Z")).to be_invalid
	end

end	