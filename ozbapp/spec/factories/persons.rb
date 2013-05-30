require 'faker'

FactoryGirl.define do
	factory :Person do
		sequence(:pnr) {|n| "#{n}" }
		name {Faker::Name.first_name}
		vorname {Faker::Name.last_name}
		rolle "P"
		email {Faker::Internet.email}

		factory :person_with_ozbperson do 
			after(:create) do |person|
				FactoryGirl.create(:OZBPerson, :mnr => person.pnr, :ueberPnr => person.pnr)
			end
		end

	end
end