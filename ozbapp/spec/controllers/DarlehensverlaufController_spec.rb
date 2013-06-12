require 'spec_helper'

describe DarlehensverlaufController do

	# GET Requests
	# new
	describe "GET #new" do
		context "EEKonto 70074" do
			# create test data for EEKonto 70074
			before :each do
			end

			context "Show from 01.11.2010 - 05.12.2010" do
			end
		end

		context "ZEKonto 10073" do
			# create test data for EEKonto 10073
			before :each do
			end

			context "Show from 15.08.2011 - 15.02.2012" do
			end
		end
	end

	# kontoauszug
	# kontoauszug does the same as the methode new.
	# the only difference is, it renders a different template
	# therefore it should be fine, to test if the correct template has been rendered.
	describe "GET #kontoauszug" do
	end

	# Class and instance methods	
	describe "Class and instance methods" do

		# getKKL(ktoNr)
		context "getKKL(ktoNr)" do
			# create test data
			before :each do
			end

			it "returns 1, if given valid Konto is related to KKL: 'A'"
			it "returns 0.75, if given valid Konto is related to KKL: 'B'"
			it "returns 0.5, if given valid Konto is related to KKL: 'C'"
			it "returns 0.25, if given valid Konto is related to KKL: 'D'"
			it "returns 0.00, if given valid Konto is related to KKL: 'E'"
			it "retuns 0, if given Konto does not exists"
		end

		# checkReuse(ktoNr, vonDatum, kontoTyp)
		context "checkReuse(ktoNr, vonDatum, kontoTyp)" do
			# create test data
			before :each do
			end

			it "returns true, if a valid ZEKonto was reused before a given date"
			it "returns false, if a valid ZEKonto was not reused before a given date"
			it "returns false, if the given OZBKonto does not exists"
			it "returns false, if the given OZBKonto  is not a ZEKonto"
		end

		# findLastResetBooking(ktoNr)
		context "findLastResetBooking(ktoNr)" do
			# create test data
			before :each do
			end

			it "returns the booking, which indicated a reuse for a given valid ZEKonto"
			it "returns nil, if there is no booking, which indicates a reuse for al given valid ZEKonto"
			it "returns nil, if the given OZBKonzo does not exists"
			it "returns nil, if the given OZBKonto is not a ZEKonto"
		end

	end
	

	

end