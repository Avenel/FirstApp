require 'faker'

FactoryGirl.define do

	factory :KklVerlauf do
		sequence(:KtoNr) {|n| "#{n}"} 
		KKLAbDatum = Date.today
		sequence(:KKL) {|n| "#{n}"}

		factory :kklverlauf_with_ozbkonto_with_kontenklasse do
			before(:create) do |kklverlauf|
				ozbkonto = FactoryGirl.create(:ozbkonto_with_ozbperson)
				kontenklasse = FactoryGirl.create(:kontenklasse_A)
				kklverlauf.KtoNr = ozbkonto.ktoNr
				kklverlauf.kkl = kontenklasse.kkl
			end
		end
	end

end