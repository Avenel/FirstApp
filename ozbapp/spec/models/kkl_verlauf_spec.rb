require 'spec_helper'

describe KklVerlauf do
	#Factory
	it "has a valid factory" do
		expect(FactoryGirl.create(:kklverlauf_with_ozbkonto_with_kontenklasse)).to be_valid
	end

	# Valid/Invalid attributes

	# KtoNr
	it "is valid with a valid and existing Kontonummer" do
		FactoryGirl.create(:ozbkonto_with_ozbperson, :KtoNr => 51234)
		expect(FactoryGirl.create(:kklverlauf_with_kontenklasse, :KtoNr => 51234)).to be_valid
	end

	it "is invalid without a Kontonummer" do 
		expect(FactoryGirl.build(:kklverlauf_with_kontenklasse, :KtoNr => nil)).to be_invalid
	end

	it "is invalid with an invalid Kontonummer" do 
		expect(FactoryGirl.build(:kklverlauf_with_kontenklasse, :KtoNr => "a1234")).to be_invalid

		expect(FactoryGirl.build(:kklverlauf_with_kontenklasse, :KtoNr => 123456)).to be_invalid

		expect(FactoryGirl.build(:kklverlauf_with_kontenklasse, :KtoNr => "hellow")).to be_invalid
	end

	it "is invalid with an not existing OZBKonto" do 
		expect(FactoryGirl.build(:kklverlauf_with_kontenklasse, :KtoNr => 98792)).to be_invalid
	end

	# KKLAbDatum
	it "is valid with a valid KKLAbDatum" do
		expect(FactoryGirl.create(:kklverlauf_with_ozbkonto_with_kontenklasse, :KKLAbDatum => Date.today)).to be_valid
	end

	it "is invalid without a KKLAbDatum" do
		expect(FactoryGirl.build(:kklverlauf_with_ozbkonto_with_kontenklasse, :KKLAbDatum => nil)).to be_invalid
	end

	# KKL
	it "is valid with a valid and existing KKL" do
		kkl_a = FactoryGirl.create(:kontenklasse_A)
		expect(FactoryGirl.create(:kklverlauf_with_ozbkonto, :KKL => kkl_a.KKL)).to be_valid
	end

	it "is invalid without a KKL" do
		expect(FactoryGirl.build(:kklverlauf_with_ozbkonto, :KKL => nil)).to be_invalid	
	end

	it "is invalid with an invalid KKL" do
		expect(FactoryGirl.build(:kklverlauf_with_ozbkonto, :KKL => "10")).to be_invalid
		expect(FactoryGirl.build(:kklverlauf_with_ozbkonto, :KKL => "-1")).to be_invalid
		expect(FactoryGirl.build(:kklverlauf_with_ozbkonto, :KKL => "A")).to be_invalid		
	end

	it "is invalid with a valid and not existing KKL" do
		expect(FactoryGirl.build(:kklverlauf_with_ozbkonto, :KKL => "9")).to be_invalid
	end

	# kto_exists
	it "kto_exists is true when ozbkonto existing" do
		ozbkonto = FactoryGirl.create(:ozbkonto_with_ozbperson)
		expect(ozbkonto).to be_valid

		kklverlauf = FactoryGirl.create(:kklverlauf_with_kontenklasse, :KtoNr => ozbkonto.KtoNr)
		expect(kklverlauf).to be_valid

		expect(kklverlauf.KtoNr).to eq ozbkonto.KtoNr

		expect(kklverlauf.kto_exists).to eq true
	end

	it "kto_exists is false when ozbkonto not exists" do
		kklverlauf = FactoryGirl.create(:kklverlauf_with_ozbkonto_with_kontenklasse)
		expect(kklverlauf).to be_valid

		kklverlauf.KtoNr = 94832
		expect(kklverlauf.kto_exists).to eq false

		kklverlauf.KtoNr = nil
		expect(kklverlauf.kto_exists).to eq false

		kklverlauf.KtoNr = 0
		expect(kklverlauf.kto_exists).to eq false

		kklverlauf.KtoNr = -1
		expect(kklverlauf.kto_exists).to eq false
	end

end
