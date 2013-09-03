require 'faker'

FactoryGirl.define do

	factory :Kontenklasse do
		KKL "A"
		KKLEinrDatum Date.today
		Prozent 0.00

		factory :kontenklasse_A do
			KKL "A"
			Prozent 100.00
		end

		factory :kontenklasse_B do
			KKL "B"
			Prozent 75.00
		end

		factory :kontenklasse_C do
			KKL "C"
			Prozent 50.00
		end

		factory :kontenklasse_D do
			KKL "D"
			Prozent 25.00
		end
	end
end