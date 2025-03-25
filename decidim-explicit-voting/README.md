# Decidim Explicit Voting

A module for Decidim that allows explicit voting on various resources.

## Features

- Explicit voting (positive/negative/neutral) on any resource
- Polymorphic associations for flexible voting
- User-specific voting tracking
- Organization-scoped votes

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'decidim-explicit-voting'
```

And then execute:

```bash
$ bundle install
$ rails decidim_explicit_voting:install:migrations
$ rails db:migrate
```

## Usage

To make a model votable, include the `Votable` concern:

```ruby
class YourModel < ApplicationRecord
  include Decidim::ExplicitVoting::Votable
end
```

## Contributing

See [Decidim](https://github.com/decidim/decidim). 