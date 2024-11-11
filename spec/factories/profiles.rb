FactoryBot.define do
  factory :profile do
    user { association(:user, _skip_creating_profile: true) }
  end

  trait :with_data do
    data do
      {
        favorite_song: "Hit's Different",
        favorite_era: "Midnights"
      }
    end
    website_url { "http://example.com" }
    location { "Tampa, FL" }
    summary { "I love Taylor Swift" }
  end
end
