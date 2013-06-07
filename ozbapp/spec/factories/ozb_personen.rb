require 'faker'

FactoryGirl.define do 
	factory :OZBPerson do 
		sequence(:mnr) {|n| "#{n}"}
		sequence(:ueberPnr) {|n| "#{n}"}
		Antragsdatum Time.now
		email {Faker::Internet.email}
		password "helloWorld123"


		factory :ozbperson_with_person do
			before(:create) do |ozbperson|
				person = FactoryGirl.create(:Person)
				ozbperson.mnr = person.pnr
				ozbperson.ueberPnr = person.pnr
			end
		end

		factory :ozbperson_with_ozbkonto do
			before(:create) do |ozbperson|
				person = FactoryGirl.create(:Person)
				ozbperson.mnr = person.pnr
				ozbperson.ueberPnr = person.pnr
			end

			after(:create) do |ozbperson|
				FactoryGirl.create(:OzbKonto, :mnr => ozbperson.mnr)
			end
		end

	end
end