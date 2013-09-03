require 'faker'

FactoryGirl.define do 
	factory :OZBPerson do 
		sequence(:Mnr) {|n| "#{n+400}"}
		sequence(:UeberPnr) {|m| "#{m+400}"}
		Antragsdatum Time.now


		factory :ozbperson_with_person do
			before(:create) do |ozbperson|
				person = FactoryGirl.create(:Person)
				ozbperson.Mnr = person.Pnr
				ozbperson.UeberPnr = person.Pnr
			end
		end

		factory :ozbperson_with_ozbkonto do
			before(:create) do |ozbperson|
				person = FactoryGirl.create(:Person)
				ozbperson.Mnr = person.Pnr
				ozbperson.UeberPnr = person.Pnr
			end

			after(:create) do |ozbperson|
				FactoryGirl.create(:OzbKonto, :Mnr => ozbperson.Mnr)
			end
		end

	end
end