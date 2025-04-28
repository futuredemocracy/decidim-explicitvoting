# frozen_string_literal: true

FactoryBot.define do
  factory :voting_option, class: "Decidim::ExplicitVoting::VotingOption" do
    name { Faker::Lorem.word }
    position { Faker::Number.between(from: 0, to: 10) }
    voting
  end
end
