require 'spec_helper'

describe Person do

	# Valid factory
	it "has a valid factory" do
		expect(FactoryGirl.create(:Person)).to be_valid
	end

	# Valid/invalid attributes

	# Pnr
	it "is vaild with pnr" do
		expect(FactoryGirl.create(:Person, :Pnr => 99)).to be_valid
	end

	it "is invalid without a pnr" do
		expect(FactoryGirl.build(:Person, :Pnr => nil)).to be_invalid
	end
	
	# Nachname
	it "is valid with name" do
		expect(FactoryGirl.build(:Person, :Name => "Mustermann")).to be_valid
	end

	it "is invalid without name" do
		expect(FactoryGirl.build(:Person, :Name => nil)).to be_invalid
	end

	# Vorname
	it "is valid with firstname" do
		expect(FactoryGirl.build(:Person, :Vorname => "Max")).to be_valid
	end

	it "is invalid without firstname" do
		expect(FactoryGirl.build(:Person, :Vorname => nil)).to be_invalid
	end

	# Rolle
	it "is valid with role" do
		expect(FactoryGirl.build(:Person, :Rolle => "M")).to be_valid 
	end

	it "is invalid without role" do
		expect(FactoryGirl.build(:Person, :Rolle => nil)).to be_invalid
	end

	it "is invalid with an invalid role" do
		expect(FactoryGirl.build(:Person, :Rolle => "Z")).to be_invalid
	end

	# E-Mail
	it "is valid with a valid email adress" do
		expect(FactoryGirl.build(:Person, :EMail => "hello@example.com")).to be_valid
	end

	it "is invalid without a email adress" do
		expect(FactoryGirl.build(:Person, :EMail => nil)).to be_invalid
	end

	it "is invalid with an invalid email adress" do
		expect(FactoryGirl.build(:Person, :EMail => "foo")).to be_invalid
	end

	# Class and instance methods
	# Person.get
	it "returns the current person object" do
		person = FactoryGirl.create(:Person, :Name => "Musterfrau")
		expect(person.name).to eq "Musterfrau"

		person.name = "Mustermann"

		# wait 1sec to prevent PK validation error ("gueltigVon" should not be equal)
		sleep(1.0)
		expect(person.save!).to eq true

		expect(Person.get(person.pnr).name).to eq "Mustermann"
	end

	# self.latest_all
	it "returns all persons in their latest version" do		
		# Generate a couple of person entries
		for i in 0...5 do
			expect(FactoryGirl.create(:Person)).to be_valid
		end

		# Change lastname of a person to test history feature
		person = FactoryGirl.create(:Person)
		person.name = "Mustermann"

		# wait 1sec to prevent PK validation error ("gueltigVon" should not be equal)
		sleep(1.0)
		expect(person.save!).to eq true

		# check if there are 6 current versions of persons in the database
		expect(Person.latest_all.size).to eq 6

		# check if there are over all 7 versions of persons in the databse
		expect(Person.find(:all).size).to eq 7
	end

	# self.latest
	it "returns a person in his latest version" do
		person = FactoryGirl.create(:Person, :Name => "Musterfrau")
		expect(person.name).to eq "Musterfrau"

		person.name = "Mustermann"

		# wait 1sec to prevent PK validation error ("gueltigVon" should not be equal)
		sleep(1.0)
		expect(person.save!).to eq true

		expect(Person.latest(person.Pnr).name).to eq "Mustermann"
	end

	# fullname
	it "returns the fullname of a person" do
		person = FactoryGirl.create(:Person, :Name => "Mustermann", :Vorname => "Max")
		expect(person.fullname).to eq "Mustermann, Max"
	end

end	