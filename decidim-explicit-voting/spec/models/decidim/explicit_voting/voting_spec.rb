# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ExplicitVoting
    describe Voting do
      subject { voting }

      let(:component) { create(:component) }
      let(:voting) { create(:voting, component: component) }

      it { is_expected.to be_valid }

      it "has an association with component" do
        expect(subject.component).to eq(component)
      end

      describe "#active?" do
        context "when start_date is not set" do
          let(:voting) { create(:voting, start_date: nil, end_date: 1.day.from_now) }

          it "returns false" do
            expect(subject.active?).to be false
          end
        end

        context "when start_date is in the future" do
          let(:voting) { create(:voting, start_date: 1.day.from_now, end_date: 2.days.from_now) }

          it "returns false" do
            expect(subject.active?).to be false
          end
        end

        context "when start_date is in the past and end_date is in the future" do
          let(:voting) { create(:voting, start_date: 1.day.ago, end_date: 1.day.from_now) }

          it "returns true" do
            expect(subject.active?).to be true
          end
        end

        context "when end_date is in the past" do
          let(:voting) { create(:voting, start_date: 2.days.ago, end_date: 1.day.ago) }

          it "returns false" do
            expect(subject.active?).to be false
          end
        end
      end

      describe "#upcoming?" do
        context "when start_date is not set" do
          let(:voting) { create(:voting, start_date: nil, end_date: 1.day.from_now) }

          it "returns false" do
            expect(subject.upcoming?).to be false
          end
        end

        context "when start_date is in the future" do
          let(:voting) { create(:voting, start_date: 1.day.from_now, end_date: 2.days.from_now) }

          it "returns true" do
            expect(subject.upcoming?).to be true
          end
        end

        context "when start_date is in the past" do
          let(:voting) { create(:voting, start_date: 1.day.ago, end_date: 1.day.from_now) }

          it "returns false" do
            expect(subject.upcoming?).to be false
          end
        end
      end

      describe "#finished?" do
        context "when end_date is in the future" do
          let(:voting) { create(:voting, end_date: 1.day.from_now) }

          it "returns false" do
            expect(subject.finished?).to be false
          end
        end

        context "when end_date is in the past" do
          let(:voting) { create(:voting, end_date: 1.day.ago) }

          it "returns true" do
            expect(subject.finished?).to be true
          end
        end
      end
    end
  end
end 