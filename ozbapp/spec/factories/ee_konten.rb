require 'faker'

FactoryGirl.define do

	factory :EeKonto do
		sequence(:KtoNr) {|n| "#{n}"} 
		sequence(:BankID) {|n| "#{n}"} 
		sequence(:SachPnr) {|n| "#{n}"}
		Kreditlimit 42000


		factory :eekonto_with_ozbkonto_and_sachPerson_and_bankverbindung do
			before(:create) do |eeKonto|
				ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson)
				sachPerson = FactoryGirl.create(:ozbperson_with_person)
				bankverbindung = FactoryGirl.create(:bankverbindung_with_bank, :Pnr => ozbKonto.Mnr)
				eeKonto.KtoNr = ozbKonto.KtoNr
				eeKonto.SachPnr = sachPerson.Mnr
				eeKonto.BankID = bankverbindung.ID
			end
		end

		factory :eekonto_with_sachPerson_and_bankverbindung do
			before(:create) do |eeKonto|
				sachPerson = FactoryGirl.create(:ozbperson_with_person)
				bankverbindung = FactoryGirl.create(:bankverbindung_with_bank_and_person)
				eeKonto.SachPnr = sachPerson.Mnr
				eeKonto.BankID = bankverbindung.ID
			end
		end

		factory :eekonto_with_sachPerson do
			before(:create) do |eeKonto|
				sachPerson = FactoryGirl.create(:ozbperson_with_person)
				eeKonto.SachPnr = sachPerson.Mnr
			end
		end

	end

end