require 'spec_helper'

describe DarlehensverlaufController do

	# GET Requests
	# new
	describe "GET #new" do
		before :each do
			# load data of the test-db into the tdd db
			 `sh script/datenbank_tdd_migrieren.sh`
		end

		# create test data for EEKonto 70073		
		context "Show Darlehensverlauf of EEKonto 70073" do
			context "parameters: anzeigen, vonDatum and bisDatum are nil" do
				it "returns the 10 latest buchungen" do
					latest_ten_bookings = Buchung.where("KtoNr = ?", 70073).order("Belegdatum DESC, Typ DESC, PSaldoAcc DESC, SollBetrag").limit(10).reverse
					expect(latest_ten_bookings.size).to eq 10

					preFirstBooking = Buchung.where("KtoNr = ? AND BuchJahr = ? AND BnKreis = ? AND BelegNr = ? AND Typ = ?", 70073, 2012, "B-", 652, "w").first
					expect(preFirstBooking.nil?).to eq false

					# create first row in the overview
					tagessaldoBeginW = 1895.24
					tagessaldoBeginP = 21690

					tagessaldoEndW = -474.16

					# only for today, 2013-06-13
					tagessaldoEndP = 17081


					# create points
					lastCurrencyBooking = Buchung.where("KtoNr = ? AND BuchJahr = ? AND BnKreis = ? AND BelegNr = ? AND Typ = ?", 70073, 2013, "U-", 56, "w").first
					expect(lastCurrencyBooking.nil?).to eq false

					diffTage = (Time.now.to_date - lastCurrencyBooking.Belegdatum.to_date).to_i
					# kkl = B => 0.75
					kkl = 0.75
      				pointsInInterval = ((diffTage * tagessaldoEndW) / 30) * kkl

					# Get output from website
					get :new, :KtoNr => 70073, :EEoZEkonto => "EE"

					# expects 12 buchgungen
					expect(assigns(:Buchungen).size).to eq 12
					# expect same order
					# TODO

					# test first and last row
					# first (tagessaldo)
					expect(assigns(:vorherigeBuchung)).to eq preFirstBooking
					expect(assigns(:Buchungen).first.Sollbetrag).to eq tagessaldoBeginW 
					expect(assigns(:Buchungen).first.PSaldoAcc).to eq tagessaldoBeginP

					# last (reached points, WSaldo)
					expect(assigns(:bisDatum)).to eq Time.now.strftime("%d.%m.%Y")
					expect(assigns(:letzteWaehrungsBuchung)).to eq lastCurrencyBooking
					expect(assigns(:punkteImIntervall).to_f.round(2)).to eq pointsInInterval.to_f.round(2)
					expect(assigns(:differenzSollHaben).to_f.round(2)).to eq tagessaldoEndW.to_f.round(2)
					expect(assigns(:summeDerPunkte).to_f.round(0)).to eq tagessaldoEndP.round(0)
				end

				it "renders the correct view" do
					get :new, :KtoNr => 70073, :EEoZEkonto => "EE"
					expect(response).to render_template :new
				end
			end

			context "from 01.11.2010 - 05.12.2010" do
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