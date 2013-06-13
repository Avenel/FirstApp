require 'spec_helper'

describe KklVerlauf do
	#Factory
	it "has a valid factory" do
		expect(FactoryGirl.create(:kklverlauf_with_ozbkonto_with_kontenklasse)).to be_valid
	end

	# Valid/Invalid attributes

	# KtoNr
	it "is valid with a valid and existing Kontonummer" do
		FactoryGirl.create(:ozbkonto_with_ozbperson, :ktoNr => 51234)
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
		expect(FactoryGirl.create(:kklverlauf_with_ozbkonto, :KKL => kkl_a.kkl)).to be_valid
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

	# Method: set_ab_datum (before_create)
	it "sets the valid KKLAbDatum when it is blank" do
		ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson, :ktoNr => 74309)
		kontenKlasse = FactoryGirl.create(:kontenklasse_D)

		kkl_verlauf = FactoryGirl.build(:KklVerlauf, :KtoNr => ozbKonto.ktoNr, 
			:KKL => kontenKlasse.KKL)

		expect(kkl_verlauf).to be_valid
		expect(kkl_verlauf.KKLAbDatum).to eq nil	
		expect(kkl_verlauf.save!).to eq true
		expect(kkl_verlauf.KKLAbDatum).to eq Date.today
	end

	it "does not set the valid KKLAbDatum when it is already set" do
		ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson, :ktoNr => 74309)
		kontenKlasse = FactoryGirl.create(:kontenklasse_D)

		test_date = 1.week.ago

		kkl_verlauf = FactoryGirl.build(:KklVerlauf, :KtoNr => ozbKonto.ktoNr, 
			:KKL => kontenKlasse.KKL, :KKLAbDatum => test_date)

		expect(kkl_verlauf).to be_valid
		expect(kkl_verlauf.KKLAbDatum).to eq test_date	
		expect(kkl_verlauf.save!).to eq true
		expect(kkl_verlauf.KKLAbDatum).to eq test_date
	end

	# destroy_historic_records (callback methode: after_destroy)
	it "destroys all historic records except himself" do
		# create valid ozbkonto und a kkl_verlauf
		ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson, :ktoNr => 23456)
		kklVerlauf = FactoryGirl.create(:kklverlauf_with_kontenklasse, :KtoNr => ozbKonto.ktoNr)

		# create more kkl_verlaeufe for the past for this ozbkonto
		for i in 1..2
			sleep(1.0)
			expect(FactoryGirl.create(:KklVerlauf, 
				:KtoNr => kklVerlauf.KtoNr, 
				:KKL => kklVerlauf.KKL, 
				:KKLAbDatum => (i).weeks.ago)).to be_valid
		end

		expect(KklVerlauf.where("KtoNr = ?", kklVerlauf.KtoNr).size).to eq 3

		# Private method, therfore using send methode
		kklVerlauf.send(:destroy_historic_records)

		expect(KklVerlauf.where("KtoNr = ?", kklVerlauf.KtoNr).size).to eq 1
	end

	it "destroys zero records, because there are no historic records" do
		# create valid ozbkonto und a kkl_verlauf
		ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson, :ktoNr => 23456)
		kklVerlauf = FactoryGirl.create(:kklverlauf_with_kontenklasse, :KtoNr => ozbKonto.ktoNr)

		# create more kkl_verlaeufe for the future for this ozbkonto
		for i in 1..2
			sleep(1.0)
			expect(FactoryGirl.create(:KklVerlauf, 
				:KtoNr => kklVerlauf.KtoNr, 
				:KKL => kklVerlauf.KKL, 
				:KKLAbDatum => (-i).weeks.ago)).to be_valid
		end

		expect(KklVerlauf.where("KtoNr = ?", kklVerlauf.KtoNr).size).to eq 3

		# Private method, therfore using send methode
		kklVerlauf.send(:destroy_historic_records)

		expect(KklVerlauf.where("KtoNr = ?", kklVerlauf.KtoNr).size).to eq 3
	end

	# kto_exists
	it "kto_exists is true when ozbkonto existing" do
		ozbkonto = FactoryGirl.create(:ozbkonto_with_ozbperson)
		expect(ozbkonto).to be_valid

		kklverlauf = FactoryGirl.create(:kklverlauf_with_kontenklasse, :KtoNr => ozbkonto.ktoNr)
		expect(kklverlauf).to be_valid

		expect(kklverlauf.KtoNr).to eq ozbkonto.ktoNr

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
