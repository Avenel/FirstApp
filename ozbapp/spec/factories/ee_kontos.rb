require 'faker'

FactoryGirl.define do

	factory :EEKonto do
		sequence(:ktoNr) {|n| "#{n}"} 
		sequence(:mnr) {|n| "#{n}"}
		sequence(:SachPnr) {|n| "#{n}"}
		ktoEinrDatum Time.now
		waehrung "STR"
		wSaldo 0
		pSaldo 0
		saldoDatum Time.now

		factory :eekonto_with_ozbkonto_with_ozbperson do
			before(:create) do |ozbkonto|
				ozbperson = FactoryGirl.create(:ozbperson_with_person)
				sachPerson = FactoryGirl.create(:ozbperson_with_person)
				ozbkonto.mnr = ozbperson.mnr
				ozbkonto.SachPnr = sachPerson.mnr
			end
		end

	end

end