# frozen_string_literal: true

require "decidim/explicit_voting/engine"
require "decidim/explicit_voting/admin"
require "decidim/explicit_voting/admin_engine"
require "decidim/explicit_voting/component"

module Decidim
  module ExplicitVoting
    autoload :Vote, "decidim/explicit_voting/vote"
    autoload :Voting, "decidim/explicit_voting/voting"
    autoload :Permissions, "decidim/explicit_voting/permissions"
  end
end 