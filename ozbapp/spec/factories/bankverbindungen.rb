require 'faker'

FactoryGirl.define do

	factory :Bankverbindung do
		sequence(:id){ |n| "#{n}" }
		sequence(:BankKtoNr) { |n| "#{n*100000000000}" }
		
		factory :bankverbindung_with_bank do
			before(:create) do |bankverbindung|
				bank = FactoryGirl.create(:Bank)
				bankverbindung.BLZ = bank.BLZ
			end
		end

		factory :bankverbindung_with_person do
			before(:create) do |bankverbindung|
				person = FactoryGirl.create(:Person)
				bankverbindung.pnr = person.pnr
			end	
		end

		factory :bankverbindung_with_bank_and_person do
			before(:create) do |bankverbindung|
				person = FactoryGirl.create(:Person)
				bankverbindung.pnr = person.pnr

				bank = FactoryGirl.create(:Bank)
				bankverbindung.BLZ = bank.BLZ
			end
		end
	end

end