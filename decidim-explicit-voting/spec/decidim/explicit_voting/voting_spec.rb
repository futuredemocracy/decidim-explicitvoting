# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ExplicitVoting
    RSpec.describe Voting, type: :model do
      subject { voting }

      let(:organization) { create(:organization) }
      let(:component) { create(:component, organization: organization) }
      let(:voting) { create(:voting, component: component) }

      it { is_expected.to be_valid }
      it { is_expected.to belong_to(:component) }
      it { is_expected.to have_many(:voting_options) }
      it { is_expected.to have_many(:votes) }

      describe "validations" do
        it { is_expected.to validate_presence_of(:title) }
        it { is_expected.to validate_presence_of(:description) }
        it { is_expected.to validate_presence_of(:start_date) }
        it { is_expected.to validate_presence_of(:end_date) }
      end

      describe "scopes" do
        describe ".active" do
          let!(:active_voting) { create(:voting, component: component, start_date: 1.day.ago, end_date: 1.day.from_now) }
          let!(:inactive_voting) { create(:voting, component: component, start_date: 2.days.from_now, end_date: 3.days.from_now) }

          it "returns only active votings" do
            expect(described_class.active).to include(active_voting)
            expect(described_class.active).not_to include(inactive_voting)
          end
        end
      end

      describe "#active?" do
        context "when voting is active" do
          let(:voting) { create(:voting, component: component, start_date: 1.day.ago, end_date: 1.day.from_now) }

          it "returns true" do
            expect(voting.active?).to be true
          end
        end

        context "when voting is not active" do
          let(:voting) { create(:voting, component: component, start_date: 2.days.from_now, end_date: 3.days.from_now) }

          it "returns false" do
            expect(voting.active?).to be false
          end
        end
      end
    end
  end
end 