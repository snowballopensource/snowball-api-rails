FactoryGirl.define do
  factory :user do
    phone_number { Faker::Base.numerify('1415#3##47#') }
  end
end
