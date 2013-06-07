require 'faker'

FactoryGirl.define do

	factory :Bank do
		sequence(:BLZ) { |n| "#{n*10000000}"}
		BIC nil
		BankName Faker::Name.name
	end

end