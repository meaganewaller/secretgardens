FactoryBot.define do
  sequence(:email) { |n| "person#{n}@example.com" }
  sequence(:username) { |n| "username#{n}" }

  factory :user do
    gen_password = Faker::Internet.password
    email    { generate(:email) }
    username { generate(:username) }
    password { gen_password }
    password_confirmation { gen_password }

    trait :admin do
      after(:build) { |user| user.update(admin: true) }
    end
  end
end
