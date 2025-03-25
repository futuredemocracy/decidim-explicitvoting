# frozen_string_literal: true

require "decidim/core/test/factories"

FactoryBot.define do
  factory :explicit_voting_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :explicit_voting).i18n_name }
    manifest_name { :explicit_voting }
    participatory_space { create(:participatory_process, :with_steps, organization: organization) }
  end

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

  factory :voting_option, class: "Decidim::ExplicitVoting::VotingOption" do
    name { Faker::Lorem.word }
    position { Faker::Number.between(from: 0, to: 10) }
    voting
  end

  factory :vote, class: "Decidim::ExplicitVoting::Vote" do
    voting
    voting_option { create(:voting_option, voting: voting) }
    user { create(:user, organization: voting.component.organization) }
  end
end

def generate_localized_title
  Decidim::Faker::Localized.localized { Faker::Lorem.sentence(word_count: 3) }
end

def generate_localized_description
  Decidim::Faker::Localized.localized { Faker::Lorem.paragraph(sentence_count: 3) }
end 