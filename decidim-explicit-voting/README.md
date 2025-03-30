# Decidim Explicit Voting

Module for conducting votes in the Decidim system.

## Features

1. Ability to set a question and informational material before voting (text field for administrator).
2. Three default voting options: FOR, AGAINST, ABSTAIN (with the ability for administrators to change names).
3. After casting a vote, the voter does not see immediate results.
4. After the voting is completed (at a time determined by the administrator), results are displayed (number of votes for each option).
5. Ability to generate a "voting protocol" - a list of voters and their choices (if it is not a secret ballot).
6. Secret ballot option - general results visible to everyone, but the list of voters is only available to the administrator.

## Description of the voting process

### User view

1. User goes to the voting section within a specific process.
2. Reads the voting description [text field].
3. Selects one of the available options ("FOR", "AGAINST", "ABSTAIN" or their modified names).
4. By clicking "Cast vote", they complete their participation in the voting, or they click on the FOR, AGAINST, etc. buttons.
5. They receive a confirmation message without the ability to change their decision.
6. After the voting ends, a view appears or they can download the protocol (list of votes and choices, if not secret).

### Administrator view

1. Creating a new vote:
   a) Setting the question and description.
   b) Setting the voting duration.
   c) Selecting the voting mode (public/secret = no display of point 6 to users).
2. Preview of ongoing votes.
3. After the voting ends:
   a) Display of results.
   b) Downloading the protocol (list of votes and choices).
   c) Ability to export data to CSV/PDF file.

## Installation

Add this gem to your application's Gemfile:

```ruby
gem "decidim-explicit_voting"
```

And then execute:

```bash
bundle install
bundle exec rails decidim_explicit_voting:install:migrations
bundle exec rails db:migrate
```

## Usage

### Component configuration

1. Go to the admin panel
2. Select a participatory process
3. Add the "Explicit Voting" component
4. Configure the component settings

### Creating a vote

1. Go to the component admin panel
2. Click "New vote"
3. Fill out the form:
   - Title and description of the vote
   - Start and end date
   - Choose whether the vote should be secret

### Casting votes

1. User goes to the voting section
2. Reads the voting description
3. Selects one of the available options
4. Confirms their choice
5. Receives confirmation of their vote

### Voting results

1. After the voting ends, results are automatically published
2. The administrator can download a voting protocol containing:
   - Number of votes cast
   - Distribution of votes for each option
   - List of voters (in case of public voting)

## Development

### Tests

To run the tests:

```bash
bundle exec rspec
```

### Translations

The module supports multilingualism. Translations are located in the `config/locales` directory.

## License

The source code is available under the [GNU AFFERO GENERAL PUBLIC LICENSE](LICENSE-AGPLv3.txt).

## Contribution

See [Decidim](https://github.com/decidim/decidim). 