require 'faker'

FactoryGirl.define do
	factory :Waehrung do
    Code {(0...3).map{(65+rand(26)).chr}.join}
   	Bezeichnung "Stuttgarter"
	end
end