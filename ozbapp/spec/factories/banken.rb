require 'faker'

FactoryGirl.define do

	factory :Bank do
		sequence(:BLZ) { |n| "#{(n*10000000).to_s[0, 8]}"}
		sequence(:BIC) { |n| "#{(n*10000000).to_s[0, 8]}"}
		BankName Faker::Name.name
	end

end