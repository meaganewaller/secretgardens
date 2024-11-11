FactoryBot.define do
  sequence(:email) { |n| "person#{n}@example.com" }
  sequence(:username) { |n| "username#{n}" }
  sequence(:password) { Faker::Internet.password }

  factory :user do
    email    { generate(:email) }
    username { generate(:username) }
    password { generate(:password) }

    trait :admin do
      after(:build) { |user| user.update(admin: true) }
    end

    trait :without_profile do
      _skip_creating_profile { true }
    end
  end
end
