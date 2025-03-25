# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ExplicitVoting
    describe Vote do
      subject { vote }

      let(:organization) { create(:organization) }
      let(:component) { create(:component, organization: organization) }
      let(:voting) { create(:voting, component: component) }
      let(:voting_option) { create(:voting_option, voting: voting) }
      let(:user) { create(:user, organization: organization) }
      let(:vote) { build(:vote, voting: voting, voting_option: voting_option, user: user) }

      it { is_expected.to be_valid }

      it "has an association with voting" do
        expect(subject.voting).to eq(voting)
      end

      it "has an association with voting_option" do
        expect(subject.voting_option).to eq(voting_option)
      end

      it "has an association with user" do
        expect(subject.user).to eq(user)
      end

      context "when voting is not active" do
        let(:voting) { create(:voting, start_date: 1.day.from_now, end_date: 2.days.from_now) }

        it { is_expected.not_to be_valid }
      end

      context "when user has already voted" do
        before do
          create(:vote, voting: voting, user: user)
        end

        it { is_expected.not_to be_valid }
      end

      context "when voting_option does not belong to voting" do
        let(:other_voting) { create(:voting, component: component) }
        let(:voting_option) { create(:voting_option, voting: other_voting) }

        it { is_expected.not_to be_valid }
      end
    end
  end
end 