# frozen_string_literal: true

module Decidim
  module ExplicitVoting
    class Vote < ApplicationRecord
      belongs_to :author, class_name: "Decidim::User"
      belongs_to :votable, polymorphic: true
      belongs_to :organization, class_name: "Decidim::Organization"

      validates :author, presence: true
      validates :votable, presence: true
      validates :organization, presence: true
      validates :vote_type, presence: true
    end
  end
end 