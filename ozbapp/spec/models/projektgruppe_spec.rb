require 'spec_helper'

describe :Projektgruppe do

	# Factory
	it "has a valid factory" do
		expect(FactoryGirl.create(:Projektgruppe))
	end

	# Valid/invalid attributes
	it "is valid with a valid Projektgruppennummer" do
		expect(FactoryGirl.create(:Projektgruppe, :pgNr => 42)).to be_valid
	end

	it "is invalid without a Projektgruppennummer" do
		expect(FactoryGirl.build(:Projektgruppe, :pgNr => nil)).to be_invalid
	end

	it "is invalid with an invalid Projektgruppennummer" do
		expect(FactoryGirl.build(:Projektgruppe, :pgNr => "a1234")).to be_invalid
	end


	# Class and instance methods

end