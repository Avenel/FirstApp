require 'faker'

FactoryGirl.define do

	factory :KklVerlauf do
		sequence(:KtoNr) {|n| "#{n}"} 
		sequence(:KKL) {|n| "#{n}"}
		KKLAbDatum Date.today

		factory :kklverlauf_with_ozbkonto_with_kontenklasse do
			before(:create) do |kklverlauf|
				ozbkonto = FactoryGirl.create(:ozbkonto_with_ozbperson, :KtoNr => 12345)
				kontenklasse = FactoryGirl.create(:kontenklasse_A)
				kklverlauf.KtoNr = ozbkonto.KtoNr
				kklverlauf.KKL = kontenklasse.KKL
			end
		end

		factory :kklverlauf_with_kontenklasse do
			before(:create) do |kklverlauf|
				kontenklasse = FactoryGirl.create(:kontenklasse_B)
				kklverlauf.KKL = kontenklasse.KKL
			end
		end

		factory :kklverlauf_with_ozbkonto do
			before(:create) do |kklverlauf|
				ozbkonto = FactoryGirl.create(:ozbkonto_with_ozbperson, :KtoNr => 31337)
				kklverlauf.KtoNr = ozbkonto.KtoNr
			end
		end
	end

end