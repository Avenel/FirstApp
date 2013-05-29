require 'faker'

FactoryGirl.define do
	factory :Person do
		sequence(:Pnr) {|n| "#{n}" }
		Name {Faker::Name.first_name}
		Vorname {Faker::Name.last_name}
		Rolle "P"
		EMail {Faker::Internet.email}
	end
end