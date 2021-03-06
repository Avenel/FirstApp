require 'faker'

FactoryGirl.define do

	factory :Bankverbindung do
		sequence(:ID){ |n| "#{n}" }
		sequence(:BankKtoNr) { |n| "#{n*100000000000}" }
		IBAN "DE12500105170648489890"
		
		factory :bankverbindung_with_bank do
			before(:create) do |bankverbindung|
				bank = FactoryGirl.create(:Bank)
				bankverbindung.BLZ = bank.BLZ
			end
		end

		factory :bankverbindung_with_person do
			before(:create) do |bankverbindung|
				person = FactoryGirl.create(:Person)
				bankverbindung.Pnr = person.Pnr
			end	
		end

		factory :bankverbindung_with_bank_and_person do
			before(:create) do |bankverbindung|
				person = FactoryGirl.create(:Person)
				bankverbindung.Pnr = person.Pnr

				bank = FactoryGirl.create(:Bank)
				bankverbindung.BLZ = bank.BLZ
			end
		end
	end

end