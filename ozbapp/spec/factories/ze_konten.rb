require 'faker'

FactoryGirl.define do

	factory :ZeKonto do
		sequence(:ktoNr) {|n| "#{n}"} 
		sequence(:eeKtoNr) {|n| "#{n}"}
		sequence(:laufzeit) {|n| "#{n}"}
		sequence(:pgNr) {|n| "#{n}"}
		sequence(:zeNr) {|n| "D"+(n*10000000).to_s[0, 8]} 
		zahlModus "M"
		tilgRate 100.00
		ansparRate 20.00
		kduRate 5.00
		rduRate 5.00
		zeStatus "A"

		factory :zeKonto_with_EEKonto_Projektgruppe do
			before(:create) do |zeKonto|
				projektGruppe = FactoryGirl.create(:Projektgruppe)
				eeKonto = FactoryGirl.create(:eekonto_with_ozbkonto_and_sachPerson_and_bankverbindung)

				zeKonto.eeKtoNr = eeKonto.ktoNr
				zeKonto.pgNr = projektGruppe.pgNr
			end
		end


		factory :zeKonto_with_ozbKonto_and_EEKonto_Projektgruppe do
			before(:create) do |zeKonto|
				ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson)
				projektGruppe = FactoryGirl.create(:Projektgruppe)
				eeKonto = FactoryGirl.create(:eekonto_with_ozbkonto_and_sachPerson_and_bankverbindung)

				zeKonto.ktoNr = ozbKonto.ktoNr
				zeKonto.eeKtoNr = eeKonto.ktoNr
				zeKonto.pgNr = projektGruppe.pgNr
			end
		end

		factory :zeKonto_with_ozbKonto_and_EEKonto do
			before(:create) do |zeKonto|
				ozbKonto = FactoryGirl.create(:ozbkonto_with_ozbperson)
				eeKonto = FactoryGirl.create(:eekonto_with_ozbkonto_and_sachPerson_and_bankverbindung)

				zeKonto.ktoNr = ozbKonto.ktoNr
				zeKonto.eeKtoNr = eeKonto.ktoNr
			end
		end

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