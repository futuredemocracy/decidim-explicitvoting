# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ExplicitVoting
    RSpec.describe VotingOption, type: :model do
      subject { voting_option }

      let(:organization) { create(:organization) }
      let(:component) { create(:component, organization: organization) }
      let(:voting) { create(:voting, component: component) }
      let(:voting_option) { create(:voting_option, voting: voting) }

      it { is_expected.to be_valid }
      it { is_expected.to belong_to(:voting) }
      it { is_expected.to have_many(:votes) }

      describe "validations" do
        it { is_expected.to validate_presence_of(:title) }
        it { is_expected.to validate_presence_of(:description) }
      end

      describe "#votes_count" do
        let!(:vote1) { create(:vote, voting_option: voting_option) }
        let!(:vote2) { create(:vote, voting_option: voting_option) }

        it "returns the number of votes" do
          expect(voting_option.votes_count).to eq(2)
        end
      end
    end
  end
end 