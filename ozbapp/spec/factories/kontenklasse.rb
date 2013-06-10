require 'faker'

FactoryGirl.define do

	factory :Kontenklasse do
		KKL "0"
		KKLAbDatum Date.today
		Prozent 0.00

		factory :kontenklasse_A do
			KKL "1"
			Prozent 100.00
		end

		factory :kontenklasse_B do
			KKL "2"
			Prozent 75.00
		end

		factory :kontenklasse_C do
			KKL "3"
			Prozent 50.00
		end

		factory :kontenklasse_D do
			KKL "4"
			Prozent 25.00
		end
	end
end