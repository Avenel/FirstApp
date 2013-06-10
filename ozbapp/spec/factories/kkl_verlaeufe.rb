require 'faker'

FactoryGirl.define do

	factory :KklVerlauf do
		sequence(:ktoNr) {|n| "#{n}"} 
		KKLAbDatum = Date.today
		sequence(:KKL) {|n| "#{n}"}
	end

end