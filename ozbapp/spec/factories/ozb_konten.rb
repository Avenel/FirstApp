require 'faker'

FactoryGirl.define do

	factory :OzbKonto do
		sequence(:KtoNr) {|n| "#{10000+n}"} 
		sequence(:Mnr) {|n| "#{n}"}
		sequence(:SachPnr) {|n| "#{n}"}
		KtoEinrDatum Time.now
		WSaldo 0
		PSaldo 0
		SaldoDatum Time.now

		factory :ozbkonto_with_ozbperson do
			before(:create) do |ozbkonto|
				ozbperson = FactoryGirl.create(:ozbperson_with_person)
				sachPerson = FactoryGirl.create(:ozbperson_with_person)
				ozbkonto.Mnr = ozbperson.Mnr
				ozbkonto.SachPnr = sachPerson.Mnr
				ozbkonto.WaehrungID = FactoryGirl.create(:Waehrung).Code
			end
		end

		factory :ozbkonto_with_waehrung do
			before(:create) do |ozbkonto|
				ozbkonto.WaehrungID = FactoryGirl.create(:Waehrung).Code
			end
		end


	end

end