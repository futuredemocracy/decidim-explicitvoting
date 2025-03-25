# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ExplicitVoting
    RSpec.describe Vote, type: :model do
      subject { vote }

      let(:organization) { create(:organization) }
      let(:component) { create(:component, organization: organization) }
      let(:voting) { create(:voting, component: component) }
      let(:voting_option) { create(:voting_option, voting: voting) }
      let(:user) { create(:user, organization: organization) }
      let(:vote) { create(:vote, voting: voting, voting_option: voting_option, user: user) }

      it { is_expected.to be_valid }
      it { is_expected.to belong_to(:voting) }
      it { is_expected.to belong_to(:voting_option) }
      it { is_expected.to belong_to(:user) }

      describe "validations" do
        it { is_expected.to validate_presence_of(:voting) }
        it { is_expected.to validate_presence_of(:voting_option) }
        it { is_expected.to validate_presence_of(:user) }
        it { is_expected.to validate_uniqueness_of(:user).scoped_to(:voting_id) }
      end

      describe "scopes" do
        describe ".by_user" do
          let!(:user_vote) { create(:vote, user: user) }
          let!(:other_vote) { create(:vote) }

          it "returns votes by user" do
            expect(described_class.by_user(user)).to include(user_vote)
            expect(described_class.by_user(user)).not_to include(other_vote)
          end
        end
      end
    end
  end
end 