require 'faker'

FactoryGirl.define do

	factory :Buchung do
		sequence(:BuchJahr) { |n| "#{2000+n}"}
		sequence(:KtoNr) {|n| "#{n}"} 
		sequence(:BnKreis) {|n| "#{n}"} 
		sequence(:BelegNr) {|n| "#{n}"} 
		sequence(:Typ) {|n| "#{n}"} 
		Belegdatum Date.today 
		BuchDatum Date.today
		Buchungstext "Some dummy text"
		Sollbetrag 0
		Habenbetrag 0
		sequence(:SollKtoNr) {|n| "#{n}"}  
		sequence(:HabenKtoNr) {|n| "#{n}"}  
		WSaldoAcc 0
		Punkte 0
		PSaldoAcc 0

		factory :buchung_with_ozbkonten do
			before(:create) do |buchung|
				ozbkonto = FactoryGirl.create(:ozbkonto_with_ozbperson, :ktoNr => 42689)
				ozbkonto_soll = FactoryGirl.create(:ozbkonto_with_ozbperson, :ktoNr => 42688)
				ozbkonto_haben = FactoryGirl.create(:ozbkonto_with_ozbperson, :ktoNr => 42687)

				buchung.KtoNr = ozbkonto.ktoNr
				buchung.SollKtoNr = ozbkonto_soll.ktoNr
				buchung.HabenKtoNr = ozbkonto_haben.ktoNr
			end
		end
	end

end