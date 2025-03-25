# frozen_string_literal: true

FactoryBot.define do
  factory :voting, class: "Decidim::ExplicitVoting::Voting" do
    title { Decidim::Faker::Localized.sentence }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.paragraph(sentence_count: 3) } }
    start_date { 1.day.ago }
    end_date { 1.day.from_now }
    component { create(:component) }
  end

  factory :voting_option, class: "Decidim::ExplicitVoting::VotingOption" do
    title { Decidim::Faker::Localized.sentence }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.paragraph(sentence_count: 3) } }
    voting { create(:voting) }
  end

  factory :vote, class: "Decidim::ExplicitVoting::Vote" do
    voting { create(:voting) }
    voting_option { create(:voting_option, voting: voting) }
    user { create(:user, organization: voting.component.organization) }
  end
end 