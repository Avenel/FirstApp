require 'spec_helper'

describe Bank do

	# Factory
	it "has a valid factory" do
		expect(FactoryGirl.create(:Bank)).to be_valid
	end

	# Valid/invalid attributes
	# BLZ
	it "is valid with a valid BLZ" do 
		expect(FactoryGirl.create(:Bank, :BLZ => (10000000..99999999).to_a.sample)).to be_valid
	end

	it "is invalid without a BLZ" do 
		expect(FactoryGirl.build(:Bank, :BLZ => nil)).to be_invalid

	end

	it "is invalid with an invalid BLZ" do
		# invalid with only 7 digits
		expect(FactoryGirl.build(:Bank, :BLZ => 7261829)).to be_invalid

		# invalid with chars
		expect(FactoryGirl.build(:Bank, :BLZ => "hello")).to be_invalid
	end

	# BIC
	it "is valid with a valid BIC" do
		# Valid code = 8 or 11 chars long
		expect(FactoryGirl.create(:Bank, :BIC => "AS13AS12")).to be_valid
		expect(FactoryGirl.create(:Bank, :BIC => "AS13AS1223A")).to be_valid
	end

	it "is valid without a BIC" do
		expect(FactoryGirl.create(:Bank, :BIC => nil)).to be_valid
	end

	it "is invalid with an invalid BIC" do
		# invalid = length != 8|11
		expect(FactoryGirl.build(:Bank, :BIC => "1234")).to be_invalid
		expect(FactoryGirl.build(:Bank, :BIC => "123456789")).to be_invalid
		expect(FactoryGirl.build(:Bank, :BIC => "123456789ABCDEF")).to be_invalid
	end

	# BankName
	it "is valid with a valid BankName" do 
		expect(FactoryGirl.create(:Bank, :BankName => "Sparkasse Musterstadt")).to be_valid
	end

	it "is valid without a BankName" do
		expect(FactoryGirl.create(:Bank, :BankName => nil)).to be_valid
	end

	# What is an invalid BankName? => to be defined!
	it "is invalid with an invalid BankName" 


	# Class and instance methods
	# self.destroy_yourself_if_your_are_alone(blz)
	it "destroys himself if there are zero Bankverbindungen related to this Bank"
	it "does not destroy himself if there are any Bankverbindungen related to this Bank"

end