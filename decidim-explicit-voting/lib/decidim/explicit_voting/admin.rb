# frozen_string_literal: true

module Decidim
  module ExplicitVoting
    module Admin
      autoload :VotingsController, "decidim/explicit_voting/admin/votings_controller"
      autoload :VotingOptionsController, "decidim/explicit_voting/admin/voting_options_controller"
    end
  end
end 