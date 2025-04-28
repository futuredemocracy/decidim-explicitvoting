# frozen_string_literal: true

FactoryBot.define do
  factory :voting, class: "Decidim::ExplicitVoting::Voting" do
    title { generate_localized_title }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_description } }
    start_date { 1.day.ago }
    end_date { 1.week.from_now }
    secret { false }
    component { create(:explicit_voting_component) }

    trait :active do
      start_date { 1.day.ago }
      end_date { 1.week.from_now }
    end

    trait :upcoming do
      start_date { 1.week.from_now }
      end_date { 2.weeks.from_now }
    end

    trait :finished do
      start_date { 2.weeks.ago }
      end_date { 1.week.ago }
    end

    trait :secret do
      secret { true }
    end
  end
end
