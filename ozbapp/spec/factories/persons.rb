require 'faker'

FactoryGirl.define do
	factory :person do
		sequence(:pnr) {|n| "#{n}" }
		Name {Faker::Name.first_name}
		Vorname {Faker::Name.last_name}
		Rolle Person::AVAILABLE_ROLES[0]
		email {Faker::Internet.email}
	end
end