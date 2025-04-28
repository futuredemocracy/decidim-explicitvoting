# frozen_string_literal: true

FactoryBot.define do
  factory :vote, class: "Decidim::ExplicitVoting::Vote" do
    voting
    voting_option { create(:voting_option, voting: voting) }
    user { create(:user, organization: voting.component.organization) }
  end
end
