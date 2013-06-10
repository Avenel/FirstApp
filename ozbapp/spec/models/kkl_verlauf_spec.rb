require 'spec_helper'

describe KklVerlauf do
	#Factory
	it "has a valid factory" do
		expect(FactoryGirl.create(:kklverlauf_with_ozbkonto_with_kontenklasse)).to be_valid
	end

	# Valid/Invalid attributes

	# KtoNr
	it "is valid with a valid Kontonummer" do
		expect(FactoryGirl.create(:kklverlauf_with_ozbkonto_with_kontenklasse, :KtoNr => 51234)).to be_valid
	end

	it "is invalid without a Kontonummer" do 
		expect(FactoryGirl.build(:kklverlauf_with_ozbkonto_with_kontenklasse, :KtoNr => nil)).to be_invalid
	end

	it "is invalid with an invalid Kontonummer" do 
		expect(FactoryGirl.build(:kklverlauf_with_ozbkonto_with_kontenklasse, :KtoNr => "a1234")).to be_invalid

		expect(FactoryGirl.build(:kklverlauf_with_ozbkonto_with_kontenklasse, :KtoNr => 123456)).to be_invalid

		expect(FactoryGirl.build(:kklverlauf_with_ozbkonto_with_kontenklasse, :KtoNr => "hellow")).to be_invalid
	end

	# KKLAbDatum
	it "is valid with a valid KKLAbDatum" do
		expect(FactoryGirl.create(:Kontenklasse, :KKLAbDatum => Date.today)).to be_valid
	end

	it "is invalid without a KKLAbDatum" do
		expect(FactoryGirl.build(:Kontenklasse, :KKLAbDatum => nil)).to be_invalid
	end
end
