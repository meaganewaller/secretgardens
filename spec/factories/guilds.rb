FactoryBot.define do
  factory :guild do
    name { "MyString" }
    summary { "MyText" }
    url { Faker::Internet.url }
    last_blog_post_at { "2024-11-11 19:53:04" }
    latest_blog_post_updated_at { "2024-11-11 19:53:04" }
    profile_updated_at { "2024-11-11 19:53:04" }
    slug { "MyString" }
    tag_line { "MyString" }
  end
end
