require 'faker'

FactoryGirl.define do

	factory :Buchung do
		sequence(:BuchJahr) { |n| "#{2000+n}"}
		sequence(:KtoNr) {|n| "#{42680+10*n}"} 
		sequence(:BnKreis) {|n| "#{n}"} 
		sequence(:BelegNr) {|n| "#{n}"} 
		sequence(:Typ) {|n| "#{n}"} 
		Belegdatum Date.today 
		BuchDatum Date.today
		Buchungstext "Some dummy text"
		Sollbetrag 0
		Habenbetrag 0
		sequence(:SollKtoNr) {|n| "#{42681+10*n}"}  
		sequence(:HabenKtoNr) {|n| "#{42682+10*n}"}  
		WSaldoAcc 0
		Punkte 0
		PSaldoAcc 0

		factory :buchung_with_ozbkonten do
			before(:create) do |buchung|
				ozbkonto = FactoryGirl.create(:ozbkonto_with_ozbperson)
				ozbkonto_soll = FactoryGirl.create(:ozbkonto_with_ozbperson)
				ozbkonto_haben = FactoryGirl.create(:ozbkonto_with_ozbperson)

				buchung.KtoNr = ozbkonto.ktoNr
				buchung.SollKtoNr = ozbkonto_soll.ktoNr
				buchung.HabenKtoNr = ozbkonto_haben.ktoNr
			end
		end

		factory :buchung_without_ozbkonto do
			before(:create) do |buchung|
				ozbkonto_soll = FactoryGirl.create(:ozbkonto_with_ozbperson)
				ozbkonto_haben = FactoryGirl.create(:ozbkonto_with_ozbperson)

				buchung.SollKtoNr = ozbkonto_soll.ktoNr
				buchung.HabenKtoNr = ozbkonto_haben.ktoNr
			end
		end

		factory :buchung_without_ozbkonto_soll do
			before(:create) do |buchung|
				ozbkonto = FactoryGirl.create(:ozbkonto_with_ozbperson)
				ozbkonto_haben = FactoryGirl.create(:ozbkonto_with_ozbperson)

				buchung.KtoNr = ozbkonto.ktoNr
				buchung.HabenKtoNr = ozbkonto_haben.ktoNr
			end
		end

		factory :buchung_without_ozbkonto_haben do
			before(:create) do |buchung|
				ozbkonto = FactoryGirl.create(:ozbkonto_with_ozbperson)
				ozbkonto_soll = FactoryGirl.create(:ozbkonto_with_ozbperson)
				
				buchung.KtoNr = ozbkonto.ktoNr
				buchung.SollKtoNr = ozbkonto_soll.ktoNr
			end
		end
	end

end