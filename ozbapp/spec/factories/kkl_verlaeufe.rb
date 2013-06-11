require 'faker'

FactoryGirl.define do

	factory :KklVerlauf do
		sequence(:KtoNr) {|n| "#{n}"} 
		sequence(:KKL) {|n| "#{n}"}

		factory :kklverlauf_with_ozbkonto_with_kontenklasse do
			before(:create) do |kklverlauf|
				ozbkonto = FactoryGirl.create(:ozbkonto_with_ozbperson, :ktoNr => 12345)
				kontenklasse = FactoryGirl.create(:kontenklasse_A)
				kklverlauf.KtoNr = ozbkonto.ktoNr
				kklverlauf.kkl = kontenklasse.kkl
			end
		end

		factory :kklverlauf_with_kontenklasse do
			before(:create) do |kklverlauf|
				kontenklasse = FactoryGirl.create(:kontenklasse_B)
				kklverlauf.kkl = kontenklasse.kkl
			end
		end

		factory :kklverlauf_with_ozbkonto do
			before(:create) do |kklverlauf|
				ozbkonto = FactoryGirl.create(:ozbkonto_with_ozbperson, :ktoNr => 31337)
				kklverlauf.KtoNr = ozbkonto.ktoNr
			end
		end
	end

end