require 'faker'

FactoryGirl.define do
  
  factory :sonderberechtigung do
    EMail Faker::Internet.email
    
    factory :sonderberechtigung_it do 
      Berechtigung "IT"
    end 

    factory :sonderberechtigung_mv do
      Berechtigung "MV"
    end

    factory :sonderberechtigung_rw do
      Berechtigung "RW"
    end

    factory :sonderberechtigung_ze do
      Berechtigung "ZE"
    end

    factory :sonderberechtigung_oea do
      Berechtigung "OeA"
    end

  end

end