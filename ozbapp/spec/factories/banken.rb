require 'faker'

FactoryGirl.define do

	factory :Bank do
		sequence(:BLZ) { |n| "#{(n*10000000).to_s[0, 8]}"}
		BIC nil
		BankName Faker::Name.name
	end

end