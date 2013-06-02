require 'spec_helper'

describe OzbKonto do

	#Factory
	it "has a valid factory" do
		ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson)
		expect(ozbKonto).to be_valid

		puts ozbKonto.inspect

		expect(ozbKonto.GueltigVon.getlocal().strftime("%Y-%m-%d %H:%M:%S")).to eq Time.now.strftime("%Y-%m-%d %H:%M:%S")
		expect(ozbKonto.GueltigBis.strftime("%Y-%m-%d %H:%M:%S")).to eq "9999-12-31 23:59:59"
	end

	# Valid/invalid attributes

	# Kontonummer (ktoNr)
	it "is valid with a valid Kontonummer" do
		expect(FactoryGirl.create(:ozbkonto_with_ozbperson, :ktoNr => 51234)).to be_valid
	end

	it "is invalid without a Kontonummer" do 
		expect(FactoryGirl.build(:ozbkonto_with_ozbperson, :ktoNr => nil)).to be_invalid
	end

	it "is invalid with an invalid Kontonummer" do 
		expect(FactoryGirl.build(:ozbkonto_with_ozbperson, :ktoNr => "a1234")).to be_invalid

		expect(FactoryGirl.build(:ozbkonto_with_ozbperson, :ktoNr => 123456)).to be_invalid

		expect(FactoryGirl.build(:ozbkonto_with_ozbperson, :ktoNr => "hellow")).to be_invalid
	end

	# Mitgliedsnummer (mnr)
	it "is valid with a valid Mitgliedsnummer" do
		person = FactoryGirl.create(:Person, :pnr => 42)
		expect(person).to be_valid

		ozbperson = FactoryGirl.create(:OZBPerson, :mnr => 42, :ueberPnr => 42)
		expect(ozbperson).to be_valid

		sachbearbeiter = FactoryGirl.create(:ozbperson_with_person)
		expect(sachbearbeiter).to be_valid

		expect(FactoryGirl.build(:OzbKonto, :mnr => 42, :sachPnr => sachbearbeiter.mnr)).to be_valid
	end

	it "is invalid without a Mitgliedsnummer" do
		expect(FactoryGirl.build(:OzbKonto, :mnr => nil)).to be_invalid
	end

	it "is invalid with an invalid Mitgliedsnummer" do 
		person = FactoryGirl.create(:Person, :pnr => 42)
		expect(person).to be_valid

		ozbperson = FactoryGirl.create(:OZBPerson, :mnr => 42, :ueberPnr => 42)
		expect(ozbperson).to be_valid

		expect(FactoryGirl.build(:OzbKonto, :mnr => 45)).to be_invalid
		expect(FactoryGirl.build(:OzbKonto, :mnr => "as")).to be_invalid
	end


	# Sachbearbeiter Personalnummer (sachPnr)
	it "is valid with a valid Sachbearbeiter Personalnummer" do 
		sachbearbeiter = FactoryGirl.create(:ozbperson_with_person)
		expect(sachbearbeiter).to be_valid

		expect(FactoryGirl.create(:ozbkonto_with_ozbperson, :sachPnr => sachbearbeiter.mnr)).to be_valid		
	end

	it "is invalid without a Sachbearbeiter Personalnummer" do 
		expect(FactoryGirl.build(:ozbkonto_with_ozbperson, :sachPnr => nil)).to be_invalid		
	end

	it "is invalid with an invalid Sachbearbeiter Personalnummer" do
		expect(FactoryGirl.build(:ozbkonto_with_ozbperson, :sachPnr => 45)).to be_invalid
		expect(FactoryGirl.build(:ozbkonto_with_ozbperson, :sachPnr => "hello")).to be_invalid
	end

	# Class and instance methods 

	# ozbperson_exists

	# sachPnr_exists

	# self.get_all_ee_for(mnr)

	# self.get_all_ze_for(mnr)

	# get(ktoNr, date = Time.now)

	# self.latest(ktoNr)

	# self.destroy_yourself_if_you_are_alone(ktoNr)

	# set_wsaldo_psaldo_to_zero

	# set_saldo_datum
 
	# destroy_historic_records

	# set_assoc_attributes

	# set_valid_time

	# set_new_valid_time

	# after_update

end