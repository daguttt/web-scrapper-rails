FactoryBot.define do
  factory :page do
    url { Faker::Internet.url }
    title { Faker::Lorem.sentence }
    status { :processing }
    user
  end
end
