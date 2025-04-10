# frozen_string_literal: true

require "spec_helper"

describe Decidim::Budgets::Budget do
  subject(:budget) { build(:budget) }

  it { is_expected.to be_valid }
  it { is_expected.to act_as_paranoid }

  include_examples "has component"
  include_examples "has taxonomies"
  include_examples "resourceable"

  describe "check the log result" do
    it "overwrites the log presenter" do
      expect(described_class.log_presenter_class_for(:foo))
        .to eq Decidim::Budgets::AdminLog::BudgetPresenter
    end
  end
end
