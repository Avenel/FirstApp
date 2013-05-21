require 'faker'

FactoryGirl.define do
	factory :person do
		Name {Faker::Name.first_name}
		Vorname {Faker::Name.last_name}
		Rolle "P"
		email {Faker::Internet.email}
	end
end