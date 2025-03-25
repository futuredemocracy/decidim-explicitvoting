# frozen_string_literal: true

Gem::Specification.new do |s|
  s.version = "0.1.0"
  s.authors = ["Your Name"]
  s.email = ["your.email@example.com"]

  s.summary = "Explicit voting module for Decidim"
  s.description = "A module that allows explicit voting in Decidim"
  s.homepage = "https://github.com/yourusername/decidim-explicit-voting"
  s.license = "AGPL-3.0"
  s.required_ruby_version = ">= 2.7.5"

  s.name = "decidim-explicit_voting"
  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", "~> 0.27.0"
  s.add_dependency "decidim-admin", "~> 0.27.0"
  s.add_dependency "decidim-participatory_processes", "~> 0.27.0"

  s.add_development_dependency "decidim-dev", "~> 0.27.0"
end 