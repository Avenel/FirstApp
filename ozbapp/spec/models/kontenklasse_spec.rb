require 'spec_helper'

describe Kontenklasse do
	# Factory
	it "has a valid factory" do
		expect(FactoryGirl.create(:kontenklasse_A)).to be_valid
	end

	# Valid/invalid attributes

	# KKL
	it "is valid with a valid KKL" do
		expect(FactoryGirl.create(:Kontenklasse, :KKL => "A")).to be_valid	
	end

	it "is invalid without a KKL" do
		expect(FactoryGirl.build(:Kontenklasse, :KKL => nil)).to be_invalid	
	end

	it "is invalid with an invalid KKL" do
		expect(FactoryGirl.build(:Kontenklasse, :KKL => "10")).to be_invalid
		expect(FactoryGirl.build(:Kontenklasse, :KKL => "-1")).to be_invalid
		expect(FactoryGirl.build(:Kontenklasse, :KKL => "B2")).to be_invalid		
	end

	# KKLAbDatum
	it "is valid with a valid KKLAbDatum" do
		expect(FactoryGirl.create(:Kontenklasse, :KKLEinrDatum => Date.today)).to be_valid
	end

	it "is invalid without a KKLAbDatum" do
		expect(FactoryGirl.build(:Kontenklasse, :KKLEinrDatum => nil)).to be_invalid
	end

	# Prozent
	it "is valid with a valid Prozent value" do
		expect(FactoryGirl.create(:Kontenklasse, :Prozent => 137.42)).to be_valid
	end

	it "is invalid without a Prozent value" do
		expect(FactoryGirl.build(:Kontenklasse, :Prozent => nil)).to be_invalid
	end

	it "is invalid with an invalid Prozent value" do
		expect(FactoryGirl.build(:Kontenklasse, :Prozent => -10)).to be_invalid
		expect(FactoryGirl.build(:Kontenklasse, :Prozent => 100000)).to be_invalid
		expect(FactoryGirl.build(:Kontenklasse, :Prozent => 0.001)).to be_invalid
	end

	# kkl_with_percent
	it "returns the kkl and it percent value" do
		kontenklasse = FactoryGirl.create(:Kontenklasse, :KKL => "A", :Prozent => 100.42)
		expect(kontenklasse.kkl_with_percent).to eq "Klasse 1 - 100.42%"
	end

end
