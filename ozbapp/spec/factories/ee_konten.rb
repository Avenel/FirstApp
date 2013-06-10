require 'faker'

FactoryGirl.define do

	factory :EeKonto do
		sequence(:ktoNr) {|n| "#{n}"} 
		sequence(:bankId) {|n| "#{n}"} 
		sequence(:SachPnr) {|n| "#{n}"} 


		factory :eekonto_with_ozbkonto_and_sachPerson_and_bankverbindung do
			before(:create) do |eeKonto|
				ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson)
				sachPerson = FactoryGirl.create(:ozbperson_with_person)
				bankverbindung = FactoryGirl.create(:bankverbindung_with_bank, :pnr => ozbKonto.mnr)
				eeKonto.ktoNr = ozbKonto.ktoNr
				eeKonto.sachPnr = sachPerson.mnr
				eeKonto.bankId = bankverbindung.id
			end
		end

		factory :eekonto_with_sachPerson do
			before(:create) do |eeKonto|
				sachPerson = FactoryGirl.create(:ozbperson_with_person)
				eeKonto.sachPnr = sachPerson.mnr
			end
		end

	end

end