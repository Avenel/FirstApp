require 'spec_helper'

describe DarlehensverlaufController do

	# GET Requests
	# new
	describe "GET #new" do
		before :each do
			# load data of the test-db into the tdd db
			 #`script/datenbank_tdd_migrieren.bat`
		end

		# create test data for EEKonto 70073		
		context "Show Darlehensverlauf of EEKonto 70073" do
			context "parameters: anzeigen, vonDatum and bisDatum are nil" do
				it "returns the 10 latest buchungen" do
					preFirstBooking = Buchung.where("KtoNr = ? AND BuchJahr = ? AND BnKreis = ? AND BelegNr = ? AND Typ = ?", 70073, 2012, "B-", 652, "w").first
					expect(preFirstBooking.nil?).to eq false

					# create first row in the overview
					tagessaldoBeginW = 1895.24
					tagessaldoBeginP = 21690

					tagessaldoEndW = -274.16

					# create points
					lastCurrencyBooking = Buchung.where("KtoNr = ? AND BuchJahr = ? AND BnKreis = ? AND BelegNr = ? AND Typ = ?", 70073, 2013, "B-", 80, "w").first
					expect(lastCurrencyBooking.nil?).to eq false

					diffTage = (Time.now.to_date - lastCurrencyBooking.Belegdatum.to_date).to_i
					# kkl = B => 0.75
					kkl = 0.75
      				pointsInInterval = ((diffTage * tagessaldoEndW) / 30) * kkl

					# calculate correct points
					tagessaldoEndP = tagessaldoBeginP + pointsInInterval

					buchungen = Buchung.where("KtoNr = ? AND Belegdatum > ? AND Belegdatum <= ?", 70073, 
											"2012-11-02", Time.now).order("BelegDatum ASC, Typ ASC, Punkte DESC")
					
					buchungen.each do |b|
						tagessaldoEndP += b.Punkte
					end


					# Get output from website
					get :new, :KtoNr => 70073, :EEoZEkonto => "EE"

					# expects 13 buchgungen
					expect(assigns(:Buchungen).size).to eq 13

					# test first and last row
					# first (tagessaldo)
					expect(assigns(:vorherigeBuchung)).to eq preFirstBooking
					expect(assigns(:Buchungen).first.Sollbetrag).to eq tagessaldoBeginW 
					expect(assigns(:Buchungen).first.Punkte).to eq tagessaldoBeginP

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
				it "shows bookings from 01.11.2010 to 05.12.2010 and correct points and saldi" do
					preFirstBooking = Buchung.where("KtoNr = ? AND BuchJahr = ? AND BnKreis = ? AND BelegNr = ? AND Typ = ?", 70073, 2010, "B-", 648, "w").first
					expect(preFirstBooking.nil?).to eq false

					# create first and last row in the overview
					tagessaldoBeginW = 1600
					tagessaldoBeginP = 34347

					tagessaldoEndW = 250
					tagessaldoEndP = -5110

					lastCurrencyBooking = Buchung.where("KtoNr = ? AND BuchJahr = ? AND BnKreis = ? AND BelegNr = ? AND Typ = ?", 70073, 2010, "B-", 799, "w").first
					expect(lastCurrencyBooking.nil?).to eq false

					diffTage = (Time.zone.local(2010,12,5,0,0).to_date - lastCurrencyBooking.Belegdatum.to_date).to_i
					# kkl = B => 0.75
					kkl = 0.75
      				pointsInInterval = ((diffTage * tagessaldoEndW) / 30) * kkl

					# Get output from website
					get :new, :KtoNr => 70073, :EEoZEkonto => "EE", :vonDatum => "01.11.2010", :bisDatum => "05.12.2010"

					# expects 13 buchgungen
					expect(assigns(:Buchungen).size).to eq 7

					# test first and last row
					# first (tagessaldo)
					expect(assigns(:vorherigeBuchung)).to eq preFirstBooking
					expect(assigns(:Buchungen).first.Habenbetrag).to eq tagessaldoBeginW 
					expect(assigns(:Buchungen).first.Punkte).to eq tagessaldoBeginP

					# last (reached points, WSaldo)
					expect(assigns(:vonDatum)).to eq "01.11.2010"
					expect(assigns(:bisDatum)).to eq "05.12.2010"
					expect(assigns(:letzteWaehrungsBuchung)).to eq lastCurrencyBooking
					expect(assigns(:punkteImIntervall).to_f.round(2).floor).to eq pointsInInterval.to_f.round(2).floor
					expect(assigns(:differenzSollHaben).to_f.round(2).floor).to eq tagessaldoEndW.to_f.round(2).floor
					expect(assigns(:summeDerPunkte).to_f.ceil).to eq tagessaldoEndP.round(0)
				end
			end
		end

		context "ZEKonto 10073 [Reused]" do
			# create test data for ZEKonto 10073
			before :each do
				# load data of the test-db into the tdd db
			 	#`script/datenbank_tdd_migrieren.bat`
			end

			context "Show from 15.08.2011 - 15.02.2012" do
				it "shows bookings from 15.08.2011 to 15.12.2012 and correct points and saldi" do
					preFirstBooking = Buchung.where("KtoNr = ? AND BuchJahr = ? AND BnKreis = ? AND BelegNr = ? AND Typ = ?", 10073, 2011, "U-", 588, "w" ).first
					expect(preFirstBooking.nil?).to eq false

					# create first and last row in the overview
					tagessaldoBeginW = 2100
					tagessaldoBeginP = -22555

					tagessaldoEndW = -1312.50
					tagessaldoEndP = -32987

					lastCurrencyBooking = Buchung.where("KtoNr = ? AND BuchJahr = ? AND BnKreis = ? AND BelegNr = ? AND Typ = ?", 10073, 2012, "U-", 141, "w").first
					expect(lastCurrencyBooking.nil?).to eq false

					diffTage = (Time.zone.local(2012,02,15,0,0).to_date - lastCurrencyBooking.Belegdatum.to_date).to_i
					# kkl = A => 1.0
					kkl = 1.0
      				pointsInInterval = ((diffTage * tagessaldoEndW) / 30) * kkl

					# Get output from website
					get :new, :KtoNr => 10073, :EEoZEkonto => "ZE", :vonDatum => "15.08.2011", :bisDatum => "15.02.2012"

					# expects 8 buchgungen
					expect(assigns(:Buchungen).size).to eq 8

					# test first and last row
					# first (tagessaldo)
					expect(assigns(:vorherigeBuchung)).to eq preFirstBooking
					expect(assigns(:Buchungen).first.Sollbetrag).to eq tagessaldoBeginW 
					expect(assigns(:Buchungen).first.Punkte).to eq tagessaldoBeginP

					# last (reached points, WSaldo)
					expect(assigns(:vonDatum)).to eq "15.08.2011"
					expect(assigns(:bisDatum)).to eq "15.02.2012"
					expect(assigns(:letzteWaehrungsBuchung)).to eq lastCurrencyBooking
					expect(assigns(:differenzSollHaben).to_f.round(2).floor).to eq tagessaldoEndW.to_f.round(2).floor
					expect(assigns(:punkteImIntervall).to_f.round(2).floor).to eq pointsInInterval.to_f.round(2).floor
					expect(assigns(:summeDerPunkte).to_f.round(0)).to eq tagessaldoEndP.round(0)
				end
			end
		end

		context "ZEKonto 10038 [Reused]" do
			# create test data for ZEKonto 10073
			before :each do
				# load data of the test-db into the tdd db
			 	#`script/datenbank_tdd_migrieren.bat`
			end

			it "shows bookings from 02.02.2011 to 16.11.2012 and correct points and saldi" do
				preFirstBooking = Buchung.where("KtoNr = ? AND BuchJahr = ? AND BnKreis = ? AND BelegNr = ? AND Typ = ?", 10038, 2010, "U-", 518, "w" ).first
				expect(preFirstBooking.nil?).to eq false

				# create first and last row in the overview
				tagessaldoBeginW = 0
				tagessaldoBeginP = 0

				tagessaldoEndW = -6499.93
				tagessaldoEndP = -177644

				lastCurrencyBooking = Buchung.where("KtoNr = ? AND BuchJahr = ? AND BnKreis = ? AND BelegNr = ? AND Typ = ?", 10038, 2012, "U-", 692, "w").first
				expect(lastCurrencyBooking.nil?).to eq false

				diffTage = (Time.zone.local(2012,11,16,0,0).to_date - lastCurrencyBooking.Belegdatum.to_date).to_i
				# kkl = A => 1.0
				kkl = 1.0
  				pointsInInterval = ((diffTage * tagessaldoEndW) / 30) * kkl

				# Get output from website
				get :new, :KtoNr => 10038, :EEoZEkonto => "ZE", :vonDatum => "02.02.2011", :bisDatum => "16.11.2012"

				# expects 24 buchgungen
				expect(assigns(:Buchungen).size).to eq 24

				# test first and last row
				# first (tagessaldo)
				expect(assigns(:vorherigeBuchung)).to eq preFirstBooking
				expect(assigns(:Buchungen).first.Sollbetrag).to eq tagessaldoBeginW 
				expect(assigns(:Buchungen).first.Punkte).to eq tagessaldoBeginP

				# last (reached points, WSaldo)
				expect(assigns(:vonDatum)).to eq "02.02.2011"
				expect(assigns(:bisDatum)).to eq "16.11.2012"
				expect(assigns(:letzteWaehrungsBuchung)).to eq lastCurrencyBooking
				expect(assigns(:differenzSollHaben).to_f.round(2).floor).to eq tagessaldoEndW.to_f.round(2).floor
				expect(assigns(:punkteImIntervall).to_f.round(2).floor).to eq pointsInInterval.to_f.round(2).floor
				expect(assigns(:summeDerPunkte).to_f.round(0)).to eq tagessaldoEndP.round(0)
			end
			
			it "shows bookings from 15.03.2011 to 16.11.2012 and correct points and saldi" do
				preFirstBooking = Buchung.where("KtoNr = ? AND BuchJahr = ? AND BnKreis = ? AND BelegNr = ? AND Typ = ?", 10038, 2011, "U-", 184, "w" ).first
				expect(preFirstBooking.nil?).to eq false

				# create first and last row in the overview
				tagessaldoBeginW = 9833.33	
				tagessaldoBeginP = -11254

				tagessaldoEndW = -6499.93
				tagessaldoEndP = -177643

				lastCurrencyBooking = Buchung.where("KtoNr = ? AND BuchJahr = ? AND BnKreis = ? AND BelegNr = ? AND Typ = ?", 10038, 2012, "U-", 692, "w").first
				expect(lastCurrencyBooking.nil?).to eq false

				diffTage = (Time.zone.local(2012,11,16,0,0).to_date - lastCurrencyBooking.Belegdatum.to_date).to_i
				# kkl = A => 1.0
				kkl = 1.0
  				pointsInInterval = ((diffTage * tagessaldoEndW) / 30) * kkl

				# Get output from website
				get :new, :KtoNr => 10038, :EEoZEkonto => "ZE", :vonDatum => "15.03.2011", :bisDatum => "16.11.2012"

				# expects 22 buchgungen
				expect(assigns(:Buchungen).size).to eq 22

				# test first and last row
				# first (tagessaldo)
				expect(assigns(:vorherigeBuchung)).to eq preFirstBooking
				expect(assigns(:Buchungen).first.Sollbetrag).to eq tagessaldoBeginW 
				expect(assigns(:Buchungen).first.Punkte).to eq tagessaldoBeginP

				# last (reached points, WSaldo)
				expect(assigns(:vonDatum)).to eq "15.03.2011"
				expect(assigns(:bisDatum)).to eq "16.11.2012"
				expect(assigns(:letzteWaehrungsBuchung)).to eq lastCurrencyBooking
				expect(assigns(:differenzSollHaben).to_f.round(2).floor).to eq tagessaldoEndW.to_f.round(2).floor
				expect(assigns(:punkteImIntervall).to_f.round(2).floor).to eq pointsInInterval.to_f.round(2).floor
				expect(assigns(:summeDerPunkte).to_f.round(0)).to eq tagessaldoEndP.round(0)
			end
		end
	end

	# kontoauszug
	# kontoauszug does the same as the methode new.
	# the only difference is, it renders a different template
	# therefore it should be fine, to test if the correct template has been rendered.
	describe "GET #kontoauszug" do
		it "renders the correct template" do
			get :kontoauszug, :KtoNr => 73013, :EEoZEkonto => "ZE", :vonDatum => "01.03.2011", :bisDatum => "01.11.2011", 
								:name => "Tassilo", :vName => "Kienle"
			expect(response).to render_template :kontoauszug
		end
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