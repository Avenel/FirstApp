require 'spec_helper'
require 'person'

describe Person do

	# Reset the tdd database
	before(:all) do
    	exec('./../tools/datenbank_tdd_ruecksetzen.sh')
  	end

	# Valid factory
	it "has a valid factory" do
		expect(FactoryGirl.create(:person)).to be_valid
	end

	# Valid/invalid attributes

	# Nachname
	it "is valid with name" do
		expect(FactoryGirl.create(:person, :Name => "Mustermann")).to be_valid
	end

	it "is invalid without name" do
		expect(FactoryGirl.create(:person, :Name => nil)).to be_invalid
	end

	# Vorname
	it "is valid with firstname" do
		expect(FactoryGirl.create(:person, :Vorname => "Max")).to be_valid
	end

	it "is invalid without firstname" do
		expect(FactoryGirl.create(:person, :Vorname => nil)).to be_invalid
	end

	# Rolle
	it "is valid with role" do
		expect(FactoryGirl.create(:person, :Rolle => "M")).to be_valid 
	end

	it "is invalid without role" do
		expect(FactoryGirl.create(:person, :Rolle => nil)).to be_invalid
	end

	it "is invalid with an invalid role" do
		expect(FactoryGirl.create(:person, :Rolle => "Z")).to be_invalid
	end

	# E-Mail
	it "is valid with a valid email adress" do
		expect(FactoryGirl.create(:person, :Email => "hello@example.com")).to be_valid
	end

	it "is invalid without a email adress" do
		expect(FactoryGirl.create(:person, :Email => nil)).to be_invalid
	end

	it "is invalid with an invalid email adress" do
		expect(FactoryGirl.create(:person, :Email => "foo")).to be_invalid
	end

	it "is invalid because it is has not an unique email adress" do
		expect(FactoryGirl.create(:person, :Email => "hello@example.com")).to be_valid
		expect(FactoryGirl.create(:person, :Email => "hello@example.com")).to be_invalid
	end
end	