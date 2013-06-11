require 'spec_helper'

describe Buergschaft do

	# Factory
	it "has a valid factory" do
		expect(FactoryGirl.create(:buergschaft_with_buerge_and_glaeubiger_and_zeKonto)).to be_valid
	end

	# Valid/invalid attributes
	# Pnr_B
	it "is valid with a valid Pnr_B"
	it "is invalid without a Pnr_B"
	it "is invalid with an invalid Pnr_B"

	# Mnr_G
	it "is valid with a valid Mnr_B"
	it "is invalid without a Mnr_B"
	it "is invalid with an invalid Mnr_B"

	# SachPnr
	it "is valid with a valid SachPnr"
	it "is valid without a SachPnr"
	it "is invalid with an invalid SachPnr"

	# ZENr
	it "is valid with a valid ZENr"
	it "is invalid without a ZENr"
	it "is invalid with an invalid ZENr"

	# SichKurzbez, is it an enum = {Einzelbuergschaft, Teilbuergschaft} or not?
	it "SichKurzbez, is it an enum = {Einzelbuergschaft, Teilbuergschaft} or not?"

	# due to issues, i dont know if SichAbDatum or SichEndDatum or SichBetrag is mandatory or not
	it "due to issues, i dont know if SichAbDatum or SichEndDatum or SichBetrag is mandatory or not"

	# Class and instance methods
	# validate(bName, gName)
	it "returns no error, if buerger and glaeubiger exists"
	it "returns errors, if neither a buerger or glaeubiger exists"

	# find_by_name(lastname, firstname)
	it "returns the pnr of an existing person, given by his first- and lastname"
	it "returns 0, if the person, given by a first- and lastname, does not exist in the database"

	# set_valid_time
	it "sets the valid time to GueltigVon = now and GueltigBis = 9999-12-31 23:59:59"
	it "does not set the valid time, if it is already set"

	# set_new_valid_time
	it "sets the valid time of the new copy to GueltigVon = self.GueltigVon and GueltigBis = Time.now and updates himself to the latest record"
	it "does not set the valid time of the new copy, if the Kontonummer not exists"

	# get(pnr_b, mnr_g, date = Time.now)
	it "returns the Buergschaft for a valid Buerger, Glauebiger and date (=now)"
	it "returns the Buergschaft for a valid Buerger, Glauebiger and date (=now - 2 seconds)"
	it "returns nil, if there is no Buergschaft for a Buerger and Glauebiger and date"

	# self.latest(pnr_b, mnr_g)
	it "returns the latest version of a given OZBKonto, for a valid Buerger and Glauebiger" 
	it "returns nil, if there is no OZBKonto for a Buerger and Glauebiger"

end