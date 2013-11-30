# Read about factories at https://github.com/thoughtbot/factory_girl

require 'faker'

FactoryGirl.define do 
  factory :user do 
    before(:create) do |user|
      person = FactoryGirl.create(:Person)
      ozbperson = FactoryGirl.create(:OZBPerson, :Mnr => person.Pnr, :UeberPnr => person.Pnr)
      user.id = ozbperson.Mnr
      user.email = person.EMail
    end
    password "12345678"
    password_confirmation "12345678"
  end

  factory :user_auth_it, :parent => :user do
    after(:create) do |user|
      FactoryGirl.create(:sonderberechtigung_it, :EMail => user.email, :Mnr => user.id)
    end
  end

  factory :user_auth_mv, :parent => :user do
    after(:create) do |user|
      FactoryGirl.create(:sonderberechtigung_mv, :EMail => user.email, :Mnr => user.id)
    end
  end

  factory :user_auth_rw, :parent => :user do
    after(:create) do |user|
      FactoryGirl.create(:sonderberechtigung_rw, :EMail => user.email, :Mnr => user.id)
    end
  end

  factory :user_auth_ze, :parent => :user do
    after(:create) do |user|
      FactoryGirl.create(:sonderberechtigung_ze, :EMail => user.email, :Mnr => user.id)
    end
  end

  factory :user_auth_oea, :parent => :user do
    after(:create) do |user|
      FactoryGirl.create(:sonderberechtigung_oea, :EMail => user.email, :Mnr => user.id)
    end
  end

end