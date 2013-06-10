require 'faker'

FactoryGirl.define do

	factory :ZeKonto do
		sequence(:ktoNr) {|n| "#{n}"} 
		sequence(:eeKtoNr) {|n| "#{n}"}
		sequence(:laufzeit) {|n| "#{n}"}
		sequence(:pgnr) {|n| "#{n}"}
		zahlModus "M"
		tilgRate 100.00
		ansparRate 20.00
		kduRate 5.00
		rduRate 5.00
		zeStatus "A"
	end

end