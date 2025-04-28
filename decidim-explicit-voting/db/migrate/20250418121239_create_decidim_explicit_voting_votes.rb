class CreateDecidimExplicitVotingVotes < ActiveRecord::Migration[7.0]
  def change
    create_table :decidim_explicit_voting_votes do |t|
      t.references :voting,
                   foreign_key: { to_table: :decidim_explicit_voting_votings, on_delete: :cascade },
                   index: { name: "decidim_exp_voting_votes_on_voting_id" }
      t.references :voting_option,
                   foreign_key: { to_table: :decidim_explicit_voting_options, on_delete: :cascade },
                   index: { name: "decidim_exp_voting_votes_on_option_id" }
      t.references :decidim_user,
                   foreign_key: true,
                   index: { name: "decidim_exp_voting_votes_on_user_id" }

      t.timestamps
    end

    add_index :decidim_explicit_voting_votes,
              [:voting_id, :decidim_user_id],
              unique: true,
              name: "decidim_exp_votes_unique_user_voting"
  end
end
