require 'faker'

FactoryGirl.define do

	factory :ZeKonto do
		sequence(:ktoNr) {|n| "#{n}"} 
		sequence(:eeKtoNr) {|n| "#{n}"}
		sequence(:laufzeit) {|n| "#{n}"}
		sequence(:pgNr) {|n| "#{n}"}
		sequence(:zeNr) {|n| "D#{n}"} 
		zahlModus "M"
		tilgRate 100.00
		ansparRate 20.00
		kduRate 5.00
		rduRate 5.00
		zeStatus "A"

		factory :zeKonto_with_ozbKonto_and_Projektgruppe do
			before(:create) do |zeKonto|
				ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson)
				projektGruppe = FactoryGirl.create(:Projektgruppe)

				zeKonto.ktoNr = ozbKonto.ktoNr
				zeKonto.pgNr = projektGruppe.pgNr
			end
		end

	end

end